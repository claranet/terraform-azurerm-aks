locals {

  aks_name = "${var.stack}-${var.client_name}-${var.location_short}-${var.environment}-aks"

  default_agent_profile = {
    name                  = "default"
    count                 = 1
    vm_size               = "Standard_D2_v3"
    os_type               = "Linux"
    availability_zones    = null
    enable_auto_scaling   = false
    min_count             = null
    max_count             = null
    type                  = "VirtualMachineScaleSets"
    node_taints           = null
    vnet_subnet_id        = var.nodes_subnet_id
    max_pods              = 30
    os_disk_size_gb       = 32
    enable_node_public_ip = false
  }

  # Defaults for Linux profile
  # Generally smaller images so can run more pods and require smaller HD
  default_linux_node_profile = {
    max_pods        = 30
    os_disk_size_gb = 60
  }

  # Defaults for Windows profile
  # Do not want to run same number of pods and some images can be quite large
  default_windows_node_profile = {
    max_pods        = 20
    os_disk_size_gb = 200
  }

  default_node_pool = merge(local.default_agent_profile, var.default_node_pool)

  tags = {
    env   = var.environment
    stack = var.stack
  }


  nodes_pools_with_defaults = [for ap in var.nodes_pools : merge(local.default_agent_profile, ap)]
  nodes_pools = [for ap in local.nodes_pools_with_defaults : ap.os_type == "Linux" ? merge(local.default_linux_node_profile, ap) : merge(local.default_windows_node_profile, ap)
  ]


  # Diagnostic settings
  diag_kube_logs    = data.azurerm_monitor_diagnostic_categories.aks-diag-categories.logs
  diag_kube_metrics = data.azurerm_monitor_diagnostic_categories.aks-diag-categories.metrics

  diag_resource_list = var.diagnostics.enabled ? split("/", var.diagnostics.destination) : []
  parsed_diag = var.diagnostics.enabled ? {
    log_analytics_id   = contains(local.diag_resource_list, "microsoft.operationalinsights") ? var.diagnostics.destination : null
    storage_account_id = contains(local.diag_resource_list, "Microsoft.Storage") ? var.diagnostics.destination : null
    event_hub_auth_id  = contains(local.diag_resource_list, "Microsoft.EventHub") ? var.diagnostics.destination : null
    metric             = contains(var.diagnostics.metrics, "all") ? local.diag_kube_metrics : var.diagnostics.metrics
    log                = contains(var.diagnostics.logs, "all") ? local.diag_kube_logs : var.diagnostics.metrics
    } : {
    log_analytics_id   = null
    storage_account_id = null
    event_hub_auth_id  = null
    metric             = []
    log                = []
  }

}
