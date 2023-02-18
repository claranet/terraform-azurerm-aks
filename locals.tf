locals {
  default_agent_profile = {
    name                   = var.default_node_pool.name
    node_count             = var.default_node_pool.enable_auto_scaling == true ? var.default_node_pool.min_count : var.default_node_pool.node_count
    vm_size                = var.default_node_pool.vm_size
    os_type                = var.default_node_pool.os_type
    zones                  = var.default_node_pool.zones
    enable_auto_scaling    = var.default_node_pool.enable_auto_scaling
    min_count              = var.default_node_pool.min_count
    max_count              = var.default_node_pool.max_count
    type                   = var.default_node_pool.type
    node_taints            = var.default_node_pool.node_taints
    node_labels            = var.default_node_pool.node_labels
    orchestrator_version   = var.default_node_pool.orchestrator_version
    priority               = var.default_node_pool.priority
    enable_host_encryption = var.default_node_pool.enable_host_encryption
    eviction_policy        = var.default_node_pool.eviction_policy
    vnet_subnet_id         = var.nodes_subnet_id
    max_pods               = var.default_node_pool.max_pods
    os_disk_type           = var.default_node_pool.os_disk_type
    os_disk_size_gb        = var.default_node_pool.os_disk_size_gb
    enable_node_public_ip  = var.default_node_pool.enable_node_public_ip
  }

  # Defaults for Linux profile
  # Generally smaller images so can run more pods and require smaller HD
  default_linux_node_profile = {
    max_pods        = 30
    os_disk_size_gb = 128
  }

  # Defaults for Windows profile
  # Do not want to run same number of pods and some images can be quite large
  default_windows_node_profile = {
    max_pods        = 20
    os_disk_size_gb = 256
  }

  default_node_pool = merge(local.default_agent_profile, var.default_node_pool)

  private_dns_zone = var.private_dns_zone_type == "Custom" ? var.private_dns_zone_id : var.private_dns_zone_type

  nodes_pools_with_defaults = [for ap in var.nodes_pools : merge(local.default_agent_profile, ap)]
  nodes_pools               = [for ap in local.nodes_pools_with_defaults : ap.os_type == "Linux" ? merge(local.default_linux_node_profile, ap) : merge(local.default_windows_node_profile, ap)]

}
