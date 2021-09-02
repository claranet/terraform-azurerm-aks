output "namespace" {
  description = "Namespace used for AGIC"
  value       = try(kubernetes_namespace.agic[0].metadata[0].name, "")
}

output "application_gateway_id" {
  description = "Application gateway Id"
  value       = try(azurerm_application_gateway.app_gateway[0].id, "")
}

output "application_gateway_name" {
  description = "Application gateway name"
  value       = try(azurerm_application_gateway.app_gateway[0].name, "")
}

output "public_ip_id" {
  description = "Application gateway public ip Id"
  value       = try(azurerm_public_ip.ip[0].id, "")
}

output "public_ip_name" {
  description = "Application gateway public ip name"
  value       = try(azurerm_public_ip.ip[0].name, "")
}
