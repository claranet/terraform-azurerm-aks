module "infra" {
  source = "./modules/infra"
  providers = {
    kubernetes = kubernetes.aks-module
    helm       = helm.aks-module
  }

  resource_group_name     = var.resource_group_name
  resource_group_id       = var.resource_group_id
  aks_resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  aks_resource_group_id   = data.azurerm_resource_group.aks_nodes_rg.id
  location                = var.location

  aadpodidentity_chart_version = var.aadpodidentity_chart_version
  aadpodidentity_namespace     = var.aadpodidentity_namespace
  aadpodidentity_values        = var.aadpodidentity_values

}