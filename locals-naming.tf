locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  aks_name            = coalesce(var.custom_aks_name, data.azurecaf_name.aks.result)
  aks_identity_name   = coalesce(var.aks_user_assigned_identity_custom_name, data.azurecaf_name.aks_identity.result)
  appgw_identity_name = coalesce(var.appgw_user_assigned_identity_custom_name, data.azurecaf_name.appgw_identity.result)

  appgw_name = coalesce(var.custom_appgw_name, data.azurecaf_name.appgw.result)
}
