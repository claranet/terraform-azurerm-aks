<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| azurerm | >= 2.10 |
| helm | >=2.3.0 |
| kubernetes | >= 1.11.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.velero_identity_role_aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.velero_identity_role_storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.velero](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.velero](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.velero](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_user_assigned_identity.velero_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [helm_release.velero](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.velero_identity](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.velero](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.velero](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [azurerm_resource_group.aks_nodes_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aks\_nodes\_resource\_group\_name | Name of AKS nodes resource group | `string` | n/a | yes |
| client\_name | Client name/account used in naming | `string` | n/a | yes |
| enable\_velero | Enable velero on AKS cluster | `bool` | `true` | no |
| environment | Project environment | `string` | n/a | yes |
| location | Azure region to use | `string` | n/a | yes |
| location\_short | Short name of Azure regions to use | `string` | n/a | yes |
| name\_prefix | Prefix used in naming | `string` | `""` | no |
| nodes\_subnet\_id | Id of the subnet used for nodes | `string` | n/a | yes |
| resource\_group\_name | Name of the resource group for Velero's Storage Account | `string` | n/a | yes |
| stack | Project stack name | `string` | n/a | yes |
| velero\_chart\_repository | Helm chart repository URL | `string` | `"https://vmware-tanzu.github.io/helm-charts"` | no |
| velero\_chart\_version | Velero helm chart version to use | `string` | `"2.12.13"` | no |
| velero\_namespace | Kubernetes namespace in which to deploy Velero | `string` | `"system-velero"` | no |
| velero\_storage\_settings | Settings for Storage account and blob container for Velero<br><br>map(object({<br>  name                     = string <br>  resource\_group\_name      = string <br>  location                 = string <br>  account\_tier             = string <br>  account\_replication\_type = string <br>  tags                     = map(any) <br>  allowed\_cidrs            = list(string) <br>  allowed\_subnet\_ids       = list(string) <br>  container\_name           = string <br>})) | `map(any)` | `{}` | no |
| velero\_values | Settings for Velero helm chart<br><br>map(object({ <br>  configuration.backupStorageLocation.bucket                = string <br>  configuration.backupStorageLocation.config.resourceGroup  = string <br>  configuration.backupStorageLocation.config.storageAccount = string <br>  configuration.backupStorageLocation.name                  = string <br>  configuration.provider                                    = string <br>  configuration.volumeSnapshotLocation.config.resourceGroup = string <br>  configuration.volumeSnapshotLocation.name                 = string <br>  credential.exstingSecret                                  = string <br>  credentials.useSecret                                     = string <br>  deployRestic                                              = string <br>  env.AZURE\_CREDENTIALS\_FILE                                = string <br>  metrics.enabled                                           = string <br>  rbac.create                                               = string <br>  schedules.daily.schedule                                  = string <br>  schedules.daily.template.includedNamespaces               = string <br>  schedules.daily.template.snapshotVolumes                  = string <br>  schedules.daily.template.ttl                              = string <br>  serviceAccount.server.create                              = string <br>  snapshotsEnabled                                          = string <br>  initContainers[0].name                                    = string <br>  initContainers[0].image                                   = string <br>  initContainers[0].volumeMounts[0].mountPath               = string <br>  initContainers[0].volumeMounts[0].name                    = string <br>  image.repository                                          = string <br>  image.tag                                                 = string <br>  image.pullPolicy                                          = string<br>  podAnnotations.aadpodidbinding                            = string<br>  podLabels.aadpodidbinding                                 = string<br><br>})) | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Namespace used for Velero |
| storage\_account | Storage Account on which Velero data is stored. |
| storage\_account\_container | Container in Storage Account on which Velero data is stored. |
| velero\_identity | Azure Identity used for Velero pods |
<!-- END_TF_DOCS -->