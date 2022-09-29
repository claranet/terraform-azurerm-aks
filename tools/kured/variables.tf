variable "enable_kured" {
  description = "Enable kured daemon on AKS cluster"
  type        = bool
  default     = true
}

variable "kured_chart_repository" {
  description = "Helm chart repository URL"
  type        = string
  default     = "https://kubereboot.github.io/charts"
}

variable "kured_chart_version" {
  description = "Version of the Helm chart"
  type        = string
  default     = "2.2.0"
}

variable "kured_settings" {
  description = <<EODK
Settings for kured helm chart <br />
<pre>
map(object({ <br />
  image.repository         = string <br />
  image.tag                = string <br />
  image.pullPolicy         = string <br />
  extraArgs.reboot-days    = string <br />
  extraArgs.start-time     = string <br />
  extraArgs.end-time       = string <br />
  extraArgs.time-zone      = string <br />
  rbac.create              = string <br />
  podSecurityPolicy.create = string <br />
  serviceAccount.create    = string <br />
  autolock.enabled         = string <br />
}))<br />
</pre>
EODK
  type        = map(string)
  default     = {}
}
