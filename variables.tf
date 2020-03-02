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
map(object({ <br />
    name                  = Name of the pool. Default is default.<br />
    count                 = Number of nodes to add in the pool. Default is 1<br />
    vm_size               = VM Size. Default is Standard_D2_V3<br />
    os_type               = Os Type (Linux | Windows). Default is Linux<br />
    availability_zones    = Availability zone to use. Default [1, 2, 3]<br />
    enable_auto_scaling   = Enable or not AutoScaling. Default to false<br />
    min_count             = Minimum nodes to have in pool. Used only when autoscaling is True. Default is null<br />
    max_count             = Maximum nodes to have in pool. Used only when autoscaling is True. Default is null<br />
    type                  = Type of nodes. (AvailabilitySet | VirtualMachineScaleSets) Default is Virtual MachineScaleSets<br />
    node_taints           = A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Default is null<br />
    vnet_subnet_id        = Subnet to use with the node pool. Default is nodes_subnet_id variable result.<br />
    max_pods              = Maximum number of pod per host in the node pool. Default to 30<br />
    os_disk_size_gb       = Size in GB of nodes os disk. Default to 32<br />
    enable_node_public_ip = Allocate public IP to each node in pool or not. Default is False<br />
}))<br />
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

variable "service_accounts" {
  description = "List of service accounts to create and their roles."
  type = list(object({
    name      = string,
    namespace = string,
    role      = string
  }))
  default = []
}

#
# APPGW
#

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
  description = "Settings for kured helm chart"
  type        = map(string)
  default     = {}
}

variable "enable_velero" {
  description = "Enable velero on AKS cluster"
  type        = bool
  default     = true
}

variable "velero_storage_settings" {
  description = "Settings for Storage account and blob container for Velero"
  type        = map(any)
  default     = {}
}

variable "velero_values" {
  description = "Settings for Velero helm chart"
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
  description = "Settings for AAD Pod identity helm Chart"
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

variable "appgw_settings" {
  description = "Application gateway configuration settings. Default dummy configuration"
  type        = map(any)
  default     = {}
}

variable "name_prefix" {
  description = "prefix used in naming"
  type        = string
  default     = ""
}

variable "enable_agic" {
  description = "Enable application ingres controller"
  type        = bool
  default     = true
}