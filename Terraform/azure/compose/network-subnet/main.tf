#--------------------------------------------------
# Subnets
#--------------------------------------------------

resource "azurerm_subnet" "admin-subnet" {
  address_prefixes = [var.ADMIN_SUBNET_CIDR]
  name                 = "admin-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = var.vnet_name
}

resource "azurerm_subnet" "backend-subnet" {
  address_prefixes = [var.BACKEND_SUBNET_CIDR]
  name                 = "backend-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = var.vnet_name
}

resource "azurerm_subnet" "dmz-subnet" {
  address_prefixes = [var.DMZ_SUBNET_CIDR]
  name                 = "dmz-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = var.vnet_name
}
