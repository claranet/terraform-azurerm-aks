locals {
  name_prefix = var.name_prefix != "" ? replace(var.name_prefix, "/[a-z0-9]/", "$0-") : ""

  #    "appgw.name"                 = var.enable_agic ? azurerm_application_gateway.app_gateway.0.name: "",
  #    "appgw.subscriptionId"       = var.enable_agic ? data.azurerm_subscription.current.0.subscription_id : "",
  #    "appgw.resourceGroup"        = var.enable_agic ? azurerm_application_gateway.app_gateway.0.resource_group_name : "",
  appgw_ingress_default_values = {
    "appgw.name"                 = var.enable_agic ? var.name : ""
    "appgw.subnetID"             = var.enable_agic ? var.app_gateway_subnet_id : ""
    "appgw.usePrivateIP"         = "false"
    "armAuth.type"               = "aadPodIdentity"
    "armAuth.identityResourceID" = var.enable_agic ? var.aks_aad_pod_identity_id : ""
    "armAuth.identityClientID"   = var.aks_aad_pod_identity_client_id
    "rbac.enabled"               = "true"
    "verbosityLevel"             = "1"
  }

  appgw_ingress_settings = merge(local.appgw_ingress_default_values, var.appgw_ingress_values)

  # Diagnostic settings
  #  diag_kube_logs    = var.enable_agic ? data.azurerm_monitor_diagnostic_categories.aks-diag-categories.0.logs : []
  #  diag_kube_metrics = var.enable_agic ? data.azurerm_monitor_diagnostic_categories.aks-diag-categories.0.metrics : []

  #  diag_resource_list = var.diagnostics.enabled && var.enable_agic ? split("/", var.diagnostics.destination) : []
  #  parsed_diag        = var.diagnostics.enabled && var.enable_agic ? {
  #    log_analytics_id   = contains(local.diag_resource_list, "microsoft.operationalinsights") ? var.diagnostics.destination : null
  #    storage_account_id = contains(local.diag_resource_list, "Microsoft.Storage") ? var.diagnostics.destination : null
  #    event_hub_auth_id  = contains(local.diag_resource_list, "Microsoft.EventHub") ? var.diagnostics.destination : null
  #    metric             = contains(var.diagnostics.metrics, "all") ? local.diag_kube_metrics : var.diagnostics.metrics
  #    log                = contains(var.diagnostics.logs, "all") ? local.diag_kube_logs : var.diagnostics.metrics
  #  } : {
  #    log_analytics_id   = null
  #    storage_account_id = null
  #    event_hub_auth_id  = null
  #    metric             = []
  #    log                = []
  #  }
}