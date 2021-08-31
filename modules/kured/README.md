<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| helm | >=2.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.kured](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable\_kured | Enable kured daemon on AKS cluster | `bool` | `true` | no |
| kured\_chart\_repository | Helm chart repository URL | `string` | `"https://weaveworks.github.io/kured"` | no |
| kured\_chart\_version | Version of the Helm chart | `string` | `"2.2.0"` | no |
| kured\_settings | Settings for kured helm chart <br /><br><pre><br>map(object({ <br /><br>  image.repository         = string <br /><br>  image.tag                = string <br /><br>  image.pullPolicy         = string <br /><br>  extraArgs.reboot-days    = string <br /><br>  extraArgs.start-time     = string <br /><br>  extraArgs.end-time       = string <br /><br>  extraArgs.time-zone      = string <br /><br>  rbac.create              = string <br /><br>  podSecurityPolicy.create = string <br /><br>  serviceAccount.create    = string <br /><br>  autolock.enabled         = string <br /><br>}))<br /><br></pre> | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Namespace used for Kured |
<!-- END_TF_DOCS -->