module "infra" {
  source = "./modules/infra"
  providers = {
    kubernetes = kubernetes.aks-module
    helm       = helm.aks-module
  }

  resource_group_name     = var.resource_group_name
  resource_group_id       = data.azurerm_resource_group.aks_rg.id
  aks_resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  aks_resource_group_id   = format("/subscriptions/%s/resourceGroups/%s", "${data.azurerm_subscription.current.subscription_id}", azurerm_kubernetes_cluster.aks.node_resource_group)
  location                = var.location

  aadpodidentity_chart_version    = var.aadpodidentity_chart_version
  aadpodidentity_chart_repository = var.aadpodidentity_chart_repository
  aadpodidentity_namespace        = var.aadpodidentity_namespace
  aadpodidentity_values           = var.aadpodidentity_values
}
