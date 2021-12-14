resource "azurerm_role_assignment" "aks_uai_route_table_contributor" {
  count = var.aks_network_plugin == "kubenet" && var.outbound_type == "userDefinedRouting" ? 1 : 0

  scope                = var.aks_route_table_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_user_assigned_identity.principal_id
}
