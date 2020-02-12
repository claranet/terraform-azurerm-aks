data "azurerm_subscription" "current" {}

data "azurerm_monitor_diagnostic_categories" "aks-diag-categories" {
  resource_id = azurerm_kubernetes_cluster.aks.id
}