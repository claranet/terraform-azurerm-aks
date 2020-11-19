module "appgw" {
  source = "./modules/tools/agic"

  providers = {
    kubernetes = kubernetes.aks-module
    helm       = helm.aks-module
  }

  enable_agic           = var.enable_agic
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
  diagnostics           = var.diagnostics

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

  aks_aad_pod_identity_id           = module.infra.aad_pod_identity_id
  aks_aad_pod_identity_client_id    = module.infra.aad_pod_identity_client_id
  aks_aad_pod_identity_principal_id = module.infra.add_pod_identity_principal_id

  appgw_ingress_values = var.appgw_ingress_controller_values
  aks_name             = azurerm_kubernetes_cluster.aks.name
}

module "certmanager" {
  source = "./modules/tools/cert-manager"

  providers = {
    kubernetes = kubernetes.aks-module
    helm       = helm.aks-module
  }

  enable_cert_manager           = var.enable_cert_manager
  cert_manager_namespace        = var.cert_manager_namespace
  cert_manager_chart_repository = var.cert_manager_chart_repository
  cert_manager_chart_version    = var.cert_manager_chart_version
  cert_manager_settings         = var.cert_manager_settings
}

module "kured" {
  source = "./modules/tools/kured"

  providers = {
    kubernetes = kubernetes.aks-module
    helm       = helm.aks-module
  }

  enable_kured           = var.enable_kured
  kured_settings         = var.kured_settings
  kured_chart_repository = var.kured_chart_repository
  kured_chart_version    = var.kured_chart_version
}

module "velero" {
  source = "./modules/tools/velero"

  providers = {
    kubernetes = kubernetes.aks-module
    helm       = helm.aks-module
  }

  enable_velero = var.enable_velero

  client_name    = var.client_name
  stack          = var.stack
  environment    = var.environment
  location       = var.location
  location_short = var.location_short
  name_prefix    = var.name_prefix

  resource_group_name           = var.resource_group_name
  aks_nodes_resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  aks_cluster_name              = azurerm_kubernetes_cluster.aks.name
  nodes_subnet_id               = var.nodes_subnet_id

  velero_namespace        = var.velero_namespace
  velero_chart_repository = var.velero_chart_repository
  velero_chart_version    = var.velero_chart_version
  velero_values           = var.velero_values
  velero_storage_settings = var.velero_storage_settings
}
