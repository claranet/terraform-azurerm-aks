data "azurerm_subscription" "current" {
  count = var.enable_agic ? 1 : 0
}

data "azurerm_resource_group" "resource_group" {
  count = var.enable_agic ? 1 : 0
  name  = var.resource_group_name
}
