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

variable "extra_tags" {
  description = "Extra tags to add"
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Name of the AKS resource group"
  type        = string
}

variable "resource_group_id" {
  description = "Id of the AKS resource group"
  type        = string
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to deploy"
  type        = string
  default     = "1.15.7"
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
Default node pool configuration. <br />
<pre>map(object({ <br />
    name                  = string<br />
    count                 = number<br />
    vm_size               = string<br />
    os_type               = string<br />
    availability_zones    = list(number)<br />
    enable_auto_scaling   = bool<br />
    min_count             = number<br />
    max_count             = number<br />
    type                  = string<br />
    node_taints           = list(string)<br />
    vnet_subnet_id        = string<br />
    max_pods              = number<br />
    os_disk_size_gb       = number<br />
    enable_node_public_ip = bool<br />
}))<br /></pre>
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

variable "service_principal" {
  description = "Service principal used by AKS to interract with Azure API"
  type = object({
    client_id     = string,
    client_secret = string,
    object_id     = string
  })
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
  description = "CIDR of service subnet. If subnet has UDR make sure this is routed correctly"
  type        = string

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

#
# APPGW
#

variable "enable_agic" {
  description = "Enable Application gateway ingress controller"
  type        = bool
  default     = true
}

variable "custom_appgw_name" {
  description = "Custom name for AKS ingress application gateway"
  type        = string
  default     = ""
}

variable "appgw_subnet_id" {
  description = "Application gateway subnet id"
  type        = string
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

variable "cert_manager_chart_version" {
  description = "Cert Manager helm chart version to use"
  type        = string
  default     = "v0.13.0"
}

variable "enable_kured" {
  description = "Enable kured daemon on AKS cluster"
  type        = bool
  default     = true
}
variable "kured_settings" {
  description = <<EODK
Settings for kured helm chart <br />
<pre>
map(object({ <br />
  image.repository         = string <br />
  image.tag                = string <br />
  image.pullPolicy         = string <br />
  extraArgs.reboot-days    = string <br />
  extraArgs.start-time     = string <br />
  extraArgs.end-time       = string <br />
  extraArgs.time-zone      = string <br />
  rbac.create              = string <br />
  podSecurityPolicy.create = string <br />
  serviceAccount.create    = string <br />
  autolock.enabled         = string <br />
}))<br />
</pre>
EODK
  type        = map(string)
  default     = {}
}

variable "enable_velero" {
  description = "Enable velero on AKS cluster"
  type        = bool
  default     = true
}

variable "velero_storage_settings" {
  description = <<EOVS
Settings for Storage account and blob container for Velero <br />
<pre>
map(object({ <br />
  name                     = string <br />
  resource_group_name      = string <br />
  location                 = string <br />
  account_tier             = string <br />
  account_replication_type = string <br />
  tags                     = map(any) <br />
  allowed_cirds            = list(string) <br />
  container_name           = string <br />
}))<br />
</pre>
EOVS
  type        = map(any)
  default     = {}
}

variable "velero_values" {
  description = <<EOVV
Settings for Velero helm chart

<pre>
map(object({ <br />
  configuration.backupStorageLocation.bucket                = string <br />
  configuration.backupStorageLocation.config.resourceGroup  = string <br />
  configuration.backupStorageLocation.config.storageAccount = string <br />
  configuration.backupStorageLocation.name                  = string <br />
  configuration.provider                                    = string <br />
  configuration.volumeSnapshotLocation.config.resourceGroup = string <br />
  configuration.volumeSnapshotLocation.name                 = string <br />
  credential.exstingSecret                                  = string <br />
  credentials.useSecret                                     = string <br />
  deployRestic                                              = string <br />
  env.AZURE_CREDENTIALS_FILE                                = string <br />
  metrics.enabled                                           = string <br />
  rbac.create                                               = string <br />
  schedules.daily.schedule                                  = string <br />
  schedules.daily.template.includedNamespaces               = string <br />
  schedules.daily.template.snapshotVolumes                  = string <br />
  schedules.daily.template.ttl                              = string <br />
  serviceAccount.server.create                              = string <br />
  snapshotsEnabled                                          = string <br />
  initContainers[0].name                                    = string <br />
  initContainers[0].image                                   = string <br />
  initContainers[0].volumeMounts[0].mountPath               = string <br />
  initContainers[0].volumeMounts[0].name                    = string <br />
  image.repository                                          = string <br />
  image.tag                                                 = string <br />
  image.pullPolicy                                          = string <br />

}))<br />
</pre>
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
  default     = "2.7.3"
}

variable "aadpodidentity_values" {
  description = <<EOD
Settings for AAD Pod identity helm Chart <br />
<pre>map(object({ <br />
  nmi.nodeSelector.agentpool  = string <br />
  mic.nodeSelector.agentpool  = string <br />
  azureIdentity.enabled       = bool <br />
  azureIdentity.type          = string <br />
  azureIdentity.resourceID    = string <br />
  azureIdentity.clientID      = string <br />
  nmi.micNamespace            = string <br />
}))<br />
</pre>
EOD
  type        = map(string)
  default     = {}
}

variable "aadpodidentity_namespace" {
  description = "Kubernetes namespace in which to deploy AAD Pod Identity"
  type        = string
  default     = "system-aadpodid"
}

variable "aadpodidentity_chart_version" {
  description = "AAD Pod Identity helm chart version to use"
  type        = string
  default     = "1.5.5"
}

variable "name_prefix" {
  description = "prefix used in naming"
  type        = string
  default     = ""
}