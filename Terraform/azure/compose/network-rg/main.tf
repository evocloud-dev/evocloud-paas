#-------------------------------------------
# VPC Resource Group and Virtual Network
#-------------------------------------------
resource "azurerm_resource_group" "evocloud-deploy-rg" {
  name = var.AZ_DEPLOY_RG
  location = var.AZ_REGION

  tags = {
    environment = "prod"
    project     = var.AZ_PROJECT_ID
  }
}

resource "azurerm_virtual_network" "main" {
  #location            = azurerm_resource_group.evocloud-rg.location
  name                = "main"
  location            = azurerm_resource_group.evocloud-deploy-rg.location
  resource_group_name = azurerm_resource_group.evocloud-deploy-rg.name
  address_space       = [var.AZ_VPC_CIDR]
}


