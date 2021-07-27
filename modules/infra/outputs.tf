output "aad_pod_identity_namespace" {
  description = "Namespace used for AAD Pod Identity"
  value       = kubernetes_namespace.add_pod_identity.metadata[0].name
}

output "aad_pod_identity_azure_identity" {
  description = "Identity object for AAD Pod Identity"
  value       = azurerm_user_assigned_identity.aad_pod_identity
}

output "aad_pod_identity_id" {
  description = "ID of the User MSI used for AAD Pod Identity"
  value       = azurerm_user_assigned_identity.aad_pod_identity.id
}

output "aad_pod_identity_client_id" {
  description = "Client ID of the User MSI used for AAD Pod Identity"
  value       = azurerm_user_assigned_identity.aad_pod_identity.client_id
}

output "aad_pod_identity_principal_id" {
  description = "Principal ID of the User MSI used for AAD Pod Identity"
  value       = azurerm_user_assigned_identity.aad_pod_identity.principal_id
}
