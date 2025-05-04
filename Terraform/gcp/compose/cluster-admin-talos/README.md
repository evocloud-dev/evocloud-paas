<!-- BEGIN_TF_DOCS -->
# Terraform compose module - cluster-admin-talos

## Requirements

| Name                                                                        | Version   |
|-----------------------------------------------------------------------------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform)   | ~> 1.3    |
| <a name="requirement_terragrunt"></a> [terragrunt](#requirement\_terraform) | ~> 0.45.0 |
| <a name="requirement_google"></a> [google](#requirement\_google)            | ~> 5.0    |
| <a name="requirement_talos"></a> [talos](#requirement\_talos)               | 0.7.0     |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.45.0 |
| <a name="provider_talos"></a> [talos](#provider\_talos) | 0.7.0 |

## Dependencies

| Name                                                                                                 | Source                | Type             |
|------------------------------------------------------------------------------------------------------|-----------------------|------------------|
| <a name="depedencies_network-subnet"></a> [network-subnet](#dependencies\_network-subnet)            | compose/network-subnet | terraform module |
| <a name="dependencies_server-dmz-deployer"></a> [dmz-deployer](#dependencies\_dmz-deployer)          | compose/dmz-deployer  | terraform module |
| <a name="dependencies_server-admin-idam"></a> [server-admin-idam](#dependencies\_server-admin-idam]) | compose/server-admin-idam | terraform module |
| <a name="dependencies_server-admin-idam_replica"></a> [server-admin-idam_replica](#dependencies\_server-admin-idam_replica])   | compose/server-admin-idam_replica | terraform module |

## Resources

| Name                                                                                                                                               | Type        |
|----------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [google_compute_image.*](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_image)                             | resource    |
| [google_compute_address.*](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address)                         | resource    | | resource    |
| [random_integer.*](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer)                                         | resource    |
| [google_compute_instance.*](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)                       | resource    |
| [terraform_data.*](https://developer.hashicorp.com/terraform/language/resources/terraform-data)                                                    | resource    |
| [google_compute_disk.*](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk)                               | resource    |
| [google_compute_attached_disk.*](https://registry.terraform.io/providers/hashicorp/google/3.29.0/docs/resources/compute_attached_disk)             | resource    |
| [talos_machine_secrets.*](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_secrets)                          | resource    |
| [talos_client_configuration.*](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/client_configuration)             | data source |
| [talos_machine_configuration.*](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/machine_configuration)           | data source |
| [talos_machine_configuration_apply.*](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_configuration_apply)  | resource    |
| [talos_machine_bootstrap.*](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_bootstrap)                      | resource    |
| [talos_cluster_health.*](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/cluster_health)                         | data source |
| [talos_cluster_kubeconfig.*](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/cluster_kubeconfig)                    | resource    |

## Inputs

| Name                                                                 | Description                                        | Type      | Default                                                   | Required |
|----------------------------------------------------------------------|----------------------------------------------------|-----------|-----------------------------------------------------------|:--------:|
| <a name="input_admin_subnet_name"></a> [admin_subnet_name](#input\_input_admin_subnet_name) | Name of the admin subnet                           | `string`  | `dependency.network-subnet.outputs.admin_subnet_name`     |   yes    |
| <a name="input_deployer_server_eip"></a> [deployer_server_eip](#input\_deployer_server_eip) | Public IP of the deployment VM                     | `string`  | `dependency.server-dmz-deployer.outputs.public_ip`        |   yes    |
| <a name="input_idam_server_ip"></a> [idam_server_ip](#input\_idam_server_ip) | Private IP of the Identity Provider VM             | `string`  | `dependency.server-admin-idam.outputs.private_ip`         |   yes    |
| <a name="input_idam_replica_ip"></a> [idam_replica_ip](#input\_idam_replica_ip) | Public IP of the Identity Provider replica VM      | `string`  | `dependency.server-admin-idam_replica.outputs.private_ip` |   yes    |
| <a name="input_cluster_name"></a> [cluster_name](#input\_cluster_name) | Talos Kubernetes Cluster Name                      | `string`  | `"evotalos-alpha-cluster"`                                |   yes    |
| <a name="input_talos_version"></a> [talos_version](#input\_talos_version) | Talos OS version                                   | `string`  | `"v1.9.2"`                                                |   yes    |
| <a name="input_kubernetes_version"></a> [kubernetes_version](#input\_kubernetes_version) | Kubernetes version                                 | `string`  | `"v1.32.1"`                                               |   yes    |
| <a name="input_taloslb_revision"></a> [taloslb_revision](#input\_taloslb_revision) | Talos Load balancer configuration revision version | `string`  | `"0.1.0"k`                                                |   yes    |
| <a name="input_taloslb_revision"></a> [create_talos_img](#input\_create_talos_img) | Boolean value to create Talos OS Image if needed   | `boolean` | `true`                                                    |   yes    |

## Outputs

| Name                                                                                                       | Description                                  |
|------------------------------------------------------------------------------------------------------------|----------------------------------------------|
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig)                                         | The generated kubeconfig.                    |
| <a name="output_talos_client_configuration"></a> [talos_client_configuration](#output\_talos_client_configuration) | The generated Talos client configuration     |
| <a name="output_talosconfig"></a> [talosconfig](#output\_talosconfig)                                      | The generated Talos configuration            |
| <a name="output_talos_controlplane_config"></a> [talosconfig](#output\_talos_controlplane_config)          | The generated Talos contol plane configuration |
| <a name="output_talos_worker_config"></a> [kubeconfig](#output\_talos_worker_config)                       | The generated Talos worker plane configuration |
| <a name="output_talos_vip"></a> [talosconfig](#output\_talos_vip)                                          | The Talos virtual ip address                 |

## Authors

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.

<!-- END_TF_DOCS -->