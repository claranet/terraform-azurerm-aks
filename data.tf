data "azurerm_subscription" "current" {}

data "azurerm_monitor_diagnostic_categories" "aks_diag_categories" {
  resource_id = azurerm_kubernetes_cluster.aks.id
}

data "azurerm_resource_group" "aks_rg" {
  name = var.resource_group_name
}
