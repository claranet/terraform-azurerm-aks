module "appgw" {
  source = "./modules/appgw"

  stack       = var.stack
  environment = var.environment
  location    = var.location

  name    = local.appgw_name
  rg_name = var.resource_group_name

  ip_name                        = "${local.appgw_name}-pip"
  ip_label                       = "${local.appgw_name}-pip"
  ip_sku                         = "Standard"
  ip_allocation_method           = "Static"
  frontend_ip_configuration_name = "${local.appgw_name}-frontipconfig"
  gateway_ip_configuration_name  = "${local.appgw_name}-ipconfig"
  app_gateway_subnet_id          = var.appgw_subnet_id

  sku_name     = "Standard_v2"
  sku_tier     = "Standard_v2"
  sku_capacity = 2

  zones = ["1", "2", "3"]

  policy_name = var.appgw_policy_name

  enabled_waf = false

  // Dummy values to create the appgw.
  //Then the configuration will be managed by AKS
  appgw_backend_http_settings = [{
    name                  = "dummy"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
    probe_name            = "dummy"
  }]
  appgw_backend_pools = [{
    name  = "dummy"
    fqdns = ["dummy"]
  }]
  appgw_probes = [{
    host                                      = "dummy"
    interval                                  = 30
    minimum_servers                           = 0
    name                                      = "dummy"
    path                                      = "/"
    pick_host_name_from_backend_http_settings = false
    protocol                                  = "Http"
    timeout                                   = 30
    unhealthy_threshold                       = 3
    match_status_code                         = ["200"]
  }]
  appgw_routings = [{
    name                       = "dummy"
    rule_type                  = "Basic"
    http_listener_name         = "dummy"
    backend_address_pool_name  = "dummy"
    backend_http_settings_name = "dummy"

  }]
  appgw_http_listeners = [{
    name                           = "dummy"
    frontend_ip_configuration_name = "dummy"
    frontend_port_name             = "dummy"
    protocol                       = "Http"
    host_name                      = "dummy"
  }]
  frontend_port_settings = [{
    name = "dummy"
    port = 80
  }]
  ssl_certificates_configs = []

  app_gateway_tags = local.tags
  ip_tags          = local.tags

  aks_aad_pod_identity_id           = azurerm_user_assigned_identity.aad_pod_identity.id
  aks_aad_pod_identity_client_id    = azurerm_user_assigned_identity.aad_pod_identity.client_id
  aks_aad_pod_identity_principal_id = azurerm_user_assigned_identity.aad_pod_identity.principal_id
  appgw_ingress_settings            = var.appgw_ingress_controller_settings
  aks_name                          = azurerm_kubernetes_cluster.aks.name
}