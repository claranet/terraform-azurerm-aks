variable "aks_resource_group_name" {
  description = "Name of the AKS Managed resource group. Eg MC_xxxx"
  type        = string
}

variable "aks_network_plugin" {
  description = <<EOD
  AKS network plugin to use. Possible values are `azure` and `kubenet`.
  Changing this forces a new resource to be created.
EOD
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "kubenet"], var.aks_network_plugin)
    error_message = "The network plugin value must be \"azure\" or \"kubenet\"."
  }
}

variable "location" {
  description = "AKS Cluster location"
  type        = string
}

variable "aadpodidentity_chart_repository" {
  description = "URL of the Helm chart repository"
  type        = string
  default     = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
}

variable "aadpodidentity_chart_version" {
  description = "Azure Active Directory Pod Identity Chart version"
  type        = string
  default     = "4.1.9"
}

variable "aadpodidentity_namespace" {
  description = "Kubernetes namespace in which to deploy AAD Pod Identity"
  type        = string
  default     = "system-aadpodid"
}

variable "aadpodidentity_custom_name" {
  description = "Custom name for aad pod identity MSI"
  type        = string
  default     = "aad-pod-identity"
}

variable "aadpodidentity_extra_tags" {
  description = "Extra tags to add to aad pod identity MSI"
  type        = map(string)
  default     = {}
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
