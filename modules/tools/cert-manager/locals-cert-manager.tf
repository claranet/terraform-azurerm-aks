locals {
  cert_manager_default_values = {}

  cert_manager_values = merge(local.cert_manager_default_values, var.cert_manager_settings)
}