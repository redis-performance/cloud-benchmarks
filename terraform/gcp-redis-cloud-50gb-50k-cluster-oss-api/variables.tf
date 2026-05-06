################################################################################
# RCP cell sized to dollar-match GCP Memorystore for Valkey 9 highmem-xlarge
# (~$1.94/hr in us-east1, March 2026 pricing). Cluster-enabled + OSS Cluster API
# so we can drive memtier --cluster-mode against it head-to-head.
################################################################################

# RCP enforces a max name length of 40 chars on subscription/db names. The
# random_id suffix appended in db.tf (-XXXXXXXX, 9 chars) leaves 31 for the
# base name. Keep these short.
variable "db_name" {
  description = "db name (suffixed with random hex; total must fit in 40 chars)"
  default     = "gcp-50gb-50k-blog-db"
}

variable "subscription_name" {
  description = "subscription name (suffixed with random hex; total must fit in 40 chars)"
  default     = "gcp-50gb-50k-blog-rcp"
}

variable "ops_sec" {
  description = "throughput tier (operations per second)"
  default     = 50000
}

variable "memory_limit_in_gb" {
  description = "memory_limit_in_gb"
  default     = 50
}

variable "tls" {
  description = "tls"
  default     = false
}

variable "replication" {
  description = "replication enabled (HA)"
  default     = true
}

variable "support_oss_cluster_api" {
  description = "support_oss_cluster_api — required for memtier --cluster-mode"
  default     = true
}

# Tagging-metadata variables passed by `redis-cloud-deploy-gcp-reusable.yml`.
# Empty defaults so a local-CLI plan/apply still works without these set.
variable "github_actor" {
  default = ""
}
variable "github_repo" {
  default = ""
}
variable "github_org" {
  default = ""
}
variable "github_sha" {
  default = ""
}
variable "triggering_env" {
  default = ""
}
