<<<<<<< HEAD:modules/agic/r-logs.tf
module "diagnostic_settings_appgw" {
  count   = length(var.diagnostic_settings_logs_destination_ids) > 0 && var.enable_agic ? 1 : 0
=======
module "diagnostic-settings-appgw" {
>>>>>>> origin/master:tools/agic/r-logs.tf
  source  = "claranet/diagnostic-settings/azurerm"
  version = "4.0.2"

  resource_id           = azurerm_application_gateway.app_gateway[0].id
  logs_destinations_ids = var.diagnostic_settings_logs_destination_ids
  log_categories        = var.diagnostic_settings_log_categories
  metric_categories     = var.diagnostic_settings_metric_categories
  name                  = var.diagnostic_settings_custom_name
  retention_days        = var.diagnostic_settings_retention_days
}
