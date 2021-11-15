module "diagnostic_settings_appgw" {
  count = var.agic_enabled ? 1 : 0

  source  = "claranet/diagnostic-settings/azurerm"
  version = "4.0.3"

  resource_id           = azurerm_application_gateway.app_gateway[0].id
  logs_destinations_ids = var.diagnostic_settings_logs_destination_ids
  log_categories        = var.diagnostic_settings_log_categories
  metric_categories     = var.diagnostic_settings_metric_categories
  name                  = var.diagnostic_settings_custom_name
  retention_days        = var.diagnostic_settings_retention_days
}
