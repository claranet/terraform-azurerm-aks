variable "aadpodidentity_custom_name" {
  description = "Custom name for aad pod identity MSI"
  type        = string
  default     = "aad-pod-identity"
}

variable "custom_aks_name" {
  description = "Custom AKS name"
  type        = string
  default     = ""
}

variable "aks_user_assigned_identity_custom_name" {
  description = "Custom name for the aks user assigned identity resource"
  type        = string
  default     = null
}

variable "appgw_user_assigned_identity_custom_name" {
  description = "Custom name for the application gateway user assigned identity resource"
  type        = string
  default     = null
}
