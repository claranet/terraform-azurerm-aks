data "azurerm_monitor_diagnostic_categories" "aks-diag-categories" {
  count       = var.enable_agic ? 1 : 0
  resource_id = azurerm_application_gateway.app_gateway.0.id
}

data "azurerm_subscription" "current" {
  count = var.enable_agic ? 1 : 0
}
