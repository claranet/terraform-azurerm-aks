#tfsec:ignore:azure-container-use-rbac-permissions
resource "azurerm_kubernetes_cluster" "aks" {
  name                             = local.aks_name
  location                         = var.location
  resource_group_name              = var.resource_group_name
  dns_prefix                       = replace(local.aks_name, "/[\\W_]/", "-")
  kubernetes_version               = var.kubernetes_version
  sku_tier                         = var.aks_sku_tier
  api_server_authorized_ip_ranges  = var.private_cluster_enabled ? null : var.api_server_authorized_ip_ranges
  node_resource_group              = var.node_resource_group
  enable_pod_security_policy       = var.enable_pod_security_policy
  oidc_issuer_enabled              = var.oidc_issuer_enabled
  http_application_routing_enabled = var.http_application_routing_enabled

  private_cluster_enabled = var.private_cluster_enabled
  private_dns_zone_id     = var.private_cluster_enabled ? local.private_dns_zone : null

  dynamic "aci_connector_linux" {
    for_each = var.aci_subnet_id != null && var.aks_network_plugin != "kubenet" ? [true] : []
    content {
      subnet_name = element(split("/", var.aci_subnet_id), length(split("/", var.aci_subnet_id)) - 1)
    }
  }

  default_node_pool {
    name                = local.default_node_pool.name
    vm_size             = local.default_node_pool.vm_size
    zones               = local.default_node_pool.zones
    enable_auto_scaling = local.default_node_pool.enable_auto_scaling
    node_count          = local.default_node_pool.enable_auto_scaling ? null : local.default_node_pool.node_count
    min_count           = local.default_node_pool.enable_auto_scaling ? local.default_node_pool.min_count : null
    max_count           = local.default_node_pool.enable_auto_scaling ? local.default_node_pool.max_count : null
    max_pods            = local.default_node_pool.max_pods
    os_disk_type        = local.default_node_pool.os_disk_type
    os_disk_size_gb     = local.default_node_pool.os_disk_size_gb
    type                = local.default_node_pool.type
    vnet_subnet_id      = local.default_node_pool.vnet_subnet_id
    node_taints         = local.default_node_pool.node_taints
    node_labels         = local.default_node_pool.node_labels
    scale_down_mode     = local.default_node_pool.scale_down_mode
    tags                = merge(local.default_tags, var.default_node_pool_tags)
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_user_assigned_identity.id]
  }

  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile != null ? [var.auto_scaler_profile] : []
    content {
      balance_similar_node_groups      = try(auto_scaler_profile.value.balance_similar_node_groups, null)
      expander                         = try(auto_scaler_profile.value.expander, null)
      max_graceful_termination_sec     = try(auto_scaler_profile.value.max_graceful_termination_sec, null)
      max_node_provisioning_time       = try(auto_scaler_profile.value.max_node_provisioning_time, null)
      max_unready_nodes                = try(auto_scaler_profile.value.max_unready_nodes, null)
      max_unready_percentage           = try(auto_scaler_profile.value.max_unready_percentage, null)
      new_pod_scale_up_delay           = try(auto_scaler_profile.value.new_pod_scale_up_delay, null)
      scale_down_delay_after_add       = try(auto_scaler_profile.value.scale_down_delay_after_add, null)
      scale_down_delay_after_delete    = try(auto_scaler_profile.value.scale_down_delay_after_delete, null)
      scale_down_delay_after_failure   = try(auto_scaler_profile.value.scale_down_delay_after_failure, null)
      scan_interval                    = try(auto_scaler_profile.value.scan_interval, null)
      scale_down_unneeded              = try(auto_scaler_profile.value.scale_down_unneeded, null)
      scale_down_unready               = try(auto_scaler_profile.value.scale_down_unready, null)
      scale_down_utilization_threshold = try(auto_scaler_profile.value.scale_down_utilization_threshold, null)
      empty_bulk_delete_max            = try(auto_scaler_profile.value.empty_bulk_delete_max, null)
      skip_nodes_with_local_storage    = try(auto_scaler_profile.value.skip_nodes_with_local_storage, null)
      skip_nodes_with_system_pods      = try(auto_scaler_profile.value.skip_nodes_with_system_pods, null)
    }
  }

  oms_agent {
    log_analytics_workspace_id = var.oms_log_analytics_workspace_id
  }

  azure_policy_enabled = var.azure_policy_enabled

  dynamic "linux_profile" {
    for_each = var.linux_profile != null ? [true] : []
    iterator = lp
    content {
      admin_username = var.linux_profile.username

      ssh_key {
        key_data = var.linux_profile.ssh_key
      }
    }
  }

  dynamic "http_proxy_config" {
    for_each = var.aks_http_proxy_settings != null ? ["enabled"] : []
    content {
      http_proxy  = var.aks_http_proxy_settings.http_proxy_url
      https_proxy = var.aks_http_proxy_settings.https_proxy_url
      no_proxy    = distinct(flatten(concat(local.default_no_proxy_url_list, var.aks_http_proxy_settings.no_proxy_url_list)))
      trusted_ca  = var.aks_http_proxy_settings.trusted_ca
    }
  }

  network_profile {
    network_plugin     = var.aks_network_plugin
    network_policy     = var.aks_network_plugin == "azure" ? "azure" : var.aks_network_policy
    network_mode       = var.aks_network_plugin == "azure" ? "transparent" : null
    dns_service_ip     = cidrhost(var.service_cidr, 10)
    docker_bridge_cidr = var.docker_bridge_cidr
    service_cidr       = var.service_cidr
    load_balancer_sku  = "standard"
    outbound_type      = var.outbound_type
    pod_cidr           = var.aks_network_plugin == "kubenet" ? var.aks_pod_cidr : null
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider[*]
    content {
      secret_rotation_enabled  = key_vault_secrets_provider.value.secret_rotation_enabled
      secret_rotation_interval = key_vault_secrets_provider.value.secret_rotation_interval
    }
  }

  depends_on = [
    azurerm_role_assignment.aks_uai_private_dns_zone_contributor,
    azurerm_role_assignment.aks_uai_route_table_contributor,
  ]

  tags = merge(local.default_tags, var.extra_tags)
}

resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  count                  = length(local.nodes_pools)
  kubernetes_cluster_id  = azurerm_kubernetes_cluster.aks.id
  name                   = local.nodes_pools[count.index].name
  vm_size                = local.nodes_pools[count.index].vm_size
  os_type                = local.nodes_pools[count.index].os_type
  orchestrator_version   = local.nodes_pools[count.index].orchestrator_version
  os_disk_type           = local.nodes_pools[count.index].os_disk_type
  os_disk_size_gb        = local.nodes_pools[count.index].os_disk_size_gb
  priority               = local.nodes_pools[count.index].priority
  vnet_subnet_id         = local.nodes_pools[count.index].vnet_subnet_id
  enable_host_encryption = local.nodes_pools[count.index].enable_host_encryption
  eviction_policy        = local.nodes_pools[count.index].eviction_policy
  enable_auto_scaling    = local.nodes_pools[count.index].enable_auto_scaling
  node_count             = local.nodes_pools[count.index].enable_auto_scaling ? null : local.nodes_pools[count.index].node_count
  min_count              = local.nodes_pools[count.index].enable_auto_scaling ? local.nodes_pools[count.index].min_count : null
  max_count              = local.nodes_pools[count.index].enable_auto_scaling ? local.nodes_pools[count.index].max_count : null
  max_pods               = local.nodes_pools[count.index].max_pods
  node_labels            = local.nodes_pools[count.index].node_labels
  node_taints            = local.nodes_pools[count.index].node_taints
  enable_node_public_ip  = local.nodes_pools[count.index].enable_node_public_ip
  workload_runtime       = local.nodes_pools[count.index].workload_runtime
  zones                  = local.nodes_pools[count.index].zones
  scale_down_mode        = local.nodes_pools[count.index].scale_down_mode
  tags                   = merge(local.default_tags, var.node_pool_tags)
}

# Allow user assigned identity to manage AKS items in MC_xxx RG
resource "azurerm_role_assignment" "aks_user_assigned" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  scope                = format("/subscriptions/%s/resourceGroups/%s", data.azurerm_subscription.current.subscription_id, azurerm_kubernetes_cluster.aks.node_resource_group)
  role_definition_name = "Contributor"
}
