output "scp_name" {
  value       = google_network_connectivity_service_connection_policy.memorystore.name
  description = "Name of the shared Memorystore SCP."
}

output "scp_id" {
  value       = google_network_connectivity_service_connection_policy.memorystore.id
  description = "Full resource ID of the shared Memorystore SCP."
}

output "network" {
  value       = data.google_compute_network.network.name
  description = "VPC network the SCP is bound to."
}

output "subnetwork" {
  value       = data.google_compute_subnetwork.subnet.name
  description = "Subnetwork PSC consumer addresses are allocated from."
}
