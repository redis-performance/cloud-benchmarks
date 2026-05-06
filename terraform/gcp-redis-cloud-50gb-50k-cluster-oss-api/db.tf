# Generate a random offset to find an available CIDR
resource "random_integer" "cidr_offset" {
  min = 150
  max = 200
}

resource "random_id" "subscription_suffix" {
  byte_length = 4
}

locals {
  deployment_start_time    = timestamp()
  deployment_cidr          = "10.3.${random_integer.cidr_offset.result}.0/24"
  deployment_timestamp     = formatdate("YYYYMMDDHHmmss", timestamp())
  subscription_name_unique = "${var.subscription_name}-${random_id.subscription_suffix.hex}"
  db_name_unique           = "${var.db_name}-${random_id.subscription_suffix.hex}"
}

data "rediscloud_payment_method" "card" {
  card_type         = "Mastercard"
  last_four_numbers = data.external.env.result["rediscloud_payment_4digits"]
}

resource "rediscloud_subscription" "subscription-resource" {
  name              = local.subscription_name_unique
  payment_method    = "credit-card"
  payment_method_id = data.rediscloud_payment_method.card.id
  memory_storage    = "ram"

  cloud_provider {
    provider = "GCP"
    region {
      region                       = "us-east1"
      multiple_availability_zones  = false
      networking_deployment_cidr   = local.deployment_cidr
      preferred_availability_zones = ["us-east1-b"]
    }
  }

  creation_plan {
    memory_limit_in_gb           = var.memory_limit_in_gb
    quantity                     = 1
    replication                  = var.replication
    support_oss_cluster_api      = var.support_oss_cluster_api
    throughput_measurement_by    = "operations-per-second"
    throughput_measurement_value = var.ops_sec
    modules                      = []
  }
}

resource "random_id" "database_retry" {
  byte_length = 4
  keepers = {
    subscription_id = rediscloud_subscription.subscription-resource.id
  }
}

resource "rediscloud_subscription_database" "database-resource" {
  subscription_id                       = rediscloud_subscription.subscription-resource.id
  name                                  = local.db_name_unique
  protocol                              = "redis"
  memory_limit_in_gb                    = var.memory_limit_in_gb
  data_persistence                      = "none"
  password                              = data.external.env.result["rediscloud_default_password"]
  throughput_measurement_by             = "operations-per-second"
  throughput_measurement_value          = var.ops_sec
  external_endpoint_for_oss_cluster_api = false
  replication                           = var.replication
  support_oss_cluster_api               = var.support_oss_cluster_api
  depends_on                            = [rediscloud_subscription.subscription-resource]
  enable_tls                            = var.tls

  lifecycle {
    ignore_changes        = [subscription_id]
    create_before_destroy = true
  }
}

resource "null_resource" "deployment_timer" {
  depends_on = [
    rediscloud_subscription.subscription-resource,
    rediscloud_subscription_database.database-resource
  ]

  provisioner "local-exec" {
    command = "echo 'Deployment completed at: '$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  }

  triggers = {
    deployment_end_time = timestamp()
  }
}
