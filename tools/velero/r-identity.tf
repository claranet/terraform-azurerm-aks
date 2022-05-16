data "azurerm_resource_group" "aks_nodes_rg" {
  count = var.enable_velero ? 1 : 0
  name  = var.aks_nodes_resource_group_name
}

resource "azurerm_user_assigned_identity" "velero_identity" {
  count               = var.enable_velero ? 1 : 0
  location            = var.location
  name                = local.velero_identity_name
  resource_group_name = var.aks_nodes_resource_group_name

  tags = var.velero_identity_tags
}

resource "azurerm_role_assignment" "velero_identity_role_aks" {
  count                = var.enable_velero ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.velero_identity[0].principal_id
  scope                = try(data.azurerm_resource_group.aks_nodes_rg[0].id, "")
  role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "velero_identity_role_storage" {
  count                = var.enable_velero ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.velero_identity[0].principal_id
  scope                = azurerm_storage_account.velero[0].id
  role_definition_name = "Contributor"
}

resource "helm_release" "velero_identity" {
  depends_on = [helm_release.velero]
  count      = var.enable_velero ? 1 : 0
  chart      = "${path.module}/aad-bindings"
  name       = "velero-aad-bindings"
  namespace  = kubernetes_namespace.velero[0].metadata[0].name

  set {
    name  = "IdentityName"
    value = azurerm_user_assigned_identity.velero_identity[0].name
  }

  set {
    name  = "IdentityID"
    value = azurerm_user_assigned_identity.velero_identity[0].id
  }

  set {
    name  = "IdentityClientID"
    value = azurerm_user_assigned_identity.velero_identity[0].client_id
  }
}
