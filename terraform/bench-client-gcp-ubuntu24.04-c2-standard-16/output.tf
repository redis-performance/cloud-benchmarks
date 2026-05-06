output "server_public_ip" {
  value = google_compute_instance.benchmark_client[*].network_interface[0].access_config[0].nat_ip
  description = "Public IP addresses of the benchmark client instances"
}

output "server_private_ip" {
  value = google_compute_instance.benchmark_client[*].network_interface[0].network_ip
  description = "Private IP addresses of the benchmark client instances"
}

output "instance_names" {
  value = google_compute_instance.benchmark_client[*].name
  description = "Names of the benchmark client instances"
}

output "instance_zones" {
  value = google_compute_instance.benchmark_client[*].zone
  description = "Zones of the benchmark client instances"
}

output "machine_type" {
  value = var.machine_type
  description = "Machine type used for the benchmark client instances"
}

output "ssh_connection_info" {
  value = {
    user        = var.ssh_user
    private_key = tls_private_key.ssh_key.private_key_pem
    public_key  = tls_private_key.ssh_key.public_key_openssh
    public_ips  = google_compute_instance.benchmark_client[*].network_interface[0].access_config[0].nat_ip
    gcp_ssh_command = "gcloud compute ssh ${var.ssh_user}@${google_compute_instance.benchmark_client[0].name} --zone=${var.zone} --project=${var.project_id}"
  }
  description = "SSH connection information for the benchmark client instances"
  sensitive   = true
}

output "instance_info" {
  value = {
    count       = var.instance_count
    machine_type = var.machine_type
    zone        = var.zone
    region      = var.region
    project     = var.project_id
    setup_name  = var.setup_name
  }
  description = "Complete instance configuration information"
}

output "firewall_rule" {
  value = google_compute_firewall.benchmark_client_ssh.name
  description = "Name of the firewall rule created for SSH access"
}

output "deployment_metadata" {
  value = {
    github_actor   = var.github_actor
    github_repo    = var.github_repo
    github_org     = var.github_org
    github_sha     = var.github_sha
    triggering_env = var.triggering_env
    environment    = var.environment
  }
  description = "Deployment metadata and tags"
}
