output "namespace" {
  description = "Namespace used for Velero"
  value       = try(kubernetes_namespace.velero[0].metadata[0].name, "")
}

output "storage_account" {
  description = "Storage Account on which Velero data is stored."
  value       = azurerm_storage_account.velero
}

output "storage_account_container" {
  description = "Container in Storage Account on which Velero data is stored."
  value       = azurerm_storage_container.velero
}

output "velero_identity" {
  description = "Azure Identity used for Velero pods"
  value       = azurerm_user_assigned_identity.velero_identity
}
