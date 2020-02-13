locals {
  appgw_ingress_default_values = {
    "appgw.resourceGroup"        = azurerm_application_gateway.app_gateway.resource_group_name,
    "appgw.subscriptionId"       = data.azurerm_subscription.current.subscription_id,
    "appgw.usePrivateIP"         = "false",
    "appgw.name"                 = azurerm_application_gateway.app_gateway.name,
    "armAuth.type"               = "aadPodIdentity",
    "armAuth.identityResourceID" = var.aks_aad_pod_identity_id,
    "armAuth.identityClientID"   = var.aks_aad_pod_identity_client_id,
    "rbac.enabled"               = "true",
    "verbosityLevel"             = "1"
  }

  appgw_ingress_settings = merge(local.appgw_ingress_default_values, var.appgw_ingress_values)
}