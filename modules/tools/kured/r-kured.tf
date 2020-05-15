
resource "helm_release" "kured" {
  count      = var.enable_kured ? 1 : 0
  name       = "kured"
  chart      = "kured"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  # Forced to kube-system due to Chart specificity
  namespace = "kube-system"

  dynamic "set" {
    for_each = local.kured_values
    iterator = setting
    content {
      name  = setting.key
      value = setting.value
    }
  }
}