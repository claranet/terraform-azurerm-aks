data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "aks_rg" {
  name = var.resource_group_name
}
