<!-- BEGIN_TF_DOCS -->
# Terraform compose module - server-backend-evoharbor

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

| Name                                                                                                                         | Source                            | Type             |
|------------------------------------------------------------------------------------------------------------------------------|-----------------------------------|------------------|
| <a name="depedencies_network-subnet"></a> [network-subnet](#dependencies\_network-subnet)                                    | compose/network-subnet            | terraform module |
| <a name="dependencies_server-dmz-deployer"></a> [dmz-deployer](#dependencies\_dmz-deployer)                                  | compose/dmz-deployer              | terraform module |
| <a name="dependencies_server-admin-idam"></a> [server-admin-idam](#dependencies\_server-admin-idam])                         | compose/server-admin-idam         | terraform module |
| <a name="dependencies_server-admin-idam_replica"></a> [server-admin-idam_replica](#dependencies\_server-admin-idam_replica]) | compose/server-admin-idam_replica | terraform module |
| <a name="dependencies_server-backend-evoharbor"></a> [server-backend-evoharbor](#dependencies\_server-backend-evoharbor])    | compose/server-backend-evoharbor  | terraform module |

## Resources

| Name                                                                                                                                               | Type        |
|----------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [terraform_data.*](https://developer.hashicorp.com/terraform/language/resources/terraform-data)                                                    | resource    |

## Inputs

| Name                                                                                              | Description                                       | Type     | Default | Required |
|---------------------------------------------------------------------------------------------------|---------------------------------------------------|----------|----|:--------:|
| <a name="input_backend_subnet_name"></a> [backend_subnet_name](#input\_input_backend_subnet_name) | Name of the backend subnet                        | `string` | `dependency.network-subnet.outputs.backend_subnet_name` |   yes    |
| <a name="input_deployer_server_eip"></a> [deployer_server_eip](#input\_deployer_server_eip)       | Public IP of the deployment VM                    | `string` | `dependency.server-dmz-deployer.outputs.public_ip` |   yes    |
| <a name="input_idam_server_ip"></a> [idam_server_ip](#input\_idam_server_ip)                      | Private IP of the Identity Provider VM            | `string` | `dependency.server-admin-idam.outputs.private_ip` |   yes    |
| <a name="input_idam_replica_ip"></a> [idam_replica_ip](#input\_idam_replica_ip)                   | Public IP of the Identity Provider replica VM     | `string` | `dependency.server-admin-idam_replica.outputs.private_ip` |   yes    |
| <a name="evoharbor_revision"></a> [evoharbor_revision](#input\_runner_registration_revision)      | EvoHarbor revision | `string` | `0.1.0` |   yes    |

## Outputs

| Name | Description                                |
|------|--------------------------------------------|

## Authors

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.

<!-- END_TF_DOCS -->