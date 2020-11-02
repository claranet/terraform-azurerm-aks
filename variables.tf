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

variable "custom_aks_name" {
  description = "Custom AKS name"
  type        = string
  default     = ""
}

variable "name_prefix" {
  description = "Prefix used in naming"
  type        = string
  default     = ""
}

variable "extra_tags" {
  description = "Extra tags to add"
  type        = map(string)
  default     = {}
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

variable "default_node_pool" {
  description = <<EOD
Default node pool configuration:

```
map(object({
    name                  = string
    count                 = number
    vm_size               = string
    os_type               = string
    availability_zones    = list(number)
    enable_auto_scaling   = bool
    min_count             = number
    max_count             = number
    type                  = string
    node_taints           = list(string)
    vnet_subnet_id        = string
    max_pods              = number
    os_disk_size_gb       = number
    enable_node_public_ip = bool
}))
```

EOD

  type    = map(any)
  default = {}
}

variable "nodes_subnet_id" {
  description = "Id of the subnet used for nodes"
  type        = string
}

variable "vnet_id" {
  description = "Id of the vnet used for AKS"
  type        = string
}

variable "addons" {
  description = "Kubernetes addons to enable /disable"
  type = object({
    dashboard              = bool,
    oms_agent              = bool,
    oms_agent_workspace_id = string,
    policy                 = bool
  })
  default = {
    dashboard              = false,
    oms_agent              = true,
    oms_agent_workspace_id = null,
    policy                 = false
  }
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

}

variable "container_registries" {
  description = "List of Azure Container Registries ids where AKS needs pull access."
  type        = list(string)
  default     = []
}

variable "storage_contributor" {
  description = "List of storage accounts ids where the AKS service principal should have access."
  type        = list(string)
  default     = []
}

variable "managed_identities" {
  description = "List of managed identities where the AKS service principal should have access."
  type        = list(string)
  default     = []
}

variable "diagnostics" {
  description = "Enable and configure diagnostics logs on AKS."
  type = object({
    enabled       = bool,
    destination   = string,
    eventhub_name = string,
    logs          = list(string),
    metrics       = list(string)
  })
}

variable "diag_custom_name" {
  description = "Custom name for Azure Diagnostics for AKS."
  type        = string
  default     = null
}

##########################
# AGIC variables
##########################
variable "enable_agic" {
  description = "Enable Application gateway ingress controller"
  type        = bool
  default     = true
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
  default     = "1.2.0"
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
  default     = "v0.13.0"
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
  default     = "https://weaveworks.github.io/kured"
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

variable "velero_storage_settings" {
  description = <<EOVS
Settings for Storage account and blob container for Velero
```
map(object({ 
  name                     = string 
  resource_group_name      = string 
  location                 = string 
  account_tier             = string 
  account_replication_type = string 
  tags                     = map(any) 
  allowed_cidrs            = list(string) 
  container_name           = string 
}))
```
EOVS
  type        = map(any)
  default     = {}
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
  default     = "2.12.13"
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
  nmi.nodeSelector.agentpool  = string 
  mic.nodeSelector.agentpool  = string 
  azureIdentity.enabled       = bool 
  azureIdentity.type          = string 
  azureIdentity.resourceID    = string 
  azureIdentity.clientID      = string 
  nmi.micNamespace            = string 
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
  default     = "2.0.0"
}

