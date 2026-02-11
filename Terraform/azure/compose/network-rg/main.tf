#-------------------------------
# VPC Network Resource
#-------------------------------
resource "azurerm_resource_group" "evocloud-rg" {
  name = var.AZ_PROJECT_ID
  location = "EAST US"

  tags = {
    environment = "prod"
    project     = var.AZ_PROJECT_ID
  }
}




