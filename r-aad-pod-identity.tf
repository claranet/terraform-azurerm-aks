resource "kubernetes_namespace" "add_pod_identity" {
  metadata {
    name = local.aadpodidentity_values.namespace
    labels = {
      deployed-by = "Terraform"
    }
  }
}

resource "helm_release" "aad_pod_identity" {
  name       = "aad-pod-identity"
  repository = data.helm_repository.add_pod_identity.metadata.0.name
  chart      = "aad-pod-identity"
  version    = local.aadpodidentity_values.chart_version
  namespace  = kubernetes_namespace.add_pod_identity.metadata.0.name

  dynamic "set" {
    for_each = local.aadpodidentity_values
    iterator = setting
    content {
      name  = setting.key
      value = setting.value
    }
  }
}