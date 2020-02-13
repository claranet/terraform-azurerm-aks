locals {
  cert_manager_default_values = {
    namespace     = "system-cert-manager"
    chart_version = "v1.13.0"
  }

  cert_manager_values = merge(local.cert_manager_default_values, var.cert_manager_settings)
}