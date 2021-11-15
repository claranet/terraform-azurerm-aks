module "diagnostic_settings" {
  source  = "claranet/diagnostic-settings/azurerm"
  version = "4.0.3"

  resource_id           = azurerm_kubernetes_cluster.aks.id
  logs_destinations_ids = var.diagnostic_settings_logs_destination_ids

  log_categories    = var.diagnostic_settings_log_categories
  metric_categories = var.diagnostic_settings_metric_categories
  name              = var.diagnostic_settings_custom_name
  retention_days    = var.diagnostic_settings_retention_days
}
