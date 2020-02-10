# Common inputs

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
  default = "Basic"
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