output "aks_id" {
  description = "AKS resource id"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_nodes_rg" {
  description = "Name of the resource group in which AKS nodes are deployed"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "aks_nodes_pools_ids" {
  description = "Ids of AKS nodes pools"
  value       = azurerm_kubernetes_cluster_node_pool.node_pools.*.id
}

output "aks_nodes_pools_names" {
  description = "Names of AKS nodes pools"
  value       = azurerm_kubernetes_cluster_node_pool.node_pools.*.name
}

output "aks_kube_config_raw" {
  description = "Raw kube config to be used by kubectl command"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "aks_kube_config" {
  description = "Kube configuration of AKS Cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config
  sensitive   = true
}

output "application_gateway_id" {
  description = "Id of the application gateway used by AKS"
  value       = module.appgw.id
}