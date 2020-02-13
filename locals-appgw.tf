locals {
  default_appgw_name = "${var.stack}-${var.client_name}-${var.location_short}-${var.environment}-aks-appgw"
  appgw_name         = coalesce(var.custom_appgw_name, local.default_appgw_name)

  appgw_default_settings = {
    ip_name                        = "${local.appgw_name}-pip"
    ip_label                       = "${local.appgw_name}-pip"
    ip_sku                         = "Standard"
    ip_allocation_method           = "Static"
    frontend_ip_configuration_name = "${local.appgw_name}-frontipconfig"
    gateway_ip_configuration_name  = "${local.appgw_name}-ipconfig"
    sku_name                       = "Standard_v2"
    sku_tier                       = "Standard_v2"
    sku_capacity                   = 2
    zones                          = ["1", "2", "3"]
    policy_name                    = "AppGwSslPolicy20170401S"
    enabled_waf                    = false
    app_gateway_tags               = local.tags
    ip_tags                        = local.tags
    appgw_backend_http_settings    = [{
      name                  = "dummy"
      cookie_based_affinity = "Disabled"
      path                  = "/"
      port                  = 80
      protocol              = "Http"
      request_timeout       = 1
      probe_name            = "dummy"
    }]
    appgw_backend_pools            = [{
      name  = "dummy"
      fqdns = ["dummy"]
    }]
    appgw_probes                   = [{
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
    appgw_routings                 = [{
      name                       = "dummy"
      rule_type                  = "Basic"
      http_listener_name         = "dummy"
      backend_address_pool_name  = "dummy"
      backend_http_settings_name = "dummy"

    }]
    appgw_http_listeners           = [{
      name                           = "dummy"
      frontend_ip_configuration_name = "dummy"
      frontend_port_name             = "dummy"
      protocol                       = "Http"
      host_name                      = "dummy"
    }]
    frontend_port_settings         = [{
      name = "dummy"
      port = 80
    }]
    ssl_certificates_configs       = []
  }

  appgw_settings = merge(local.appgw_default_settings, var.appgw_settings)
}