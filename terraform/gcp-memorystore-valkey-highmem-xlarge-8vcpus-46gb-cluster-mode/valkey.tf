# Generate a random suffix for unique naming
resource "random_id" "valkey_suffix" {
  byte_length = 4
}

locals {
  deployment_start_time = timestamp()
  instance_id_with_suffix = "${var.instance_id}-${random_id.valkey_suffix.hex}"
  
  # Determine transit encryption mode based on TLS variable
  transit_encryption_mode = var.tls ? "SERVER_AUTHENTICATION" : "TRANSIT_ENCRYPTION_DISABLED"
  
  # Determine authorization mode based on TLS (AUTH requires TLS in GCP Memorystore)
  authorization_mode = var.tls ? var.auth_mode : "AUTH_DISABLED"
}

# Create Valkey cluster using the terraform-google-modules/memorystore module
module "valkey_cluster" {
  source  = "terraform-google-modules/memorystore/google//modules/valkey"
  version = "~> 15.1"

  # Core configuration
  authorization_mode                    = local.authorization_mode
  automated_backup_config               = null
  deletion_protection_enabled           = var.deletion_protection_enabled
  enable_apis                           = false
  engine_configs                        = {
    maxmemory-policy = var.maxmemory_policy
  }
  engine_version                        = var.engine_version
  gcs_source                           = null
  instance_id                          = local.instance_id_with_suffix

  location                             = var.location
  managed_backup_source                = null
  mode                                 = "CLUSTER"
  network                              = var.network
  node_type                            = var.node_type
  persistence_config                   = {}
  project_id                           = var.project_id
  replica_count                        = var.replica_count
  # SCP is owned by the standalone `terraform/gcp-memorystore-shared-scp/`
  # cell — GCP allows only one SCP per (network, gcp-memorystore) pair, so
  # parallel/serial Memorystore deploys can't each create their own. The
  # Service Connect Automation infrastructure on the cluster instance
  # auto-discovers the SCP by network + service-class, so we just have to
  # NOT create one here.
  service_connection_policies = {}
  shard_count                          = var.shard_count
  transit_encryption_mode              = local.transit_encryption_mode
  zone_distribution_config_mode        = "SINGLE_ZONE"
  zone_distribution_config_zone        =  "us-east1-b"

  
}

# Null resource to capture deployment completion time
resource "null_resource" "deployment_timer" {
  depends_on = [module.valkey_cluster]

  provisioner "local-exec" {
    command = "echo 'Valkey deployment completed at: '$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  }

  triggers = {
    deployment_end_time = timestamp()
  }
}
