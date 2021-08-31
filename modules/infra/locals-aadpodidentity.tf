locals {
  aadpodidentity_default_values = {
    "azureIdentity.enabled"     = "true"
    "azureIdentity.type"        = "0"
    "azureIdentity.resourceID"  = azurerm_user_assigned_identity.aad_pod_identity.id
    "azureIdentity.clientID"    = azurerm_user_assigned_identity.aad_pod_identity.client_id
    "nmi.micNamespace"          = kubernetes_namespace.add_pod_identity.metadata[0].name
    "rbac.allowAccessToSecrets" = "false"
  }

  aadpodidentity_values = merge(local.aadpodidentity_default_values, var.aadpodidentity_values)
}
