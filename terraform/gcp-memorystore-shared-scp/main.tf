# Standalone Service Connection Policy for GCP Memorystore (Valkey).
#
# GCP enforces ONE ServiceConnectionPolicy per (network, service-class)
# combination. The per-instance terraform cells (e.g.,
# `gcp-memorystore-valkey-highmem-xlarge-8vcpus-46gb-cluster-mode`) used to
# create their own SCP via the `terraform-google-modules/memorystore` module,
# which made parallel deploys collide and serialized deploys with skip_destroy
# also collide on retry.
#
# This cell creates the SCP once. All Memorystore deploys reference it via
# the existing network (Service Connect Automation auto-discovers SCPs by
# network + service-class), so no module-input wiring is needed downstream —
# the per-instance cells just need to skip their own SCP creation.

data "google_compute_network" "network" {
  project = "your-gcp-project"
  name    = var.network_name
}

data "google_compute_subnetwork" "subnet" {
  project = "your-gcp-project"
  name    = var.subnet_name
  region  = var.location
}

resource "google_network_connectivity_service_connection_policy" "memorystore" {
  name          = var.scp_name
  location      = var.location
  service_class = "gcp-memorystore"
  description   = "Shared SCP for Memorystore Valkey deploys (managed by gcp-memorystore-shared-scp)"
  network       = data.google_compute_network.network.id

  psc_config {
    subnetworks = [data.google_compute_subnetwork.subnet.id]
  }

  labels = {
    managed-by = "terraform"
    shared-by  = "memorystore-valkey-deploys"
  }
}
