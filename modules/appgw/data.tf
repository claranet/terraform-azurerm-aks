data "azurerm_monitor_diagnostic_categories" "aks-diag-categories" {
  resource_id = azurerm_application_gateway.app_gateway.id
}