/**
 * Copyright 2020 Quortex
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  type        = string
  description = "The GCP project in which to create the cluster."
}

variable "location" {
  type        = string
  description = "The location in which to create the cluster (set zone for zonal cluster and region for regional one)."
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster."
  default     = "quortex"
}

variable "cluster_description" {
  type        = string
  description = "Description of the cluster."
  default     = ""
}

variable "min_master_version" {
  type        = string
  description = "The minimum version of the master. GKE will auto-update the master to new versions, so this does not guarantee the current master version."
}

variable "network" {
  type        = string
  description = "The name or self_link of the Google Compute Engine network to which the cluster is connected."
}

variable "subnetwork" {
  type        = string
  description = "The name or self_link of the Google Compute Engine subnetwork in which the cluster's instances are launched."
}

variable "pod_range_name" {
  type        = string
  description = "The name of the existing secondary range in the cluster's subnetwork to use for pod IP addresses."
}

variable "svc_range_name" {
  type        = string
  description = "The name of the existing secondary range in the cluster's subnetwork to use for service ClusterIPs."
}

variable "default_max_pods_per_node" {
  type        = string
  description = "The default maximum number of pods per node in this cluster."
  default     = 110
}

variable "master_cidr_block" {
  type        = string
  description = "The IP range in CIDR notation to use for the hosted master network. This range will be used for assigning private IP addresses to the cluster master(s) and the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network, and it must be a /28 subnet."
}

variable "master_authorized_networks" {
  type        = map
  description = "External networks that can access the Kubernetes cluster master through HTTPS."
  default     = {}
}

variable "network_policy_enabled" {
  type        = bool
  description = "Whether network policy is enabled on the cluster."
  default     = false
}

variable "network_policy_provider" {
  type        = string
  description = "The selected network policy provider."
  default     = "PROVIDER_UNSPECIFIED"
}

variable "enable_legacy_abac" {
  type        = bool
  description = "Whether the ABAC authorizer is enabled for this cluster. When enabled, identities in the system, including service accounts, nodes, and controllers, will have statically granted permissions beyond those provided by the RBAC configuration or IAM."
  default     = false
}

variable "monitoring_service" {
  type        = string
  description = "The monitoring service that the cluster should write metrics to."
  default     = "none"
}

variable "logging_service" {
  type        = string
  description = "The logging service that the cluster should write logs to. "
  default     = "none"
}

variable "resource_labels" {
  type        = map
  description = "The GCE resource labels (a map of key/value pairs) to be applied to the cluster."
  default     = {}
}

variable "enable_secure_boot" {
  type        = bool
  description = "Defines if the instance has Secure Boot enabled"
  default     = false
}
variable "daily_maintenance_start_time" {
  type        = string
  description = "Cluster daily maintenance start time in RFC3339 date format."
  default     = "03:00"
}

variable "node_pools" {
  type        = any
  description = "The cluster nodes instances configuration. Defined as a map whick key defines the node name and value is a block following official documentation (https://www.terraform.io/docs/providers/google/r/container_node_pool.html) for these values => version, max_pods_per_node, machine_type, image_type, min_cpu_platform, preemptible, disk_type, disk_size_gb, local_ssd_count, guest_accelerator, oauth_scopes, taint, tags, labels, min_node_count, min_node_count, max_node_count, auto_repair, auto_upgrade"
  default     = {}
}
