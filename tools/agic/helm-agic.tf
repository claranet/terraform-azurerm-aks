resource "kubernetes_namespace" "agic" {
  count = var.agic_enabled ? 1 : 0
  metadata {
    name = "system-agic"
    labels = {
      deployed-by = "Terraform"
    }
  }
}

resource "azurerm_role_assignment" "agic" {
  count                = var.agic_enabled ? 1 : 0
  principal_id         = var.aks_aad_pod_identity_principal_id
  scope                = try(azurerm_application_gateway.app_gateway[0].id, var.application_gateway_id)
  role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "agic_rg" {
  count                = var.agic_enabled ? 1 : 0
  principal_id         = var.aks_aad_pod_identity_principal_id
  scope                = data.azurerm_resource_group.resource_group[0].id
  role_definition_name = "Reader"
}


resource "helm_release" "agic" {
  count = var.agic_enabled ? 1 : 0
  depends_on = [
    azurerm_role_assignment.agic,
    azurerm_role_assignment.agic_rg,
    azurerm_application_gateway.app_gateway
  ]
  name       = "ingress-azure"
  repository = var.agic_chart_repository
  chart      = "ingress-azure"
  namespace  = kubernetes_namespace.agic[0].metadata[0].name
  version    = coalesce(var.agic_helm_version, var.agic_chart_version)


  dynamic "set" {
    for_each = local.appgw_ingress_settings
    iterator = setting
    content {
      name  = setting.key
      value = setting.value
    }
  }
}
