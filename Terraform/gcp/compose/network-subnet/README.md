<!-- BEGIN_TF_DOCS -->
# Terraform compose module - network-subnet

## Requirements

| Name                                                                        | Version   |
|-----------------------------------------------------------------------------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform)   | ~> 1.3    |
| <a name="requirement_terragrunt"></a> [terragrunt](#requirement\_terraform) | ~> 0.45.0 |
| <a name="requirement_google"></a> [google](#requirement\_google)            | ~> 5.0    |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.45.0 |

## Dependencies

| Name                                                                                                 | Source                | Type             |
|------------------------------------------------------------------------------------------------------|-----------------------|------------------|
| <a name="depedencies_network-vpc"></a> [network-vpc](#dependencies\_network-vpc)            | compose/network-subnet | terraform module |

## Resources

| Name                                                                                                                                               | Type        |
|----------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [google_compute_subnetwork.*](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork)                         | resource    | | resource    |

## Inputs

| Name                                                                 | Description                                        | Type      | Default                                                   | Required |
|----------------------------------------------------------------------|----------------------------------------------------|-----------|-----------------------------------------------------------|:--------:|

## Outputs

| Name                                                                                             | Description      |
|--------------------------------------------------------------------------------------------------|------------------|
| <a name="output_dmz_subnet_name"></a> [dmz_subnet_name](#output\_dmz_subnet_name)                | DMZ Subnet Name. |
| <a name="output_dmz_subnet_id"></a> [dmz_subnet_id](#output\_dmz_subnet_id) | DMZ Subnet ID    |
| <a name="output_admin_subnet_name"></a> [admin_subnet_name](#output\_admin_subnet_name) | Admin Subnet Name    |
| <a name="output_admin_subnet_id"></a> [admin_subnet_id](#output\_admin_subnet_id) | Admin Subnet ID    |
| <a name="output_backend_subnet_name"></a> [backend_subnet_name](#output\_backend_subnet_name) | Backend Subnet Name    |
| <a name="output_backend_subnet_id"></a> [backend_subnet_id](#output\_backend_subnet_id) | Backend Subnet ID    |


## Authors

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.

<!-- END_TF_DOCS -->