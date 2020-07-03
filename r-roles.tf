resource "azurerm_role_assignment" "cluster_admin" {
  principal_id         = var.service_principal.object_id
  scope                = data.azurerm_resource_group.aks_rg.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
}

resource "azurerm_role_assignment" "acr" {
  count                = length(var.container_registries)
  principal_id         = var.service_principal.object_id
  scope                = var.container_registries[count.index]
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "subnet" {
  scope                = join("/", slice(split("/", var.nodes_subnet_id), 0, 9))
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

