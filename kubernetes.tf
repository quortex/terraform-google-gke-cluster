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

# The Quortex GKE cluster.
resource "google_container_cluster" "quortex" {

  # The name of the cluster, unique within the project and location.
  name = var.cluster_name

  # The location in which to create the cluster (set zone for zonal cluster and region for regional one).
  location = var.location

  # Description of the cluster.
  description = var.cluster_description

  #  The minimum version of the master. GKE will auto-update the master to new versions, so this does not guarantee the current master version.
  min_master_version = var.min_master_version

  # The name or self_link of the Google Compute Engine network to which the cluster is connected.
  network = var.network
  # The name or self_link of the Google Compute Engine subnetwork in which the cluster's instances are launched.
  subnetwork = var.subnetwork

  ip_allocation_policy {
    # The name of the existing secondary range in the cluster's subnetwork to use for pod IP addresses.
    cluster_secondary_range_name = var.pod_range_name
    # The name of the existing secondary range in the cluster's subnetwork to use for service ClusterIPs.
    services_secondary_range_name = var.svc_range_name
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool ...
  initial_node_count = 1

  # ... and immediately delete it.
  remove_default_node_pool = true

  # The default maximum number of pods per node in this cluster.
  default_max_pods_per_node = var.default_max_pods_per_node

  node_config {
      shielded_instance_config{
      enable_secure_boot= var.enable_secure_boot
    }
  }

  # The authentication information for accessing the Kubernetes master.
  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""

    # Whether client certificate authorization is enabled for this cluster.
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  private_cluster_config {
    # Either endpoint can be used.
    enable_private_endpoint = false
    # Enables the private cluster feature, creating a private endpoint on the cluster.
    enable_private_nodes = true
    # The IP range in CIDR notation to use for the hosted master network.
    # This range will be used for assigning private IP addresses to the cluster master(s) and the ILB VIP.
    # This range must not overlap with any other ranges in use within the cluster's network, and it must be a /28 subnet.
    master_ipv4_cidr_block = var.master_cidr_block
  }

  # The authentication information for accessing the Kubernetes master.
  master_authorized_networks_config {
    # External networks that can access the Kubernetes cluster master through HTTPS.
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks

      content {
        display_name = cidr_blocks.key
        cidr_block   = cidr_blocks.value
      }
    }
  }

  # Whether the ABAC authorizer is enabled for this cluster.
  # When enabled, identities in the system, including service accounts, nodes, and controllers, will have statically granted permissions beyond those provided by the RBAC configuration or IAM.
  enable_legacy_abac = var.enable_legacy_abac

  network_policy {
    enabled  = var.network_policy_enabled
    provider = var.network_policy_provider
  }

  # The configuration for addons supported by GKE.
  addons_config {

    # http load balancing required to work with Network Endpoints Groups
    # https://cloud.google.com/kubernetes-engine/docs/how-to/standalone-neg?hl=fr
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = true
    }
  }

  # The monitoring service that the cluster should write metrics to.
  monitoring_service = var.monitoring_service
  # The logging service that the cluster should write logs to.
  logging_service = var.logging_service

  # The GCE resource labels (a map of key/value pairs) to be applied to the cluster.
  resource_labels = var.resource_labels

  # The maintenance policy to use for the cluster.
  maintenance_policy {
    daily_maintenance_window {
      # Cluster daily maintenance start time in RFC3339 date format.
      start_time = var.daily_maintenance_start_time
    }
  }
}

