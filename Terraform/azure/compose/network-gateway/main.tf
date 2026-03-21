#--------------------------------------------------------------
# NAT Gateway Assoc
#--------------------------------------------------------------

#--------------------------------------------------------------
# Important SNAT Ports Knowledge
#--------------------------------------------------------------
# Each nat public ip gives you 64,512 SNAT ports
# shared across all VMs on all associated subnets.

# WARNING: When the pool runs dry, new outbound connections
# start failing,which can be tricky to debug since it looks
# like an intermittent network error.

# FIX: IF encountered, add more nat public ip addresses.
# Each one adds another 64,512 ports to the pool
#--------------------------------------------------------------

resource "azurerm_public_ip" "nat_pip" {
  name                = "evo-nat-pip"
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# ── NAT Gateway ───────────────────────────────────────────────────────────
resource "azurerm_nat_gateway" "nat-gateway" {
  name                    = "evo-nat-gateway"
  location                = var.rg_location
  resource_group_name     = var.rg_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}


# ── Associate Public IP to NAT Gateway ───────────────────────────────────
resource "azurerm_nat_gateway_public_ip_association" "evo-nat-pip-assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat-gateway.id
  public_ip_address_id = azurerm_public_ip.nat_pip.id
}

# ── Associate NAT Gateway to subnets ─────────────────────────────────────
resource "azurerm_subnet_nat_gateway_association" "all" {
  for_each = {
    admin_subnet   = var.admin_subnet_id
    backend_subnet = var.backend_subnet_id
    dmz_subnet     = var.dmz_subnet_id
  }
  subnet_id      = each.value
  nat_gateway_id = azurerm_nat_gateway.nat-gateway.id
}
