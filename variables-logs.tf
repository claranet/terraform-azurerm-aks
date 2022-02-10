variable "diagnostic_settings_custom_name" {
  description = "Custom name for Azure Diagnostics for AKS."
  type        = string
  default     = "default"
}

variable "diagnostic_settings_logs_destination_ids" {
  description = "List of destination resources IDs for logs diagnostic destination. Can be Storage Account, Log Analytics Workspace and Event Hub. No more than one of each can be set."
  type        = list(string)
  default     = []
}

variable "diagnostic_settings_retention_days" {
  description = "The number of days to keep diagnostic logs."
  type        = number
  default     = 30
}

variable "diagnostic_settings_log_categories" {
  description = "List of log categories"
  type        = list(string)
  default     = null
}

variable "diagnostic_settings_metric_categories" {
  description = "List of metric categories"
  type        = list(string)
  default     = null
}
