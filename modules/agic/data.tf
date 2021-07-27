data "azurerm_monitor_diagnostic_categories" "aks_diag_categories" {
  count       = var.enable_agic ? 1 : 0
  resource_id = azurerm_application_gateway.app_gateway.0.id
}

data "azurerm_subscription" "current" {
  count = var.enable_agic ? 1 : 0
}

data "azurerm_resource_group" "resource_group" {
  count = var.enable_agic ? 1 : 0
  name  = var.resource_group_name
}
