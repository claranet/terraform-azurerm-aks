# Common inputs
variable "client_name" {
  description = "Client name/account used in naming"
  type        = string
}

variable "location" {
  description = "Location of application gateway."
  type        = string
}

variable "location_short" {
  description = "Short name of Azure regions to use."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to deploy the application gateway."
  type        = string
}

variable "environment" {
  description = "Project's environment."
  type        = string
}

variable "stack" {
  description = "Project's stack."
  type        = string
}


# Network inputs
variable "ip_tags" {
  description = "Specific tags for the public ip address."
  type        = map(string)
}

variable "ip_sku" {
  description = "SKU of the public ip address."
  type        = string
  default     = "Standard"
}

variable "ip_allocation_method" {
  description = "Allocation method of the IP address."
  type        = string
  default     = "Static"
}

variable "app_gateway_subnet_id" {
  description = "ID of the subnet to use with the application gateway."
  type        = string
}

# Application gateway inputs
variable "use_existing_application_gateway" {
  description = <<DESC
True to use an existing Application Gateway instead of creating a new one.
If true you may use appgw_ingress_controller_values = { appgw.shared = true } to tell AGIC to not erase the whole Application Gateway configuration with its own configuration.
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

variable "sku_capacity" {
  description = "Application gateway's SKU capacity."
  type        = string
  default     = 2
}

variable "sku_name" {
  description = "Application gateway's SKU name."
  type        = string
  default     = "Standard_v2"
}

variable "sku_tier" {
  description = "Application gateway's SKU tier."
  type        = string
  default     = "Standard_v2"
}

variable "zones" {
  description = "Application gateway's Zones to use."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "gateway_identity_id" {
  description = "Id of the application gateway MSI."
  type        = string
  default     = null
}

variable "frontend_port_settings" {
  description = "Appgw frontent port settings."
  type        = list(map(string))
  default = [{
    fake = "fake"
  }]
}

variable "firewall_mode" {
  description = "Appgw WAF mode."
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
  description = "Appgw WAF exclusion settings."
  type        = list(map(string))
  default     = []
}

variable "policy_name" {
  description = "Name of the SSLPolicy to use with Appgw."
  type        = string
  default     = "AppGwSslPolicy20170401S"
}

variable "authentication_certificate_configs" {
  type        = list(map(string))
  description = "List of maps including authentication certificate configurations."
  default     = []
}

variable "trusted_root_certificate_configs" {
  type        = list(map(string))
  description = "Trusted root certificate configurations."
  default     = []
}

variable "appgw_backend_pools" {
  type        = any
  description = "List of maps including backend pool configurations."
  default     = [{ fake = "fake" }]
}

variable "appgw_http_listeners" {
  type        = list(map(string))
  description = "List of maps including http listeners configurations."
  default     = [{ fake = "fake" }]
}

variable "ssl_certificates_configs" {
  type        = list(map(string))
  description = "List of maps including ssl certificates configurations."
  default     = []
}

variable "appgw_routings" {
  type        = list(map(string))
  description = "List of maps including request routing rules configurations."
  default     = [{ fake = "fake" }]
}

variable "appgw_probes" {
  type        = any
  description = "List of maps including request probes configurations."
  default = [
    {
      fake = "fake"
  }]
}

variable "appgw_backend_http_settings" {
  type        = any
  description = "List of maps including backend http settings configurations."
  default     = [{ fake = "fake" }]
}

variable "appgw_url_path_map" {
  type        = any
  description = "List of maps including url path map configurations."
  default     = []
}

variable "appgw_redirect_configuration" {
  type        = list(map(string))
  description = "List of maps including redirect configurations."
  default     = []
}

variable "appgw_rewrite_rule_set" {
  type        = any
  description = "Application gateway's rewrite rules"
  default     = []
}

variable "app_gateway_tags" {
  description = "Tags to apply on the Application gateway."
  type        = map(string)
}

# WAF Values
variable "enabled_waf" {
  description = "Enable WAF or not."
  type        = bool
  default     = false
}

variable "file_upload_limit_mb" {
  description = "WAF configuration of the file upload limit in MB."
  type        = number
  default     = 100
}

variable "max_request_body_size_kb" {
  description = "WAF configuration of the max request body size in KB."
  default     = 128
  type        = number
}

variable "request_body_check" {
  description = "WAF should check the request body."
  default     = true
  type        = bool
}

variable "rule_set_type" {
  description = "WAF rules set type."
  default     = "OWASP"
  type        = string
}

variable "rule_set_version" {
  description = "WAF rules set version."
  default     = "3.0"
  type        = string
}

# AGIC Values
variable "appgw_ingress_values" {
  description = "Application Gateway Ingress Controller settings."
  type        = map(string)
  default     = {}
}

variable "aks_aad_pod_identity_id" {
  description = "AAD Identity id used by AKS."
  type        = string
}

variable "aks_aad_pod_identity_client_id" {
  description = "AAD Identity client_id used by AKS."
  type        = string
}

variable "aks_aad_pod_identity_principal_id" {
  description = "AAD Identity principal_id used by AKS."
  type        = string
}

variable "agic_enabled" {
  description = "Enable application gateway ingress controller."
  type        = bool
  default     = true
}

variable "agic_helm_version" {
  description = "[DEPRECATED] Version of Helm chart to deploy."
  type        = string
  default     = null
}

variable "agic_chart_repository" {
  description = "Helm chart repository URL."
  type        = string
  default     = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"
}

variable "agic_chart_version" {
  description = "Version of the Helm chart."
  type        = string
  default     = "1.5.2"
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
