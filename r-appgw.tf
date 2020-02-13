module "appgw" {
  source = "./modules/appgw"

  stack       = var.stack
  environment = var.environment
  location    = var.location

  name                  = local.appgw_name
  rg_name               = var.resource_group_name
  app_gateway_subnet_id = var.appgw_subnet_id

  ip_name                        = local.appgw_settings.ip_name
  ip_label                       = local.appgw_settings.ip_label
  ip_sku                         = local.appgw_settings.ip_sku
  ip_allocation_method           = local.appgw_settings.ip_allocation_method
  frontend_ip_configuration_name = local.appgw_settings.frontend_ip_configuration_name
  gateway_ip_configuration_name  = local.appgw_settings.gateway_ip_configuration_name

  sku_name     = local.appgw_settings.sku_name
  sku_tier     = local.appgw_settings.sku_tier
  sku_capacity = local.appgw_settings.sku_capacity

  zones = local.appgw_settings.zones

  policy_name = local.appgw_settings.policy_name

  enabled_waf = local.appgw_settings.enabled_waf

  appgw_backend_http_settings = local.appgw_settings.appgw_backend_http_settings
  appgw_backend_pools         = local.appgw_settings.appgw_backend_pools
  appgw_probes                = local.appgw_settings.appgw_probes
  appgw_routings              = local.appgw_settings.appgw_routings
  appgw_http_listeners        = local.appgw_settings.appgw_http_listeners
  frontend_port_settings      = local.appgw_settings.frontend_port_settings
  ssl_certificates_configs    = local.appgw_settings.ssl_certificates_configs

  app_gateway_tags = local.appgw_settings.app_gateway_tags
  ip_tags          = local.appgw_settings.ip_tags

  aks_aad_pod_identity_id           = azurerm_user_assigned_identity.aad_pod_identity.id
  aks_aad_pod_identity_client_id    = azurerm_user_assigned_identity.aad_pod_identity.client_id
  aks_aad_pod_identity_principal_id = azurerm_user_assigned_identity.aad_pod_identity.principal_id
  appgw_ingress_values              = var.appgw_ingress_controller_values
  aks_name                          = azurerm_kubernetes_cluster.aks.name
}