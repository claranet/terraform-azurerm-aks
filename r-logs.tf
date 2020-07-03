resource "azurerm_monitor_diagnostic_setting" "aks" {
  count                          = var.diagnostics.enabled ? 1 : 0
  name                           = var.diag_custom_name == null ? "${local.name_prefix}${var.stack}-${var.client_name}-${var.location_short}-${var.environment}-aks-diag" : var.diag_custom_name
  target_resource_id             = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id     = local.parsed_diag.log_analytics_id
  eventhub_authorization_rule_id = local.parsed_diag.event_hub_auth_id
  eventhub_name                  = local.parsed_diag.event_hub_auth_id != null ? var.diagnostics.eventhub_name : null
  storage_account_id             = local.parsed_diag.storage_account_id

  dynamic "log" {
    for_each = local.parsed_diag.log
    content {
      category = log.value

      retention_policy {
        enabled = false
      }
    }
  }

  dynamic "metric" {
    for_each = local.parsed_diag.metric
    content {
      category = metric.value

      retention_policy {
        enabled = false
      }
    }
  }
}