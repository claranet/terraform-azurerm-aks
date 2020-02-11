locals {
  cert_manager_default_settings = {}

  cert_manager_settings = merge(local.cert_manager_default_settings, var.cert_manager_settings)
}