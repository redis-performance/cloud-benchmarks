output "instance_id" {
  value       = module.valkey_cluster.id
  description = "The Valkey cluster instance ID"
}

output "endpoints" {
  value       = module.valkey_cluster.endpoints
  description = "Endpoints for the Valkey instance"
}

# Primary endpoint IP address (from the first PSC auto connection with CONNECTION_TYPE_PRIMARY)
output "primary_endpoint" {
  value = try(
    [for conn in module.valkey_cluster.endpoints[0].connections :
      conn.psc_auto_connection[0].ip_address
      if conn.psc_auto_connection[0].connection_type == "CONNECTION_TYPE_PRIMARY"
    ][0],
    module.valkey_cluster.endpoints[0].connections[0].psc_auto_connection[0].ip_address
  )
  description = "The primary endpoint IP address for the Valkey instance"
}

# Primary endpoint port
output "primary_endpoint_port" {
  value = try(
    [for conn in module.valkey_cluster.endpoints[0].connections :
      conn.psc_auto_connection[0].port
      if conn.psc_auto_connection[0].connection_type == "CONNECTION_TYPE_PRIMARY"
    ][0],
    6379
  )
  description = "The primary endpoint port for the Valkey instance"
}

# GCP Memorystore uses IAM authentication, not password tokens
output "auth_token" {
  value       = null
  description = "GCP Memorystore uses IAM authentication - no password token required"
  sensitive   = true
}
