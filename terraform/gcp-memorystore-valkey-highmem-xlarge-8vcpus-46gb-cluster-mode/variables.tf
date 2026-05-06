################################################################################
# Variables used for deployment tag
################################################################################

variable "instance_id" {
  description = "The ID to use for the Valkey instance"
  default     = "memorystore-valkey-xlarge-8vcpus-46gb-cluster-mode"
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default = "your-gcp-project"
}

variable "location" {
  description = "The region where Valkey cluster will be created"
  default     = "us-east1"
}

variable "node_type" {
  description = "The nodeType for the Valkey cluster"
  default     = "HIGHMEM_XLARGE"
}

variable "shard_count" {
  description = "Number of shards for the instance"
  default     = 1
}

variable "replica_count" {
  description = "Number of replica nodes per shard"
  default     = 1
}

variable "tls" {
  description = "Enable TLS encryption in transit"
  default     = false
}

variable "auth_mode" {
  description = "Authorization mode of the instance"
  default     = "AUTH_DISABLED"
}

variable "network" {
  description = "Name of the consumer network"
  default     = "default"
}

variable "subnet_names" {
  description = "List of subnet names for service connection policies"
  type        = list(string)
  default     = ["default"]
}

variable "engine_version" {
  description = "Engine version of the instance"
  default     = "VALKEY_9_0"
}

variable "deletion_protection_enabled" {
  description = "If set to true deletion of the instance will fail"
  default     = false
}

variable "maxmemory_policy" {
  description = "Maxmemory policy for the Valkey instance"
  default     = "volatile-ttl"
}

variable "region" {
  description = "GCP region for shared resources"
  default     = "us-east1"
}

################################################################################
# Variables used for GitHub Actions deployment tracking
################################################################################

variable "github_actor" {
  description = "The name of the person or app that initiated the deployment."
  default     = "N/A"
}

variable "github_repo" {
  description = "The owner and repository name. For example, testing-infrastructure."
  default     = "N/A"
}

variable "triggering_env" {
  description = "The triggering environment. For example circleci."
  default     = "N/A"
}

variable "github_org" {
  description = "The owner name. For example, RedisModules."
  default     = "N/A"
}

variable "github_sha" {
  description = "The commit SHA that triggered the deployment."
  default     = "N/A"
}
