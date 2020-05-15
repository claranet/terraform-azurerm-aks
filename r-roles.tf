data "azurerm_resource_group" "main_rg" {
  name = var.resource_group_name
}

data "azurerm_resource_group" "nodes_rg" {
  name = azurerm_kubernetes_cluster.aks.node_resource_group
}

resource "azurerm_role_assignment" "cluster_admin" {
  principal_id         = var.service_principal.object_id
  scope                = data.azurerm_resource_group.main_rg.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
}

resource "azurerm_role_assignment" "acr" {
  count                = length(var.container_registries)
  principal_id         = var.service_principal.object_id
  scope                = var.container_registries[count.index]
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "subnet" {
  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = var.service_principal.object_id
}

resource "azurerm_role_assignment" "storage" {
  count        = length(var.storage_contributor)
  principal_id = var.service_principal.object_id
  scope        = var.storage_contributor[count.index]
}

resource "azurerm_role_assignment" "msi" {
  count        = length(var.managed_identities)
  principal_id = var.service_principal.object_id
  scope        = var.managed_identities[count.index]
}

