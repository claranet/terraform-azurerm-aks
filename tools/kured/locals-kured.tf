locals {
  # Forced to kube-system due to Chart specificity
  namespace = "kube-system"
  kured_default_values = {
    "image.repository"         = "ghcr.io/kubereboot/kured"
    "image.tag"                = "1.11.0"
    "image.pullPolicy"         = "IfNotPresent"
    "extraArgs.reboot-days"    = "mon"
    "extraArgs.start-time"     = "3am"
    "extraArgs.end-time"       = "6am"
    "extraArgs.time-zone"      = "Europe/Paris"
    "rbac.create"              = "true"
    "podSecurityPolicy.create" = "false"
    "serviceAccount.create"    = "true"
  }

  kured_values = merge(local.kured_default_values, var.kured_settings)
}
