module "infra" {
  source = "./modules/infra"

  aks_resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  aks_network_plugin      = var.aks_network_plugin

  location = var.location

  aadpodidentity_chart_version    = var.aadpodidentity_chart_version
  aadpodidentity_chart_repository = var.aadpodidentity_chart_repository
  aadpodidentity_namespace        = var.aadpodidentity_namespace
  aadpodidentity_values           = var.aadpodidentity_values
  aadpodidentity_custom_name      = var.aadpodidentity_custom_name

  aadpodidentity_extra_tags = var.aadpodidentity_extra_tags
}
