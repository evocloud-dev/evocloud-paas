<!-- BEGIN_TF_DOCS -->
# Terraform compose module - kubeapp-flux

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

| Name                                                                                                                                  | Source                               | Type             |
|---------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------|------------------|
| <a name="dependencies_server-dmz-deployer"></a> [dmz-deployer](#dependencies\_dmz-deployer)                                           | compose/dmz-deployer                 | terraform module |
| <a name="dependencies_server-backend-evocode"></a> [server-backend-evocode](#dependencies\_server-backend-evocode])                   | compose/server-backend-evocode       | terraform module |
| <a name="dependencies_server-backend-evocode-group"></a> [server-backend-evocode-group](#dependencies\_server-backend-evocode-group]) | compose/server-backend-evocode-group | terraform module |

## Resources

| Name                                                                                                                                               | Type        |
|----------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [terraform_data.*](https://developer.hashicorp.com/terraform/language/resources/terraform-data)                                                    | resource    |

## Inputs

| Name                                                           | Description                                                                                                     | Type     | Default                 |                             Required                             |
|----------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|----------|-------------------------|:----------------------------------------------------------------:|
| <a name="input_deployer_server_eip"></a> [deployer_server_eip](#input\_deployer_server_eip) | Public IP of the deployment VM                                                                                  | `string` | `dependency.server-dmz-deployer.outputs.public_ip` |                               yes                                |
| <a name="input_evocode_private_ip"></a> [evocode_private_ip](#input\_evocode_private_ip) | Evocode Server Private IP Address                                                                               | `string` | `dependency.server-backend-evocode.outputs.private_ip` |                               yes                                |
| <a name="input_fluxcd_repo_group"></a> [fluxcd_repo_group](#input\_fluxcd_repo_group) | Project Group Name in Evocode/Gitlab                                                                            | `string` | `evosystems` |           yes and must match a group in Evocode/Gitlab           |
| <a name="input_fluxcd_git_repo"></a> [fluxcd_git_repo](#input\_input_fluxcd_git_repo) | Name of the Project or Repository in Evocode/Gitlab                                                             | `string` | `evocloud` | yes  and must be a valid project or repository in Evocode/Gitlab |
| <a name="input_fluxcd_repo_dir"></a> [fluxcd_repo_dir](#input\_fluxcd_repo_dir) | Directory path to store flux deployment manifests. Relative path to the Project or Repository in Evocode/Gitlab | `string` | `Gitops/k8s-clusters/cluster-mgr02"`                 |                               yes                                |

## Outputs

| Name | Description                                    |
|------|------------------------------------------------|

## Authors

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.

<!-- END_TF_DOCS -->