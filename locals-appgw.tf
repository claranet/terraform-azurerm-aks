locals {
  default_appgw_name = "${var.stack}-${var.client_name}-${var.location_short}-${var.environment}-aks-appgw"
  appgw_name         = coalesce(var.custom_appgw_name, local.default_appgw_name)
}