<!-- BEGIN_TF_DOCS -->
# Terraform compose module - network-gateway

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

## Resources

| Name                                                                                                                                               | Type        |
|----------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [google_compute_router.*](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router)                         | resource    | | resource    |
| [google_compute_router_nat.*](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat)                       | resource    |

## Inputs

| Name                                                                 | Description                                        | Type      | Default                                                   | Required |
|----------------------------------------------------------------------|----------------------------------------------------|-----------|-----------------------------------------------------------|:--------:|

## Outputs

| Name | Description       |
|------|-------------------|
| <a name="output_vpc_gateway_name"></a> [vpc_gateway_name](#output\_vpc_gateway_name) | VPC Gateway Name. |
| <a name="output_vpc_gateway_id"></a> [vpc_gateway_id](#output\_vpc_gateway_id) | VPC Gateway ID    |
| <a name="output_vpc_nat_gateway_name"></a> [vpc_nat_gateway_name](#output\_vpc_nat_gateway_name) | VPC NAT Gateway name    |
| <a name="output_vpc_nat_gateway_id"></a> [vpc_nat_gateway_id](#output\_vpc_nat_gateway_id) | VPC NAT Gateway ID    |

## Authors

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.

<!-- END_TF_DOCS -->