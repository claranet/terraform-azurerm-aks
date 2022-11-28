# Generic naming variables
variable "name_prefix" {
  description = "Optional prefix for the generated name"
  type        = string
  default     = ""
}

variable "name_suffix" {
  description = "Optional suffix for the generated name"
  type        = string
  default     = ""
}

variable "use_caf_naming" {
  description = "Use the Azure CAF naming provider to generate default resource name. `custom_aks_name` override this if set. Legacy default name is used if this is set to `false`."
  type        = bool
  default     = true
}

# Custom naming override
variable "name" {
  description = "Name of the application gateway."
  type        = string
}

variable "ip_name" {
  description = "Name of the applications gateway's public ip address"
  type        = string
}

variable "frontend_ip_configuration_name" {
  description = "Name of the appgw frontend ip configuration."
  type        = string
}

variable "gateway_ip_configuration_name" {
  description = "Name of the appgw gateway ip configuration."
  type        = string
}

variable "frontend_priv_ip_configuration_name" {
  description = "Name of the appgw frontend private ip configuration."
  type        = string
  default     = null
}
