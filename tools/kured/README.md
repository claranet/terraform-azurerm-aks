# Azure Kubernetes Service - Kured tool submodule
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/aks/azurerm/latest/submodules/kured)

This module deploys [Kured](https://github.com/weaveworks/kured) on an existing K8S cluster with Helm 3.

## Version compatibility

| Module version    | Terraform version | Helm version | Kubernetes version |
|-------------------|-------------------|--------------|--------------------|
| >= 3.x.x          | 0.12.x            | = 1.1.1      | ~> 1.11.1          |
| >= 2.x.x, < 3.x.x | 0.12.x            | N/A          | N/A                |
| <  2.x.x          | 0.11.x            | N/A          | N/A                |

## Usage

```hcl
module "kured" {
  source  = "claranet/aks/azurerm//modules/tools/kured"
  version = "x.x.x"

  cert_manager_namespace     = var.cert_manager_namespace
  cert_manager_chart_version = var.cert_manager_chart_version
  cert_manager_settings      = var.cert_manager_settings
}

```

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| helm | >= 2.3.0 |

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
| kured\_chart\_repository | Helm chart repository URL | `string` | `"https://kubereboot.github.io/charts"` | no |
| kured\_chart\_version | Version of the Helm chart | `string` | `"2.2.0"` | no |
| kured\_settings | Settings for kured helm chart <br /><br><pre><br>map(object({ <br /><br>  image.repository         = string <br /><br>  image.tag                = string <br /><br>  image.pullPolicy         = string <br /><br>  extraArgs.reboot-days    = string <br /><br>  extraArgs.start-time     = string <br /><br>  extraArgs.end-time       = string <br /><br>  extraArgs.time-zone      = string <br /><br>  rbac.create              = string <br /><br>  podSecurityPolicy.create = string <br /><br>  serviceAccount.create    = string <br /><br>  autolock.enabled         = string <br /><br>}))<br /><br></pre> | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Namespace used for Kured |
<!-- END_TF_DOCS -->

## Related documentation

- Kured documentation : [github.com/weaveworks/kured](https://github.com/weaveworks/kured)
