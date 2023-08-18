variable "location" {
  description = "Azure region to use"
  type        = string
}

variable "location_short" {
  description = "Short name of Azure regions to use"
  type        = string
}

variable "client_name" {
  description = "Client name/account used in naming"
  type        = string
}

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "stack" {
  description = "Project stack name"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the AKS resource group"
  type        = string
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to deploy"
  type        = string
  default     = "1.17.9"
}

variable "api_server_authorized_ip_ranges" {
  description = "Ip ranges allowed to interract with Kubernetes API. Default no restrictions"
  type        = list(string)
  default     = []
}

variable "node_resource_group" {
  description = "Name of the resource group in which to put AKS nodes. If null default to MC_<AKS RG Name>"
  type        = string
  default     = null
}

variable "enable_pod_security_policy" {
  description = "Enable pod security policy or not. https://docs.microsoft.com/fr-fr/azure/AKS/use-pod-security-policies"
  type        = bool
  default     = false
}

variable "oidc_issuer_enabled" {
  description = "Whether to enable OpenID Connect issuer or not. https://learn.microsoft.com/en-us/azure/aks/use-oidc-issuer"
  type        = bool
  default     = false
}

variable "http_application_routing_enabled" {
  description = "Whether HTTP Application Routing is enabled."
  type        = bool
  default     = false
}

variable "private_cluster_enabled" {
  description = "Configure AKS as a Private Cluster: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_cluster_enabled"
  type        = bool
  default     = true
}

variable "vnet_id" {
  description = "Vnet id that Aks MSI should be network contributor in a private cluster"
  type        = string
  default     = null
}

variable "appgw_identity_enabled" {
  description = "Configure a managed service identity for Application gateway used with AGIC (useful to configure ssl cert into appgw from keyvault)"
  type        = bool
  default     = false
}

variable "private_dns_zone_type" {
  type        = string
  default     = "System"
  description = <<EOD
Set AKS private dns zone if needed and if private cluster is enabled (privatelink.<region>.azmk8s.io)
- "Custom" : You will have to deploy a private Dns Zone on your own and pass the id with <private_dns_zone_id> variable
If this settings is used, aks user assigned identity will be "userassigned" instead of "systemassigned"
and the aks user must have "Private DNS Zone Contributor" role on the private DNS Zone
- "System" : AKS will manage the private zone and create it in the same resource group as the Node Resource Group
- "None" : In case of None you will need to bring your own DNS server and set up resolving, otherwise cluster will have issues after provisioning.

https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_dns_zone_id
EOD
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Id of the private DNS Zone when <private_dns_zone_type> is custom"
}

variable "private_dns_zone_role_assignment_enabled" {
  description = "Option to enable or disable Private DNS Zone role assignment."
  type        = bool
  default     = true
}

variable "aks_user_assigned_identity_resource_group_name" {
  description = "Resource Group where to deploy the aks user assigned identity resource. Used when private cluster is enabled and when Azure private dns zone is not managed by aks"
  type        = string
  default     = null
}

variable "aks_route_table_id" {
  description = "Provide an existing route table when `outbound_type variable` is set to `userdefinedrouting` with kubenet : https://docs.microsoft.com/fr-fr/azure/aks/configure-kubenet#bring-your-own-subnet-and-route-table-with-kubenet"
  type        = string
  default     = null
}

variable "aks_sku_tier" {
  description = "aks sku tier. Possible values are Free ou Paid"
  type        = string
  default     = "Free"
}

variable "aks_network_plugin" {
  description = "AKS network plugin to use. Possible values are `azure` and `kubenet`. Changing this forces a new resource to be created"
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "kubenet"], var.aks_network_plugin)
    error_message = "The network plugin value must be \"azure\" or \"kubenet\"."
  }
}

variable "aks_network_policy" {
  description = "AKS network policy to use."
  type        = string
  default     = "calico"
}

variable "aks_http_proxy_settings" {
  description = "AKS HTTP proxy settings. URLs must be in format `http(s)://fqdn:port/`. When setting the `no_proxy_url_list` parameter, the AKS Private Endpoint domain name and the AKS VNet CIDR must be added to the URLs list."
  type = object({
    http_proxy_url    = optional(string)
    https_proxy_url   = optional(string)
    no_proxy_url_list = optional(list(string), [])
    trusted_ca        = optional(string)
  })
  default = null
}

