data "azurerm_subscription" "current" {
  count = var.agic_enabled ? 1 : 0
}

data "azurerm_resource_group" "resource_group" {
  count = var.agic_enabled ? 1 : 0
  name  = var.resource_group_name
}
