#--------------------------------------------------
# Single Node Cluster
#--------------------------------------------------
data "azurerm_image" "rocky-linux" {
  name                = var.TALOS_AMI_NAME
  resource_group_name = var.AZ_STORAGE_RG
}