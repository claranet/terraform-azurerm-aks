resource "kubernetes_namespace" "add_pod_identity" {
  metadata {
    name = "system-aadpodid"
    labels = {
      deployed-by = "Terraform"
    }
  }
}

data "helm_repository" "add_pod_identity" {
  name = "aad-pod-identity"
  url  = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
}

resource "helm_release" "aad_pod_identity" {
  name       = "aad-pod-identity"
  repository = data.helm_repository.add_pod_identity.metadata.0.name
  chart      = "aad-pod-identity"
  version    = "1.5.5"
  namespace  = kubernetes_namespace.add_pod_identity.metadata.0.name

  set {
    name  = "nmi.nodeSelector.agentpool"
    value = "default"
  }

  set {
    name  = "mic.nodeSelector.agentpool"
    value = "default"
  }

  set {
    name  = "azureIdentity.enabled"
    value = "true"
  }

  set {
    name  = "azureIdentity.type"
    value = "0"
    # Identity
  }

  set {
    name  = "azureIdentity.resourceID"
    value = azurerm_user_assigned_identity.aad_pod_identity.id
  }

  set {
    name  = "azureIdentity.clientID"
    value = azurerm_user_assigned_identity.aad_pod_identity.client_id
  }

  set {
    name  = "nmi.micNamespace"
    value = kubernetes_namespace.add_pod_identity.metadata.0.name
  }
}