variable "appgw_user_assigned_identity_resource_group_name" {
  description = "Resource Group where to deploy the Application Gateway User Assigned Identity resource."
  type        = string
  default     = null
}

variable "default_node_pool" {
  description = "Default node pool configuration"
  type = object({
    name                   = optional(string, "default")
    node_count             = optional(number, 1)
    vm_size                = optional(string, "Standard_D2_v3")
    os_type                = optional(string, "Linux")
    workload_runtime       = optional(string, null)
    zones                  = optional(list(number), [1, 2, 3])
    enable_auto_scaling    = optional(bool, false)
    min_count              = optional(number, 1)
    max_count              = optional(number, 10)
    type                   = optional(string, "VirtualMachineScaleSets")
    node_taints            = optional(list(any), null)
    node_labels            = optional(map(any), null)
    orchestrator_version   = optional(string, null)
    priority               = optional(string, null)
    enable_host_encryption = optional(bool, null)
    eviction_policy        = optional(string, null)
    max_pods               = optional(number, 30)
    os_disk_type           = optional(string, "Managed")
    os_disk_size_gb        = optional(number, 128)
    enable_node_public_ip  = optional(bool, false)
    scale_down_mode        = optional(string, "Delete")
  })
  default = {}
}

variable "nodes_subnet_id" {
  description = "ID of the subnet used for nodes"
  type        = string
}

variable "aci_subnet_id" {
  description = "Optional subnet Id used for ACI virtual-nodes"
  type        = string
  default     = null
}

variable "auto_scaler_profile" {
  description = "Configuration of `auto_scaler_profile` block object"
  type = object({
    balance_similar_node_groups      = optional(bool, false)
    expander                         = optional(string, "random")
    max_graceful_termination_sec     = optional(number, 600)
    max_node_provisioning_time       = optional(string, "15m")
    max_unready_nodes                = optional(number, 3)
    max_unready_percentage           = optional(number, 45)
    new_pod_scale_up_delay           = optional(string, "10s")
    scale_down_delay_after_add       = optional(string, "10m")
    scale_down_delay_after_delete    = optional(string, "10s")
    scale_down_delay_after_failure   = optional(string, "3m")
    scan_interval                    = optional(string, "10s")
    scale_down_unneeded              = optional(string, "10m")
    scale_down_unready               = optional(string, "20m")
    scale_down_utilization_threshold = optional(number, 0.5)
    empty_bulk_delete_max            = optional(number, 10)
    skip_nodes_with_local_storage    = optional(bool, true)
    skip_nodes_with_system_pods      = optional(bool, true)
  })
  default = null
}

variable "oms_log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace used to send OMS logs"
  type        = string
}

variable "azure_policy_enabled" {
  description = "Should the Azure Policy Add-On be enabled?"
  type        = bool
  default     = false
}

variable "linux_profile" {
  description = "Username and ssh key for accessing AKS Linux nodes with ssh."
  type = object({
    username = string,
    ssh_key  = string
  })
  default = null
}

variable "service_cidr" {
  description = "CIDR used by kubernetes services (kubectl get svc)."
  type        = string
}

variable "aks_pod_cidr" {
  description = "CIDR used by pods when network plugin is set to `kubenet`. https://docs.microsoft.com/en-us/azure/aks/configure-kubenet"
  type        = string
  default     = "172.17.0.0/16"
}

variable "outbound_type" {
  description = "The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are `loadBalancer` and `userDefinedRouting`."
  type        = string
  default     = "loadBalancer"
}

variable "docker_bridge_cidr" {
  description = "IP address for docker with Network CIDR."
  type        = string
  default     = "172.16.0.1/16"
}

variable "nodes_pools" {
  description = "A list of nodes pools to create, each item supports same properties as `local.default_agent_profile`"
  type        = list(any)
  default     = []
}

variable "container_registries_id" {
  description = "List of Azure Container Registries ids where AKS needs pull access."
  type        = list(string)
  default     = []
}

