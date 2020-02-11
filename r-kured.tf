resource "helm_release" "kured" {
  count      = var.enable_kured ? 1 : 0
  name       = "kured"
  chart      = "kured"
  repository = data.helm_repository.stable.metadata.0.name
  namespace  = "kube-system"
  # Forced to kube-system due to Chart specificity

  dynamic "set" {
    for_each = local.kured_settings
    iterator = setting
    content {
      name  = setting.key
      value = setting.value
    }
  }
}