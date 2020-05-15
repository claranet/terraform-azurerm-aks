resource "kubernetes_namespace" "agic" {
  count = var.enable_agic ? 1 : 0
  metadata {
    name   = "system-agic"
    labels = {
      deployed-by = "Terraform"
    }
  }
}

#resource "azurerm_role_assignment" "agic" {
#  count                = var.enable_agic ? 1 : 0
#  principal_id         = var.aks_aad_pod_identity_principal_id
#  scope                = azurerm_application_gateway.app_gateway.0.id
#  role_definition_name = "Contributor"
#}

data "azurerm_resource_group" "appgw-rg" {
  count = var.enable_agic ? 1 : 0
  name  = var.rg_name
}

resource "azurerm_role_assignment" "agic-rg" {
  count                = var.enable_agic ? 1 : 0
  principal_id         = var.aks_aad_pod_identity_principal_id
  scope                = data.azurerm_resource_group.appgw-rg.0.id
  role_definition_name = "Reader"
}

data "azurerm_subscription" "current" {
  count = var.enable_agic ? 1 : 0
}

resource "helm_release" "agic" {
  count      = var.enable_agic ? 1 : 0
  #  depends_on = [null_resource.install_crd, azurerm_role_assignment.agic, azurerm_role_assignment.agic-rg,
  #    azurerm_application_gateway.app_gateway]
  name       = "ingress-azure"
  repository = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"
  chart      = "ingress-azure"
  namespace  = kubernetes_namespace.agic.0.metadata.0.name
  version    = "1.0.0"


  dynamic "set" {
    for_each = local.appgw_ingress_settings
    iterator = setting
    content {
      name  = setting.key
      value = setting.value
    }
  }
}

resource "random_string" "kube-config-file-name" {
  count   = var.enable_agic ? 1 : 0
  length  = 10
  special = false
}

// FIXME https://github.com/Azure/application-gateway-kubernetes-ingress/issues/720
resource "null_resource" "install_crd" {
  count = var.enable_agic ? 1 : 0
  // Get AKS Credentials
  provisioner "local-exec" {
    command = "az aks get-credentials --subscription ${data.azurerm_subscription.current.0.subscription_id} --resource-group ${var.rg_name} --name ${var.aks_name} --admin -f /tmp/${random_string.kube-config-file-name.0.result} --overwrite-existing"
  }

  provisioner "local-exec" {
    command     = "KUBECONFIG=/tmp/${random_string.kube-config-file-name.0.result} kubectl apply -f https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/crds/AzureIngressProhibitedTarget.yaml"
    interpreter = ["bash", "-c"]
  }
}