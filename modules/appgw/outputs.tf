output "application_gateway_id" {
  description = "Application gateway Id"
  value       = azurerm_application_gateway.app_gateway.id
}

output "application_gateway_name" {
  description = "Application gateway name"
  value       = azurerm_application_gateway.app_gateway.name
}

output "public_ip_id" {
  description = "Application gateway public ip Id"
  value       = azurerm_public_ip.ip.id
}

output "public_ip_name" {
  description = "Application gateway public ip name"
  value       = azurerm_public_ip.ip.name
}
