[![Quortex][logo]](https://quortex.io)
# terraform-google-gke-cluster
A terraform module for Quortex infrastructure GKE cluster layer.

It provides a set of resources necessary to provision the Quortex infrastructure GKE cluster.

This module is available on [Terraform Registry][registry_tf_google_gke_cluster].

Get all our terraform modules on [Terraform Registry][registry_tf_modules] or on [Github][github_tf_modules] !

## Created resources

This module creates the following resources in GCP:

- a fully configurable GKE cluster
- a list of node pools to create in that cluster


## Usage example

```hcl
module "gke-cluster" {
  source  = "quortex/gke-cluster/google"

  # Globally used variables.
  project_id = module.network.project_id
  location   = "europe-west1-c"

  # Prevent resources conflicts for multiple workspaces usage.
  cluster_name = "quortex-${terraform.workspace}"

  network            = module.network.network
  subnetwork         = module.network.subnetwork
  pod_range_name     = module.network.pod_range_name
  svc_range_name     = module.network.svc_range_name
  master_cidr_block  = module.network.master_cidr_block
  min_master_version = "1.14.10-gke.27"
  node_pools = {
    main = {
      machine_type   = "custom-2-4096"
      min_node_count = 1
      max_node_count = 1
    },
    workflow-preemptive-group = {
      machine_type   = "n1-highcpu-16"
      min_node_count = 2
      max_node_count = 4
    }
  }

  # External networks that can access the Kubernetes cluster master through HTTPS.
  master_authorized_networks = {
    quortex  = "147.178.103.209/32"
  }
}
```

---

## Related Projects

This project is part of our terraform modules to provision a Quortex infrastructure for Google Cloud Platform.

![infra_gcp]

Check out these related projects.

- [terraform-google-network][registry_tf_google_network] - A terraform module for Quortex infrastructure network layer.

- [terraform-google-load-balancer][registry_tf_google_load_balancer] - A terraform module for Quortex infrastructure GCP load balancing layer.

- [terraform-google-storage][registry_tf_google_storage] - A terraform module for Quortex infrastructure GCP persistent storage layer.

## Help

**Got a question?**

File a GitHub [issue](https://github.com/quortex/terraform-google-gke-cluster/issues) or send us an [email][email].


  [logo]: https://storage.googleapis.com/quortex-assets/logo.webp
  [email]: mailto:info@quortex.io
  [infra_gcp]: https://storage.googleapis.com/quortex-assets/infra_gcp_002.jpg
  [registry_tf_modules]: https://registry.terraform.io/modules/quortex
  [registry_tf_google_network]: https://registry.terraform.io/modules/quortex/network/google
  [registry_tf_google_gke_cluster]: https://registry.terraform.io/modules/quortex/gke-cluster/google
  [registry_tf_google_load_balancer]: https://registry.terraform.io/modules/quortex/load-balancer/google
  [registry_tf_google_storage]: https://registry.terraform.io/modules/quortex/storage/google
  [github_tf_modules]: https://github.com/quortex?q=terraform-