# The cluster's node pools definitions.
resource "google_container_node_pool" "quortex" {
  for_each = var.node_pools

  # The name of the node pool.
  name = each.key

  # The location (region or zone) of the cluster.
  location = google_container_cluster.quortex.location
  cluster  = google_container_cluster.quortex.name

  # The Kubernetes version for the nodes in this pool.
  version = lookup(each.value, "version", "")

  # The maximum number of pods per node in this node pool.
  # Note that this does not work on node pools which are "route-based" - that is, node pools belonging to clusters that do not have IP Aliasing enabled.
  # See the official documentation for more information.
  max_pods_per_node = lookup(each.value, "max_pods_per_node", var.default_max_pods_per_node)

  node_config {

    shielded_instance_config{
    enable_secure_boot= var.enable_secure_boot
  }

    # The name of a Google Compute Engine machine type.
    machine_type = lookup(each.value, "machine_type", "n1-standard-1")

    # The image type to use for this node. Note that changing the image type will delete and recreate all nodes in the node pool.
    image_type = lookup(each.value, "image_type", "COS")

    # Minimum CPU platform to be used by this instance.
    # The instance may be scheduled on the specified or newer CPU platform.
    min_cpu_platform = lookup(each.value, "min_cpu_platform", "")

    # A boolean that represents whether or not the underlying node VMs are preemptible.
    preemptible = lookup(each.value, "preemptible", false)

    # Type of the disk attached to each node (e.g. 'pd-standard' or 'pd-ssd').
    disk_type = lookup(each.value, "disk_type", "pd-standard")

    # Size of the disk attached to each node, specified in GB. The smallest allowed disk size is 10GB.
    disk_size_gb = lookup(each.value, "disk_size_gb", 100)

    # The amount of local SSD disks that will be attached to each cluster node.
    local_ssd_count = lookup(each.value, "local_ssd_count", 0)

    # List of the type and count of accelerator cards attached to the instance.
    guest_accelerator = lookup(each.value, "guest_accelerator", [])

    # The set of Google API scopes to be made available on all of the node VMs under the "default" service account.
    # These can be either FQDNs, or scope aliases. The following scopes are necessary to ensure the correct functioning of the cluster:
    # storage-ro (https://www.googleapis.com/auth/devstorage.read_only), if the cluster must read private images from GCR. Note this will grant read access to ALL GCS content unless you also specify a custom role. See https://cloud.google.com/kubernetes-engine/docs/how-to/access-scopes
    # logging-write (https://www.googleapis.com/auth/logging.write), if logging_service is not none.
    # monitoring (https://www.googleapis.com/auth/monitoring), if monitoring_service is not none.
    oauth_scopes = lookup(each.value, "oauth_scopes", ["https://www.googleapis.com/auth/monitoring.write"])

    # A list of Kubernetes taints to apply to nodes. GKE's API can only set this field on cluster creation.
    # Taint values can be updated safely in Kubernetes (eg. through kubectl), and it's recommended that you do not use this field to manage taints.
    #     The taint block supports:
    #       key (Required) Key for taint.
    #       value (Required) Value for taint.
    #       effect (Required) Effect for taint. Accepted values are NO_SCHEDULE, PREFER_NO_SCHEDULE, and NO_EXECUTE.
    taint = lookup(each.value, "taint", null)

    # The metadata key/value pairs assigned to instances in the cluster.
    metadata = {
      disable-legacy-endpoints = "true"
    }


    # The list of instance tags applied to all nodes. Tags are used to identify valid sources or targets for network firewalls.
    tags = lookup(each.value, "tags", [])

    # The Kubernetes labels (key/value pairs) to be applied to each node.
    labels = lookup(each.value, "labels", {})
  }

  # Initial node count equal to minimum node count.
  initial_node_count = lookup(each.value, "min_node_count", 1)

  # Configuration required by cluster autoscaler to adjust the size of the node pool to the current cluster usage.
  autoscaling {
    # Minimum number of nodes in the NodePool. Must be >=0 and <= max_node_count.
    min_node_count = lookup(each.value, "min_node_count", 1)
    # Maximum number of nodes in the NodePool. Must be >= min_node_count.
    max_node_count = lookup(each.value, "max_node_count", 1)
  }

  management {
    # Whether the nodes will be automatically repaired.
    auto_repair = lookup(each.value, "auto_repair", true)
    # Whether the nodes will be automatically upgraded.
    auto_upgrade = lookup(each.value, "auto_upgrade", true)
  }

  lifecycle {
    ignore_changes = [node_config[0].taint]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}
