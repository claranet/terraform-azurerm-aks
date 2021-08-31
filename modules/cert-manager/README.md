<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| helm | >=2.3.0 |
| kubernetes | >= 1.11.1 |

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
| cert\_manager\_chart\_version | Cert Manager helm chart version to use | `string` | `"v0.13.0"` | no |
| cert\_manager\_namespace | Kubernetes namespace in which to deploy Cert Manager | `string` | `"system-cert-manager"` | no |
| cert\_manager\_settings | Settings for cert-manager helm chart | `map(string)` | `{}` | no |
| enable\_cert\_manager | Enable cert-manager on AKS cluster | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Namespace used for Cert Manager |
<!-- END_TF_DOCS -->