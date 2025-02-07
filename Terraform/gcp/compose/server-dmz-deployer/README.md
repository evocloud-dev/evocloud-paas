<!-- BEGIN_TF_DOCS -->
# Terraform compose module - server-dmz-deployer

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

| Name                                                                                                       | Source                            | Type             |
|------------------------------------------------------------------------------------------------------------|-----------------------------------|------------------|
| <a name="depedencies_network-subnet"></a> [network-subnet](#dependencies\_network-subnet)                  | compose/network-subnet            | terraform module |
| <a name="dependencies_network-routing"></a> [network-routing](#dependencies\_network-gateway)              | compose/network-gateway           | terraform module |
| <a name="dependencies_server-dmz-deployer"></a> [server-dmz-deployer](#dependencies\_server-dmz-deployer]) | compose/server-dmz-deployer         | terraform module |

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
| <a name="input_deployer_revision"></a> [deployer_revision](#input\_deployer_revision) | RDP Deployment Revision   | `string` | `0.1.0`                                                    |   yes    |

## Outputs

| Name | Description                          |
|------|--------------------------------------|
| <a name="output_private_ip"></a> [private_ip](#output\_private_ip) | Deployer Servier Private IP Address. |
| <a name="output_public_ip"></a> [public_ip](#output\_public_ip) | Deployer Server Public IP Address    |

## Authors

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.

<!-- END_TF_DOCS -->