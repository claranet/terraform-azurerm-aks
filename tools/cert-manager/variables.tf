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
  default     = "v1.8.0"
}