variable "key_vault_secrets_provider" {
  description = "Enable AKS built-in Key Vault secrets provider. If enabled, an identity is created by the AKS itself and exported from this module."
  type = object({
    secret_rotation_enabled  = optional(bool)
    secret_rotation_interval = optional(string)
  })
  default = null
}

##########################
# AGIC variables
##########################
variable "agic_enabled" {
  description = "Enable Application gateway ingress controller"
  type        = bool
  default     = true
}

variable "use_existing_application_gateway" {
  description = <<DESC
True to use an existing Application Gateway instead of creating a new one.
If true you may use `appgw_ingress_controller_values = { appgw.shared = true }` to tell AGIC to not erase the whole Application Gateway configuration with its own configuration.
You also have to deploy AzureIngressProhibitedTarget CRD.
https://github.com/Azure/application-gateway-kubernetes-ingress/blob/072626cb4e37f7b7a1b0c4578c38d1eadc3e8701/docs/setup/install-existing.md#multi-cluster--shared-app-gateway
DESC
  type        = bool
  default     = false
}

variable "application_gateway_id" {
  description = "ID of an existing Application Gateway to use as an AGIC. `use_existing_application_gateway` must be set to `true`."
  type        = string
  default     = null
}

variable "agic_helm_version" {
  description = "[DEPRECATED] Version of Helm chart to deploy"
  type        = string
  default     = null
}

variable "agic_chart_repository" {
  description = "Helm chart repository URL"
  type        = string
  default     = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"
}

variable "agic_chart_version" {
  description = "Version of the Helm chart"
  type        = string
  default     = "1.5.2"
}

variable "custom_appgw_name" {
  description = "Custom name for AKS ingress application gateway"
  type        = string
  default     = ""
}

variable "appgw_subnet_id" {
  description = "Application gateway subnet id"
  type        = string
  default     = ""
}

variable "appgw_ingress_controller_values" {
  description = "Application Gateway Ingress Controller settings"
  type        = map(string)
  default     = {}
}

variable "appgw_settings" {
  description = "Application gateway configuration settings. Default dummy configuration"
  type        = map(any)
  default     = {}
}

variable "appgw_ssl_certificates_configs" {
  description = "Application gateway ssl certificates configuration"
  type        = list(map(string))
  default     = []
}

##########################
# Cert Manager variables
##########################
variable "enable_cert_manager" {
  description = "Enable cert-manager on AKS cluster"
  type        = bool
  default     = true
}
variable "cert_manager_settings" {
  description = "Settings for cert-manager helm chart"
  type        = map(string)
  default     = {}
}

variable "cert_manager_namespace" {
  description = "Kubernetes namespace in which to deploy Cert Manager"
  type        = string
  default     = "system-cert-manager"
}

variable "cert_manager_chart_repository" {
  description = "Helm chart repository URL"
  type        = string
  default     = "https://charts.jetstack.io"
}

variable "cert_manager_chart_version" {
  description = "Cert Manager helm chart version to use"
  type        = string
  default     = "v1.8.0"
}

##########################
# Kured variables
##########################
variable "enable_kured" {
  description = "Enable kured daemon on AKS cluster"
  type        = bool
  default     = true
}

variable "kured_chart_repository" {
  description = "Helm chart repository URL"
  type        = string
  default     = "https://kubereboot.github.io/charts"
}

variable "kured_chart_version" {
  description = "Version of the Helm chart"
  type        = string
  default     = "2.2.0"
}

variable "kured_settings" {
  description = <<EODK
Settings for kured helm chart:

```
map(object({
  image.repository         = string
  image.tag                = string
  image.pullPolicy         = string
  extraArgs.reboot-days    = string
  extraArgs.start-time     = string
  extraArgs.end-time       = string
  extraArgs.time-zone      = string
  rbac.create              = string
  podSecurityPolicy.create = string
  serviceAccount.create    = string
  autolock.enabled         = string
}))
```
EODK
  type        = map(string)
  default     = {}
}

##########################
# Velero variables
##########################
variable "enable_velero" {
  description = "Enable velero on AKS cluster"
  type        = bool
  default     = true
}

