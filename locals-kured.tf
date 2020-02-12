locals {
  kured_default_values = {
    "image.repository"         = "weaveworks/kured"
    # To change when 1.3.0 will be released
    "image.tag"                = "master-f6e4062"
    "image.pullPolicy"         = "IfNotPresent"
    "extraArgs.reboot-days"    = "mon"
    "extraArgs.start-time"     = "3am"
    "extraArgs.end-time"       = "6am"
    "extraArgs.time-zone"      = "Europe/Paris"
    "rbac.create"              = "true"
    "podSecurityPolicy.create" = "false"
    "serviceAccount.create"    = "true"
    "autolock.enabled"         = "false"
  }

  kured_values = merge(local.kured_default_values, var.kured_settings)
}