locals {
  default_agent_profile = {
    name                   = "default"
    count                  = 1
    vm_size                = "Standard_D2_v3"
    os_type                = "Linux"
    zones                  = [1, 2, 3]
    enable_auto_scaling    = false
    min_count              = null
    max_count              = null
    type                   = "VirtualMachineScaleSets"
    node_taints            = null
    node_labels            = null
    orchestrator_version   = null
    priority               = null
    enable_host_encryption = null
    eviction_policy        = null
    vnet_subnet_id         = var.nodes_subnet_id
    max_pods               = 30
    os_disk_type           = "Managed"
    os_disk_size_gb        = 128
    enable_node_public_ip  = false
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
