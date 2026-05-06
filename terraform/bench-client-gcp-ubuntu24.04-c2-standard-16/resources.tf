# Generate random suffix for unique naming
resource "random_id" "instance_suffix" {
  byte_length = 4
}

# Get the latest Ubuntu 24.04 LTS image
data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}

# Generate SSH key pair for GCP metadata (no file operations needed)
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create firewall rule to allow SSH access
resource "google_compute_firewall" "benchmark_client_ssh" {
  name    = "benchmark-client-ssh-${random_id.instance_suffix.hex}"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["benchmark-client"]

  description = "Allow SSH access to benchmark client instances"
}

# Create the benchmark client instance
resource "google_compute_instance" "benchmark_client" {
  count        = var.instance_count
  name         = "${var.setup_name}-${count.index + 1}-${random_id.instance_suffix.hex}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["benchmark-client"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnet
    
    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${tls_private_key.ssh_key.public_key_openssh}"
  }

  labels = {
    environment    = lower(replace(var.environment, "/[^a-z0-9_-]/", "-"))
    setup          = lower(replace(replace(replace(var.setup_name, ".", "-"), "/", "-"), "_", "-"))
    triggering_env = var.triggering_env == "N/A" ? "manual" : substr(lower(replace(replace(replace(var.triggering_env, ".", "-"), "/", "-"), "_", "-")), 0, 63)
    github_actor   = var.github_actor == "N/A" ? "unknown" : substr(lower(replace(replace(replace(var.github_actor, ".", "-"), "/", "-"), "_", "-")), 0, 63)
    github_org     = var.github_org == "N/A" ? "unknown" : substr(lower(replace(replace(replace(var.github_org, ".", "-"), "/", "-"), "_", "-")), 0, 63)
    github_repo    = var.github_repo == "N/A" ? "unknown" : substr(lower(replace(replace(replace(var.github_repo, ".", "-"), "/", "-"), "_", "-")), 0, 63)
    managed_by     = "terraform"
  }

  depends_on = [
    tls_private_key.ssh_key,
    google_compute_firewall.benchmark_client_ssh
  ]

  ################################################################################
  # Wait for instance to be ready
  ################################################################################
  provisioner "remote-exec" {
    inline = [
      "echo 'Instance is ready for configuration'"
    ]
    
    connection {
      type        = "ssh"
      host        = self.network_interface[0].access_config[0].nat_ip
      user        = var.ssh_user
      private_key = tls_private_key.ssh_key.private_key_pem
      timeout     = "5m"
      agent       = false
    }
  }

  ################################################################################
  # Install redis-tools and memtier_benchmark
  ################################################################################
  provisioner "remote-exec" {
    inline = [
      "echo 'Starting benchmark tools installation...'",

      # Install prerequisites for Redis repository
      "sudo apt-get update",
      "sudo apt-get install -y lsb-release curl gpg",

      # Add Redis APT repository
      "curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg",
      "echo \"deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/redis.list",

      # Update package list with new repository
      "sudo apt-get update",

      # Install redis-tools, memtier-benchmark, python3-pip, and docker
      "sudo apt-get install -y redis-tools memtier-benchmark python3-pip docker.io",

      # Add ubuntu user to docker group
      "sudo usermod -aG docker ubuntu",

      # Update pip and install redis-benchmarks-specification (Ubuntu 24.04 requires --break-system-packages)
      "pip3 install --upgrade pip --break-system-packages",

      # Install redis-benchmarks-specification
      "pip3 install redis-benchmarks-specification --break-system-packages",

      # Add pip user bin to PATH for current session and future logins
      "echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc",
      "export PATH=$HOME/.local/bin:$PATH",

      # Verify installations
      "echo 'Verifying installations...'",
      "redis-cli --version",
      "memtier_benchmark --version",
      "python3 --version",
      "pip3 --version",
      "docker --version",
      "export PATH=$HOME/.local/bin:$PATH && redis-benchmarks-spec-client-runner --version",
      "echo 'All tools installation completed successfully!'"
    ]

    connection {
      type        = "ssh"
      host        = self.network_interface[0].access_config[0].nat_ip
      user        = var.ssh_user
      private_key = tls_private_key.ssh_key.private_key_pem
      timeout     = "10m"
      agent       = false
    }
  }
}
