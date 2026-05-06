
output "deployment_cidr" {
  value       = local.deployment_cidr
  description = "Auto-generated CIDR block used for deployment"
}

output "public_endpoint" {
  value       = rediscloud_subscription_database.database-resource.public_endpoint
  description = "Redis database public endpoint"
}

output "private_endpoint" {
  value       = rediscloud_subscription_database.database-resource.private_endpoint
  description = "Redis database private endpoint"
}

output "database_password" {
  value       = rediscloud_subscription_database.database-resource.password
  description = "Redis database password"
  sensitive   = true
}

output "database_info" {
  value = {
    public_endpoint  = rediscloud_subscription_database.database-resource.public_endpoint
    private_endpoint = rediscloud_subscription_database.database-resource.private_endpoint
    password         = rediscloud_subscription_database.database-resource.password
  }
  description = "Complete Redis database connection information"
  sensitive   = true
}

output "deployment_start_time" {
  value       = local.deployment_start_time
  description = "Timestamp when deployment started"
}

output "deployment_timestamp" {
  value       = local.deployment_timestamp
  description = "Formatted timestamp used for unique resource naming (YYYYMMDDHHmmss)"
}

output "deployment_end_time" {
  value       = null_resource.deployment_timer.triggers.deployment_end_time
  description = "Timestamp when deployment completed"
}

output "deployment_timing" {
  value       = "Started: ${local.deployment_start_time} | Completed: ${null_resource.deployment_timer.triggers.deployment_end_time} | ID: ${local.deployment_timestamp}"
  description = "Deployment start and end times with unique timestamp ID"
}

output "subscription_info" {
  value = {
    id   = rediscloud_subscription.subscription-resource.id
    name = rediscloud_subscription.subscription-resource.name
  }
  description = "Redis Cloud subscription information"
}
