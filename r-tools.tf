module "appgw" {
  source = "./tools/agic"

  agic_enabled          = var.agic_enabled
  agic_chart_repository = var.agic_chart_repository
  agic_chart_version    = coalesce(var.agic_helm_version, var.agic_chart_version)

  stack          = var.stack
  environment    = var.environment
  location       = var.location
  location_short = var.location_short
  client_name    = var.client_name

  name                  = local.appgw_name
  resource_group_name   = var.resource_group_name
  app_gateway_subnet_id = var.appgw_subnet_id

  custom_diagnostic_settings_name = var.custom_diagnostic_settings_name

  logs_destinations_ids   = var.logs_destinations_ids
  logs_retention_days     = var.logs_retention_days
  logs_categories         = var.logs_categories
  logs_metrics_categories = var.logs_metrics_categories

  ip_name                             = local.appgw_settings.ip_name
  ip_sku                              = local.appgw_settings.ip_sku
  ip_allocation_method                = local.appgw_settings.ip_allocation_method
  frontend_ip_configuration_name      = local.appgw_settings.frontend_ip_configuration_name
  frontend_priv_ip_configuration_name = local.appgw_settings.frontend_priv_ip_configuration_name
  gateway_ip_configuration_name       = local.appgw_settings.gateway_ip_configuration_name
  gateway_identity_id                 = local.appgw_settings.identity

  sku_name     = local.appgw_settings.sku_name
  sku_tier     = local.appgw_settings.sku_tier
  sku_capacity = local.appgw_settings.sku_capacity

  zones = local.appgw_settings.zones

  policy_name = local.appgw_settings.policy_name

  enabled_waf              = local.appgw_settings.enabled_waf
  file_upload_limit_mb     = local.appgw_settings.file_upload_limit_mb
  max_request_body_size_kb = local.appgw_settings.max_request_body_size_kb
  request_body_check       = local.appgw_settings.request_body_check
  rule_set_type            = local.appgw_settings.rule_set_type
  rule_set_version         = local.appgw_settings.rule_set_version
  firewall_mode            = local.appgw_settings.firewall_mode

  use_existing_application_gateway = var.use_existing_application_gateway
  application_gateway_id           = var.application_gateway_id

  appgw_backend_http_settings = local.appgw_settings.appgw_backend_http_settings
  appgw_backend_pools         = local.appgw_settings.appgw_backend_pools
  appgw_probes                = local.appgw_settings.appgw_probes
  appgw_routings              = local.appgw_settings.appgw_routings
  appgw_http_listeners        = local.appgw_settings.appgw_http_listeners
  frontend_port_settings      = local.appgw_settings.frontend_port_settings

  ssl_certificates_configs = var.appgw_ssl_certificates_configs

  app_gateway_tags = local.appgw_settings.app_gateway_tags
  ip_tags          = local.appgw_settings.ip_tags

  aks_aad_pod_identity_id           = module.infra.aad_pod_identity_id
  aks_aad_pod_identity_client_id    = module.infra.aad_pod_identity_client_id
  aks_aad_pod_identity_principal_id = module.infra.aad_pod_identity_principal_id

  appgw_ingress_values = var.appgw_ingress_controller_values

  private_ingress  = var.private_ingress
  appgw_private_ip = var.appgw_private_ip
}

module "certmanager" {
  source = "./tools/cert-manager"

  enable_cert_manager           = var.enable_cert_manager
  cert_manager_namespace        = var.cert_manager_namespace
  cert_manager_chart_repository = var.cert_manager_chart_repository
  cert_manager_chart_version    = var.cert_manager_chart_version
  cert_manager_settings         = var.cert_manager_settings
}

module "kured" {
  source = "./tools/kured"

  enable_kured           = var.enable_kured
  kured_settings         = var.kured_settings
  kured_chart_repository = var.kured_chart_repository
  kured_chart_version    = var.kured_chart_version
}

module "velero" {
  depends_on = [azurerm_kubernetes_cluster.aks]

  source = "./tools/velero"

  enable_velero = var.enable_velero

  client_name    = var.client_name
  stack          = var.stack
  environment    = var.environment
  location       = var.location
  location_short = var.location_short
  name_prefix    = var.name_prefix

  resource_group_name           = var.resource_group_name
  aks_nodes_resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  nodes_subnet_id               = var.nodes_subnet_id

  velero_namespace            = var.velero_namespace
  velero_chart_repository     = var.velero_chart_repository
  velero_chart_version        = var.velero_chart_version
  velero_values               = var.velero_values
  velero_storage_settings     = var.velero_storage_settings
  velero_identity_custom_name = var.velero_identity_custom_name

  velero_identity_tags = merge(local.default_tags, var.velero_identity_extra_tags)

}
