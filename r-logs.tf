module "diagnostic-settings" {
  count   = length(var.diagnostic_settings_logs_destination_ids) > 0 ? 1 : 0
  source  = "claranet/diagnostic-settings/azurerm"
  version = "4.0.1"

  resource_id           = azurerm_kubernetes_cluster.aks.id
  logs_destinations_ids = var.diagnostic_settings_logs_destination_ids
  eventhub_name         = var.diagnostic_settings_event_hub_name
  log_categories        = var.diagnostic_settings_log_categories
  metric_categories     = var.diagnostic_settings_metric_categories
  name                  = var.diagnostic_settings_custom_name
  retention_days        = var.diagnostic_settings_retention_days
}
