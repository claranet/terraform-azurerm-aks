locals {
  cert_manager_default_values = {
    "installCRDs" = "true"
  }

  cert_manager_values = merge(local.cert_manager_default_values, var.cert_manager_settings)
}
