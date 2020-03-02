# Common inputs
variable "location_short" {
  description = "Short name of Azure regions to use"
}

variable "client_name" {
  description = "Client name/account used in naming"
  type        = string
}

variable "location" {}

variable "rg_name" {}

# Network inputs

variable "ip_name" {}

variable "ip_tags" {
  type = map(string)
}

variable "ip_label" {}

variable "ip_sku" {
  type    = string
  default = "Standard"
}

variable "ip_allocation_method" {
  type    = string
  default = "Dynamic"
}

variable "app_gateway_subnet_id" {}

# Application gateway inputs

variable "name" {}

variable "sku_capacity" {}

variable "sku_name" {}

variable "sku_tier" {}

variable "zones" {}

variable "frontend_ip_configuration_name" {
  type = string
}

variable "gateway_ip_configuration_name" {
  type = string
}

variable "frontend_port_settings" {
  type = list(map(string))
}

variable "firewall_mode" {
  type    = string
  default = "Detection"
}

variable "disabled_rule_group_settings" {
  type = list(object({
    rule_group_name = string
    rules           = list(string)
  }))
  default = []
}

variable "waf_exclusion_settings" {
  type    = list(map(string))
  default = []
}

variable "policy_name" {
  type    = string
  default = "AppGwSslPolicy20170401S"
}

variable "authentication_certificate_configs" {
  type        = list(map(string))
  description = "List of maps including authentication certificate configurations"
  default     = []
}

variable "trusted_root_certificate_configs" {
  type        = list(map(string))
  description = ""
  default     = []
}

variable "appgw_backend_pools" {
  type        = any
  description = "List of maps including backend pool configurations"
}

variable "appgw_http_listeners" {
  type        = list(map(string))
  description = "List of maps including http listeners configurations"
}

variable "ssl_certificates_configs" {
  type        = list(map(string))
  description = "List of maps including ssl certificates configurations"
}

variable "appgw_routings" {
  type        = list(map(string))
  description = "List of maps including request routing rules configurations"
}

variable "appgw_probes" {
  type        = any
  description = "List of maps including request probes configurations"
}

variable "appgw_backend_http_settings" {
  type        = any
  description = "List of maps including backend http settings configurations"
}

variable "appgw_url_path_map" {
  type        = any
  description = "List of maps including url path map configurations"
  default     = []
}

variable "appgw_redirect_configuration" {
  type        = list(map(string))
  description = "List of maps including redirect configurations"
  default     = []
}

variable "appgw_rewrite_rule_set" {
  type        = any
  description = "TODO"
  default     = []
}

variable "app_gateway_tags" {
  type = map(string)
}

variable "environment" {}

variable "stack" {}

variable "enabled_waf" {
  default = true
}

variable "file_upload_limit_mb" {
  default = 100
}

variable "max_request_body_size_kb" {
  default = 128
}

variable "request_body_check" {
  default = "true"
}

variable "rule_set_type" {
  default = "OWASP"
}

variable "rule_set_version" {
  default = "3.0"
}

variable "appgw_ingress_values" {
  description = "Application Gateway Ingress Controller settings"
  type        = map(string)
  default     = {}
}

variable "aks_aad_pod_identity_id" {
  description = "AAD Identity id used by AKS"
  type        = string
}

variable "aks_aad_pod_identity_client_id" {
  description = "AAD Identity client_id used by AKS"
  type        = string
}

variable "aks_aad_pod_identity_principal_id" {
  description = "AAD Identity principal_id used by AKS"
  type        = string
}

variable "aks_name" {
  description = "Name of the AKS Cluster attached to this APPGW"
  type        = string
}

variable "diagnostics" {
  description = "Enable diagnostics logs on AKS"
  type = object({
    enabled       = bool,
    destination   = string,
    eventhub_name = string,
    logs          = list(string),
    metrics       = list(string)
  })
}

variable "name_prefix" {
  description = "(Optional) prefix used in naming"
  type        = string
  default     = ""
}

variable "diag_custom_name" {
  description = "(Optional) Custom name for Azure Diagnostics for AKS."
  type        = string
  default     = null
}

variable "enable_agic" {
  description = "(Optional) Enable application gateway ingress controller"
  type        = bool
  default     = true
}