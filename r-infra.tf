module "infra" {
  source = "./modules/infra"

  providers = {
    kubernetes = kubernetes.aks-module
    helm       = helm.aks-module
  }

  aks_resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  location                = var.location

  aadpodidentity_chart_version    = var.aadpodidentity_chart_version
  aadpodidentity_chart_repository = var.aadpodidentity_chart_repository
  aadpodidentity_namespace        = var.aadpodidentity_namespace
  aadpodidentity_values           = var.aadpodidentity_values
}
