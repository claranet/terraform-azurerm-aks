# Azure Kubernetes Service - Cert manager tool submodule
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/aks/azurerm/latest/submodules/cert-manager)

This module deploys [cert-manager](https://cert-manager.io/docs/) utility on an existing K8S cluster with Helm 3.

## Version compatibility

| Module version    | Terraform version | Helm version | Kubernetes version |
|-------------------|-------------------|--------------|--------------------|
| >= 3.x.x          | 0.12.x            | = 1.1.1      | ~> 1.11.1          |
| >= 2.x.x, < 3.x.x | 0.12.x            | N/A          | N/A                |
| <  2.x.x          | 0.11.x            | N/A          | N/A                |

## Usage

```hcl
module "certmanager" {
  source = "claranet/aks/azurerm//modules/tools/cert-manager"

  cert_manager_namespace     = var.cert_manager_namespace
  cert_manager_chart_version = var.cert_manager_chart_version
  cert_manager_settings      = var.cert_manager_settings
}

```

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| helm | >= 2.5.1 |
| kubernetes | >= 2.11.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.cert_manager](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cert\_manager\_chart\_repository | Helm chart repository URL | `string` | `"https://charts.jetstack.io"` | no |
| cert\_manager\_chart\_version | Cert Manager helm chart version to use | `string` | `"v1.8.0"` | no |
| cert\_manager\_namespace | Kubernetes namespace in which to deploy Cert Manager | `string` | `"system-cert-manager"` | no |
| cert\_manager\_settings | Settings for cert-manager helm chart | `map(string)` | `{}` | no |
| enable\_cert\_manager | Enable cert-manager on AKS cluster | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Namespace used for Cert Manager |
<!-- END_TF_DOCS -->

## Related documentation

- cert-manager documentation : [github.com/jetstack/cert-manager](https://github.com/jetstack/cert-manager)
