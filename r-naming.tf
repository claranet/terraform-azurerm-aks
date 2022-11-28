data "azurecaf_name" "aks" {
  name          = var.stack
  resource_type = "azurerm_kubernetes_cluster"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.client_name, var.location_short, var.environment, local.name_suffix, var.use_caf_naming ? "" : "aks"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

data "azurecaf_name" "aks_identity" {
  name          = var.stack
  resource_type = "azurerm_user_assigned_identity"
  prefixes      = compact(["aks", local.name_prefix])
  suffixes      = compact([var.client_name, var.location_short, var.environment, local.name_suffix, var.use_caf_naming ? "" : "identity"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

data "azurecaf_name" "appgw_identity" {
  name          = var.stack
  resource_type = "azurerm_user_assigned_identity"
  prefixes      = compact(["appgw", local.name_prefix])
  suffixes      = compact([var.client_name, var.location_short, var.environment, local.name_suffix, var.use_caf_naming ? "" : "identity"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

data "azurecaf_name" "appgw" {
  name          = var.stack
  resource_type = "azurerm_application_gateway"
  prefixes      = compact(["aks", local.name_prefix])
  suffixes      = compact([var.client_name, var.location_short, var.environment, local.name_suffix, var.use_caf_naming ? "" : "appgw"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}
