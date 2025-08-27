<!-- BEGIN_TF_DOCS -->
# Terraform compose module - server-dmz-vdc

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
| <a name="depedencies_network-subnet"></a> [network-subnet](#dependencies\_network-subnet)            | compose/network-subnet | terraform module |
| <a name="dependencies_server-dmz-deployer"></a> [server-dmz-deployer](#dependencies\_dmz-deployer)          | compose/server-dmz-rdp  | terraform module |
| <a name="dependencies_server-admin-idam"></a> [server-admin-idam](#dependencies\_server-admin-idam]) | compose/server-admin-idam | terraform module |
| <a name="dependencies_server-admin-idam_replica"></a> [server-admin-idam_replica](#dependencies\_server-admin-idam_replica])   | compose/server-admin-idam_replica | terraform module |

## Resources

| Name                                                                                                                                               | Type        |
|----------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [google_compute_address.*](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address)                         | resource    | | resource    |
| [google_compute_instance.*](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)                       | resource    |
| [terraform_data.*](https://developer.hashicorp.com/terraform/language/resources/terraform-data)                                                    | resource    |

## Inputs

| Name                                                                 | Description                                        | Type      | Default                                                   | Required |
|----------------------------------------------------------------------|----------------------------------------------------|-----------|-----------------------------------------------------------|:--------:|
| <a name="input_dmz_subnet_name"></a> [dmz_subnet_name](#input\_input_dmz_subnet_name) | Name of the admin subnet                           | `string`  | `dependency.network-subnet.outputs.dmz_subnet_name`     |   yes    |
| <a name="input_deployer_server_eip"></a> [deployer_server_eip](#input\_deployer_server_eip) | Public IP of the deployment VM                     | `string`  | `dependency.server-dmz-deployer.outputs.public_ip`        |   yes    |
| <a name="input_idam_server_ip"></a> [idam_server_ip](#input\_idam_server_ip) | Private IP of the Identity Provider VM             | `string`  | `dependency.server-admin-idam.outputs.private_ip`         |   yes    |
| <a name="input_idam_replica_ip"></a> [idam_replica_ip](#input\_idam_replica_ip) | Public IP of the Identity Provider replica VM      | `string`  | `dependency.server-admin-idam_replica.outputs.private_ip` |   yes    |
| <a name="input_rdp_revision"></a> [rdp_revision](#input\_rdp_revision) | RDP Deployment Revision   | `string` | `0.1.0`                                                    |   yes    |

## Outputs

| Name | Description                                  |
|------|----------------------------------------------|
| <a name="output_rdp_server_private_ip"></a> [rdp_server_private_ip](#output\_rdp_server_private_ip) | RDP Private IP Address.                    |
| <a name="output_rdp_server_public_ip"></a> [rdp_server_public_ip](#output\_rdp_server_public_ip) | RDP Public IP Address     |

## Authors

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.

<!-- END_TF_DOCS -->