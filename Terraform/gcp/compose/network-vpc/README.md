<!-- BEGIN_TF_DOCS -->
# Terraform compose module - server-dmz-rdp

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

## Resources

| Name                                                                                                                                               | Type        |
|----------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [google_compute_network.*](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network)                         | resource    | | resource    |
| [google_compute_firewall.*](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall)                       | resource    |

## Inputs

| Name                                                                 | Description                                        | Type      | Default                                                   | Required |
|----------------------------------------------------------------------|----------------------------------------------------|-----------|-----------------------------------------------------------|:--------:|

## Outputs

| Name | Description   |
|------|---------------|
| <a name="output_main_vpc_id"></a> [main_vpc_id](#output\_rdp_server_private_ip) | Main VPC ID.  |
| <a name="output_main_vpc_name"></a> [main_vpc_name](#output\_main_vpc_name) | Main VPC Name |

## Authors

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.

<!-- END_TF_DOCS -->