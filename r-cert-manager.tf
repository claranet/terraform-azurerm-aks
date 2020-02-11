resource "kubernetes_namespace" "cert-manager" {
  count = var.enable_cert_manager ? 1 : 0
  metadata {
    name   = "system-cert-manager"
    labels = {
      deployed-by = "Terraform"
    }
  }
}

resource "helm_release" "cert-manager" {
  count      = var.enable_cert_manager ? 1 : 0
  name       = "cert-manager"
  chart      = "cert-manager"
  repository = data.helm_repository.jetstack.metadata.0.name
  namespace  = kubernetes_namespace.cert-manager.0.metadata.0.name
  version    = "v0.13.0"
  dynamic "set" {
    for_each = local.cert_manager_settings
    iterator = setting
    content {
      name  = setting.key
      value = setting.value
    }
  }
}