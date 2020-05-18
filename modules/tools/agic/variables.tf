# Common inputs
variable "location_short" {
  description = "Short name of Azure regions to use"
}

variable "client_name" {
  description = "Client name/account used in naming"
  type        = string
}

variable "location" {
  description = "Location of application gateway"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to deploy the application gateway"
  type        = string
}

variable "resource_group_id" {
  description = "Id of the resource group used to deploy the application gateway"
  type        = string
}
# Network inputs

variable "ip_name" {
  description = "Name of the applications gateway's public ip address"
  type        = string
}

variable "ip_tags" {
  description = "Specific tags for the public ip address"
  type        = map(string)
}

variable "ip_label" {
  description = "Domain name for the public ip address"
  type        = string
}

variable "ip_sku" {
  description = "SKU of the public ip address"
  type        = string
  default     = "Standard"
}

variable "ip_allocation_method" {
  description = "Allocation method of the IP address"
  type        = string
  default     = "Dynamic"
}

variable "app_gateway_subnet_id" {
  description = "ID of the subnet to use with the application gateway"
  type        = string
}

# Application gateway inputs

variable "name" {
  description = "Name of the application gateway"
  type        = string
}

variable "sku_capacity" {
  description = "Application gateway's SKU capacity"
  type        = string
}

variable "sku_name" {
  description = "Application gateway's SKU name"
  type        = string
}

variable "sku_tier" {
  description = "Application gateway's SKU tier"
  type        = string
}

variable "zones" {
  description = "Application gateway's Zones to use"
  type        = list(string)
}

variable "frontend_ip_configuration_name" {
  description = "Name of the appgw frontend ip configuration"
  type        = string
}

variable "gateway_ip_configuration_name" {
  description = "Name of the appgw gateway ip configuration"
  type        = string
}

variable "frontend_port_settings" {
  description = "Appgw frontent port settings"
  type        = list(map(string))
}

variable "firewall_mode" {
  description = "Appgw WAF mode"
  type        = string
  default     = "Detection"
}

variable "disabled_rule_group_settings" {
  description = "Appgw WAF rules group to disable."
  type = list(object({
    rule_group_name = string
    rules           = list(string)
  }))
  default = []
}

variable "waf_exclusion_settings" {
  description = "Appgw WAF exclusion settings"
  type        = list(map(string))
  default     = []
}

variable "policy_name" {
  description = "Name of the SSLPolicy to use with Appgw"
  type        = string
  default     = "AppGwSslPolicy20170401S"
}

variable "authentication_certificate_configs" {
  type        = list(map(string))
  description = "List of maps including authentication certificate configurations"
  default     = []
}

variable "trusted_root_certificate_configs" {
  type        = list(map(string))
  description = "Trusted root certificate configurations"
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
  description = "Application gateway's rewrite rules"
  default     = []
}

variable "app_gateway_tags" {
  description = "Tags to apply on the Application gateway"
  type        = map(string)
}

variable "environment" {
  description = "Project's environment"
  type        = string
}

variable "stack" {
  description = "Project's stack"
  type        = string
}

# WAF Values
variable "enabled_waf" {
  description = "Enable WAF or not"
  type        = bool
  default     = true
}

variable "file_upload_limit_mb" {
  description = "WAF configuration of the file upload limit in MB"
  type        = number
  default     = 100
}

variable "max_request_body_size_kb" {
  description = "WAF configuration of the max request body size in KB"
  default     = 128
  type        = number
}

variable "request_body_check" {
  description = "WAF should check the request body"
  default     = true
  type        = bool
}

variable "rule_set_type" {
  description = "WAF rules set type"
  default     = "OWASP"
  type        = string
}

variable "rule_set_version" {
  description = "WAF rules set version"
  default     = "3.0"
  type        = string
}

# AGIC Values
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
  description = "prefix used in naming"
  type        = string
  default     = ""
}

variable "diag_custom_name" {
  description = "Custom name for Azure Diagnostics for AKS."
  type        = string
  default     = null
}

variable "enable_agic" {
  description = "Enable application gateway ingress controller"
  type        = bool
  default     = true
}
