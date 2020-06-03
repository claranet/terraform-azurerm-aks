resource "kubernetes_namespace" "agic" {
  count = var.enable_agic ? 1 : 0
  metadata {
    name = "system-agic"
    labels = {
      deployed-by = "Terraform"
    }
  }
}

resource "azurerm_role_assignment" "agic" {
  count                = var.enable_agic ? 1 : 0
  principal_id         = var.aks_aad_pod_identity_principal_id
  scope                = azurerm_application_gateway.app_gateway.0.id
  role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "agic-rg" {
  count                = var.enable_agic ? 1 : 0
  principal_id         = var.aks_aad_pod_identity_principal_id
  scope                = var.resource_group_id
  role_definition_name = "Reader"
}


resource "helm_release" "agic" {
  count = var.enable_agic ? 1 : 0
  depends_on = [
    azurerm_role_assignment.agic,
    azurerm_role_assignment.agic-rg,
  azurerm_application_gateway.app_gateway]
  name       = "ingress-azure"
  repository = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"
  chart      = "ingress-azure"
  namespace  = kubernetes_namespace.agic.0.metadata.0.name
  version    = var.agic_helm_version


  dynamic "set" {
    for_each = local.appgw_ingress_settings
    iterator = setting
    content {
      name  = setting.key
      value = setting.value
    }
  }
}