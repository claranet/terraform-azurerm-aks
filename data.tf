data "azurerm_subscription" "current" {}

data "azurerm_monitor_diagnostic_categories" "aks-diag-categories" {
  resource_id = azurerm_kubernetes_cluster.aks.id
}

data "azurerm_resource_group" "aks_nodes_rg" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  name       = azurerm_kubernetes_cluster.aks.node_resource_group
}

data "azurerm_resource_group" "aks_rg" {
  name = var.resource_group_name
}