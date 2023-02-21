data "azurerm_subscription" "current" {}

data "azurerm_virtual_network" "aks_vnet" {
  count = local.is_custom_dns_private_cluster ? 1 : 0

  name                = reverse(split("/", var.vnet_id))[0]
  resource_group_name = split("/", var.vnet_id)[4]
}
