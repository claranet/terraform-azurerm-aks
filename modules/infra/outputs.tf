output "aad_pod_identity_id" {
  value = azurerm_user_assigned_identity.aad_pod_identity.id
}

output "aad_pod_identity_client_id" {
  value = azurerm_user_assigned_identity.aad_pod_identity.client_id
}

output "add_pod_identity_principal_id" {
  value = azurerm_user_assigned_identity.aad_pod_identity.principal_id
}