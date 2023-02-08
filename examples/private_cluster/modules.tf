locals {
  allowed_cidrs = ["x.x.x.x", "y.y.y.y"]
}

module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "x.x.x"

  azure_region = var.azure_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "x.x.x"

  location    = module.azure_region.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack
}

module "azure_virtual_network" {
  source  = "claranet/vnet/azurerm"
  version = "x.x.x"

  environment    = var.environment
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  vnet_cidr = ["10.0.0.0/19"]
}

resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = "privatelink.francecentral.azmk8s.io"
  resource_group_name = module.rg.resource_group_name

}

module "node_network_subnet" {
  source  = "claranet/subnet/azurerm"
  version = "x.x.x"

  environment    = var.environment
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  stack          = var.stack

  resource_group_name  = module.rg.resource_group_name
  virtual_network_name = module.azure_virtual_network.virtual_network_name

  name_suffix = "nodes"

  subnet_cidr_list = ["10.0.0.0/20"]

  service_endpoints = ["Microsoft.Storage"]
}

module "appgw_network_subnet" {
  source  = "claranet/subnet/azurerm"
  version = "x.x.x"

  environment    = var.environment
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  stack          = var.stack

  resource_group_name  = module.rg.resource_group_name
  virtual_network_name = module.azure_virtual_network.virtual_network_name

  name_suffix = "appgw"

  subnet_cidr_list = ["10.0.20.0/24"]
}

module "global_run" {
  source  = "claranet/run/azurerm"
  version = "x.x.x"

  client_name    = var.client_name
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  environment    = var.environment
  stack          = var.stack

  monitoring_function_splunk_token = var.monitoring_function_splunk_token

  resource_group_name = module.rg.resource_group_name

  tenant_id = var.azure_tenant_id
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

module "aks" {
  source  = "claranet/aks/azurerm"
  version = "x.x.x"

  client_name = var.client_name
  environment = var.environment
  stack       = var.stack

  resource_group_name = module.rg.resource_group_name
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short

  service_cidr       = "10.0.16.0/22"
  kubernetes_version = "1.19.7"

  vnet_id         = module.azure_virtual_network.virtual_network_id
  nodes_subnet_id = module.node_network_subnet.subnet_id

  private_cluster_enabled = true
  private_dns_zone_type   = "Custom"
  private_dns_zone_id     = azurerm_private_dns_zone.private_dns_zone.id

  agic_enabled           = true
  appgw_subnet_id        = module.appgw_network_subnet.subnet_id
  appgw_identity_enabled = true

  default_node_pool = {
    max_pods        = 110
    os_disk_size_gb = 64
    vm_size         = "Standard_B4ms"
  }

  nodes_pools = [
    {
      name                = "nodepool1"
      vm_size             = "Standard_B4ms"
      os_type             = "Linux"
      os_disk_type        = "Ephemeral"
      os_disk_size_gb     = 100
      vnet_subnet_id      = module.node_network_subnet.subnet_id
      max_pods            = 110
      enable_auto_scaling = true
      count               = 1
      min_count           = 1
      max_count           = 10
    },
  ]

  linux_profile = {
    username = "nodeadmin"
    ssh_key  = tls_private_key.key.public_key_openssh
  }

  oms_log_analytics_workspace_id = module.global_run.log_analytics_workspace_id
  azure_policy_enabled           = false

  logs_destinations_ids = [module.global_run.log_analytics_workspace_id]

  appgw_ingress_controller_values = { "verbosityLevel" = 5, "appgw.shared" = true }
  cert_manager_settings           = { "cainjector.nodeSelector.agentpool" = "default", "nodeSelector.agentpool" = "default", "webhook.nodeSelector.agentpool" = "default" }
  velero_storage_settings         = { allowed_cidrs = local.allowed_cidrs }

  container_registries_id = [module.acr.acr_id]
}

module "acr" {
  source  = "claranet/acr/azurerm"
  version = "x.x.x"

  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  resource_group_name = module.rg.resource_group_name
  sku                 = "Standard"

  client_name = var.client_name
  environment = var.environment
  stack       = var.stack

  logs_destinations_ids = [module.global_run.log_analytics_workspace_id]
}
