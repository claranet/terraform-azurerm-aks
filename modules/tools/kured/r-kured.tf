resource "helm_release" "kured" {
  count      = var.enable_kured ? 1 : 0
  name       = "kured"
  chart      = "kured"
  repository = var.kured_chart_repository
  version    = var.kured_chart_version
  namespace  = local.namespace

  dynamic "set" {
    for_each = local.kured_values
    iterator = setting
    content {
      name  = setting.key
      value = setting.value
    }
  }
}
