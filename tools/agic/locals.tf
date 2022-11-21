locals {
  name_prefix  = var.name_prefix != "" ? replace(var.name_prefix, "/[a-z0-9]/", "$0-") : ""
  default_name = "${local.name_prefix}${var.stack}-${var.client_name}-${var.location_short}-${var.environment}-aks-appgw"
  name         = coalesce(var.name, local.default_name)

  ip_name                             = coalesce(var.ip_name, "${local.name}-pip")
  ip_label                            = coalesce(var.ip_name, "${local.name}-pip")
  frontend_ip_configuration_name      = coalesce(var.frontend_ip_configuration_name, "${local.name}-frontipconfig")
  frontend_priv_ip_configuration_name = coalesce(var.frontend_priv_ip_configuration_name, "${local.name}-frontipconfig-priv")
  gateway_ip_configuration_name       = coalesce(var.gateway_ip_configuration_name, "${local.name}-ipconfig")

  appgw_ingress_default_values = {
    "appgw.name"                 = try(azurerm_application_gateway.app_gateway[0].name, split("/", var.application_gateway_id)[8], "")
    "appgw.subscriptionId"       = try(data.azurerm_subscription.current[0].subscription_id, split("/", var.application_gateway_id)[2], "")
    "appgw.resourceGroup"        = try(azurerm_application_gateway.app_gateway[0].resource_group_name, split("/", var.application_gateway_id)[4], "")
    "appgw.subnetID"             = try(var.app_gateway_subnet_id, "")
    "appgw.usePrivateIP"         = "false"
    "armAuth.type"               = "aadPodIdentity"
    "armAuth.identityResourceID" = try(var.aks_aad_pod_identity_id, "")
    "armAuth.identityClientID"   = try(var.aks_aad_pod_identity_client_id, "")
    "rbac.enabled"               = "true"
    "verbosityLevel"             = "1"
  }

  appgw_ingress_settings = merge(local.appgw_ingress_default_values, var.appgw_ingress_values)
}