variable "velero_identity_custom_name" {
  description = "Name of the Velero MSI"
  type        = string
  default     = "velero"
}

variable "velero_storage_settings" {
  description = "Settings for Storage account and blob container for Velero"
  default     = {}
  type = object({
    name                     = optional(string)
    resource_group_name      = optional(string)
    location                 = optional(string)
    account_tier             = optional(string)
    account_replication_type = optional(string)
    tags                     = optional(map(any))
    allowed_cidrs            = optional(list(string))
    allowed_subnet_ids       = optional(list(string))
    container_name           = optional(string)
  })
}

variable "velero_values" {
  description = <<EOVV
Settings for Velero helm chart:

```
map(object({
  configuration.backupStorageLocation.bucket                = string
  configuration.backupStorageLocation.config.resourceGroup  = string
  configuration.backupStorageLocation.config.storageAccount = string
  configuration.backupStorageLocation.name                  = string
  configuration.provider                                    = string
  configuration.volumeSnapshotLocation.config.resourceGroup = string
  configuration.volumeSnapshotLocation.name                 = string
  credential.exstingSecret                                  = string
  credentials.useSecret                                     = string
  deployRestic                                              = string
  env.AZURE_CREDENTIALS_FILE                                = string
  metrics.enabled                                           = string
  rbac.create                                               = string
  schedules.daily.schedule                                  = string
  schedules.daily.template.includedNamespaces               = string
  schedules.daily.template.snapshotVolumes                  = string
  schedules.daily.template.ttl                              = string
  serviceAccount.server.create                              = string
  snapshotsEnabled                                          = string
  initContainers[0].name                                    = string
  initContainers[0].image                                   = string
  initContainers[0].volumeMounts[0].mountPath               = string
  initContainers[0].volumeMounts[0].name                    = string
  image.repository                                          = string
  image.tag                                                 = string
  image.pullPolicy                                          = string
}))
```
EOVV
  type        = map(string)
  default     = {}
}

variable "velero_namespace" {
  description = "Kubernetes namespace in which to deploy Velero"
  type        = string
  default     = "system-velero"
}

variable "velero_chart_version" {
  description = "Velero helm chart version to use"
  type        = string
  default     = "2.29.5"
}

variable "velero_chart_repository" {
  description = "URL of the Helm chart repository"
  type        = string
  default     = "https://vmware-tanzu.github.io/helm-charts"
}

##########################
# AAD Pod Identity variables
##########################
variable "aadpodidentity_values" {
  description = <<EOD
Settings for AAD Pod identity helm Chart:

```
map(object({
  nmi.nodeSelector.agentpool    = string
  mic.nodeSelector.agentpool    = string
  azureIdentity.enabled         = bool
  azureIdentity.type            = string
  azureIdentity.resourceID      = string
  azureIdentity.clientID        = string
  nmi.micNamespace              = string
}))
```
EOD
  type        = map(string)
  default     = {}
}

variable "aadpodidentity_namespace" {
  description = "Kubernetes namespace in which to deploy AAD Pod Identity"
  type        = string
  default     = "system-aadpodid"
}

variable "aadpodidentity_chart_repository" {
  description = "AAD Pod Identity Helm chart repository URL"
  type        = string
  default     = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
}

variable "aadpodidentity_chart_version" {
  description = "AAD Pod Identity helm chart version to use"
  type        = string
  default     = "4.1.9"
}

variable "aadpodidentity_kubenet_policy_enabled" {
  description = <<EOD
  Boolean to wether deploy or not a built-in Azure Policy at the cluster level
  to mitigate potential security issue with aadpodidentity used with kubenet :
  https://docs.microsoft.com/en-us/azure/aks/use-azure-ad-pod-identity#using-kubenet-network-plugin-with-azure-active-directory-pod-managed-identities "
EOD
  type        = bool
  default     = false
}

variable "private_ingress" {
  description = "Private ingress boolean variable. When `true`, the default http listener will listen on private IP instead of the public IP."
  type        = bool
  default     = false
}

variable "appgw_private_ip" {
  description = "Private IP for Application Gateway. Used when variable `private_ingress` is set to `true`."
  type        = string
  default     = null
}
