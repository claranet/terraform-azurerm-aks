data "azurerm_subscription" "current" {}

resource "kubernetes_namespace" "add_pod_identity" {
  metadata {
    name = var.aadpodidentity_namespace
    labels = {
      deployed-by = "Terraform"
    }
  }
}

resource "helm_release" "aad_pod_identity" {
  name       = "aad-pod-identity"
  repository = var.aadpodidentity_chart_repository
  chart      = "aad-pod-identity"
  version    = var.aadpodidentity_chart_version
  namespace  = kubernetes_namespace.add_pod_identity.metadata[0].name

  dynamic "set" {
    for_each = local.aadpodidentity_values
    iterator = setting
    content {
      name  = setting.key
      value = setting.value
    }
  }

  # If `Aadpodidentity` is used within an Aks Cluster with Kubenet network Plugin,
  # `nmi.allowNetworkPluginKubenet` parameter is set to `true`.
  # https://github.com/Azure/aad-pod-identity/issues/949
  set {
    name  = "nmi.allowNetworkPluginKubenet"
    value = var.aks_network_plugin == "kubenet" ? "true" : "false"
  }
}

resource "azurerm_user_assigned_identity" "aad_pod_identity" {
  location            = var.location
  name                = var.aadpodidentity_custom_name
  resource_group_name = var.aks_resource_group_name

  tags = var.aadpodidentity_extra_tags
}

resource "azurerm_role_assignment" "aad_pod_identity_msi" {
  scope                = format("/subscriptions/%s/resourceGroups/%s", data.azurerm_subscription.current.subscription_id, var.aks_resource_group_name)
  principal_id         = azurerm_user_assigned_identity.aad_pod_identity.principal_id
  role_definition_name = "Managed Identity Operator"
}
