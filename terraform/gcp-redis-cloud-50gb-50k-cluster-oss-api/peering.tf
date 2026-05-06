
data "google_compute_network" "network" {
  project = "your-gcp-project"
  name    = "default"
}

resource "rediscloud_subscription_peering" "gcp-peering" {
  subscription_id  = rediscloud_subscription.subscription-resource.id
  provider_name    = "GCP"
  gcp_project_id   = data.google_compute_network.network.project
  gcp_network_name = data.google_compute_network.network.name
}

resource "google_compute_network_peering" "redis-cloud-peering" {
  name         = "redis-cloud-peering-${local.deployment_timestamp}"
  network      = data.google_compute_network.network.self_link
  peer_network = "https://www.googleapis.com/compute/v1/projects/${rediscloud_subscription_peering.gcp-peering.gcp_redis_project_id}/global/networks/${rediscloud_subscription_peering.gcp-peering.gcp_redis_network_name}"

  depends_on = [rediscloud_subscription_peering.gcp-peering]
}
