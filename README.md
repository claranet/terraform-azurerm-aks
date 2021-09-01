<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| azurerm | >= 2.51 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| appgw | ./modules/agic | n/a |
| certmanager | ./modules/cert-manager | n/a |
| diagnostic\_settings | claranet/diagnostic-settings/azurerm | 4.0.1 |
| infra | ./modules/infra | n/a |
| kured | ./modules/kured | n/a |
| velero | ./modules/velero | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.node_pools](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_role_assignment.aad_pod_identity_mio_appgw_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_acr_pull_allowed](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_uai_private_dns_zone_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_uai_vnet_network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_user_assigned](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.aks_user_assigned_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.appgw_assigned_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aadpodidentity\_chart\_repository | AAD Pod Identity Helm chart repository URL | `string` | `"https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"` | no |
| aadpodidentity\_chart\_version | AAD Pod Identity helm chart version to use | `string` | `"2.0.0"` | no |
| aadpodidentity\_namespace | Kubernetes namespace in which to deploy AAD Pod Identity | `string` | `"system-aadpodid"` | no |
| aadpodidentity\_values | Settings for AAD Pod identity helm Chart:<pre>map(object({ <br>  nmi.nodeSelector.agentpool  = string <br>  mic.nodeSelector.agentpool  = string <br>  azureIdentity.enabled       = bool <br>  azureIdentity.type          = string <br>  azureIdentity.resourceID    = string <br>  azureIdentity.clientID      = string <br>  nmi.micNamespace            = string <br>}))</pre> | `map(string)` | `{}` | no |
| addons | Kubernetes addons to enable /disable | <pre>object({<br>    dashboard              = bool,<br>    oms_agent              = bool,<br>    oms_agent_workspace_id = string,<br>    policy                 = bool<br>  })</pre> | <pre>{<br>  "dashboard": false,<br>  "oms_agent": true,<br>  "oms_agent_workspace_id": null,<br>  "policy": false<br>}</pre> | no |
| agic\_chart\_repository | Helm chart repository URL | `string` | `"https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"` | no |
| agic\_chart\_version | Version of the Helm chart | `string` | `"1.2.0"` | no |
| agic\_helm\_version | [DEPRECATED] Version of Helm chart to deploy | `string` | `null` | no |
| aks\_sku\_tier | aks sku tier. Possible values are Free ou Paid | `string` | `"Free"` | no |
| aks\_user\_assigned\_identity\_custom\_name | Custom name for the aks user assigned identity resource | `string` | `null` | no |
| aks\_user\_assigned\_identity\_resource\_group\_name | Resource Group where to deploy the aks user assigned identity resource. Used when private cluster is enabled and when Azure private dns zone is not managed by aks | `string` | `null` | no |
| api\_server\_authorized\_ip\_ranges | Ip ranges allowed to interract with Kubernetes API. Default no restrictions | `list(string)` | `[]` | no |
| appgw\_ingress\_controller\_values | Application Gateway Ingress Controller settings | `map(string)` | `{}` | no |
| appgw\_private\_ip | Private IP for Application Gateway. Used when variable `private_ingress` is set to `true`. | `string` | `null` | no |
| appgw\_settings | Application gateway configuration settings. Default dummy configuration | `map(any)` | `{}` | no |
| appgw\_ssl\_certificates\_configs | Application gateway ssl certificates configuration | `list(map(string))` | `[]` | no |
| appgw\_subnet\_id | Application gateway subnet id | `string` | `""` | no |
| appgw\_user\_assigned\_identity\_custom\_name | Custom name for the application gateway user assigned identity resource | `string` | `null` | no |
| appgw\_user\_assigned\_identity\_resource\_group\_name | Resource Group where to deploy the application gateway user assigned identity resource | `string` | `null` | no |
| cert\_manager\_chart\_repository | Helm chart repository URL | `string` | `"https://charts.jetstack.io"` | no |
| cert\_manager\_chart\_version | Cert Manager helm chart version to use | `string` | `"v0.13.0"` | no |
| cert\_manager\_namespace | Kubernetes namespace in which to deploy Cert Manager | `string` | `"system-cert-manager"` | no |
| cert\_manager\_settings | Settings for cert-manager helm chart | `map(string)` | `{}` | no |
| client\_name | Client name/account used in naming | `string` | n/a | yes |
| container\_registries\_id | List of Azure Container Registries ids where AKS needs pull access. | `list(string)` | `[]` | no |
| custom\_aks\_name | Custom AKS name | `string` | `""` | no |
| custom\_appgw\_name | Custom name for AKS ingress application gateway | `string` | `""` | no |
| default\_node\_pool | Default node pool configuration:<pre>map(object({<br>    name                  = string<br>    count                 = number<br>    vm_size               = string<br>    os_type               = string<br>    availability_zones    = list(number)<br>    enable_auto_scaling   = bool<br>    min_count             = number<br>    max_count             = number<br>    type                  = string<br>    node_taints           = list(string)<br>    vnet_subnet_id        = string<br>    max_pods              = number<br>    os_disk_size_gb       = number<br>    enable_node_public_ip = bool<br>}))</pre> | `map(any)` | `{}` | no |
| diagnostic\_settings\_custom\_name | Custom name for Azure Diagnostics for AKS. | `string` | `"default"` | no |
| diagnostic\_settings\_event\_hub\_name | Event hub name used with diagnostics settings | `string` | `null` | no |
| diagnostic\_settings\_log\_categories | List of log categories | `list(string)` | `null` | no |
| diagnostic\_settings\_logs\_destination\_ids | List of destination resources IDs for logs diagnostic destination. Can be Storage Account, Log Analytics Workspace and Event Hub. No more than one of each can be set. | `list(string)` | `[]` | no |
| diagnostic\_settings\_metric\_categories | List of metric categories | `list(string)` | `null` | no |
| diagnostic\_settings\_retention\_days | The number of days to keep diagnostic logs. | `number` | `30` | no |
| docker\_bridge\_cidr | IP address for docker with Network CIDR. | `string` | `"172.16.0.1/16"` | no |
| enable\_agic | Enable Application gateway ingress controller | `bool` | `true` | no |
| enable\_appgw\_msi | Configure a managed service identity for Application gateway used with AGIC (useful to configure ssl cert into appgw from keyvault) | `bool` | `false` | no |
| enable\_cert\_manager | Enable cert-manager on AKS cluster | `bool` | `true` | no |
| enable\_kured | Enable kured daemon on AKS cluster | `bool` | `true` | no |
| enable\_pod\_security\_policy | Enable pod security policy or not. https://docs.microsoft.com/fr-fr/azure/AKS/use-pod-security-policies | `bool` | `false` | no |
| enable\_private\_cluster | Configure AKS as a Private Cluster : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_cluster_enabled | `bool` | `false` | no |
| enable\_velero | Enable velero on AKS cluster | `bool` | `true` | no |
| environment | Project environment | `string` | n/a | yes |
| extra\_tags | Extra tags to add | `map(string)` | `{}` | no |
| kubernetes\_version | Version of Kubernetes to deploy | `string` | `"1.17.9"` | no |
| kured\_chart\_repository | Helm chart repository URL | `string` | `"https://weaveworks.github.io/kured"` | no |
| kured\_chart\_version | Version of the Helm chart | `string` | `"2.2.0"` | no |
| kured\_settings | Settings for kured helm chart:<pre>map(object({ <br>  image.repository         = string <br>  image.tag                = string <br>  image.pullPolicy         = string <br>  extraArgs.reboot-days    = string <br>  extraArgs.start-time     = string <br>  extraArgs.end-time       = string <br>  extraArgs.time-zone      = string <br>  rbac.create              = string <br>  podSecurityPolicy.create = string <br>  serviceAccount.create    = string <br>  autolock.enabled         = string <br>}))</pre> | `map(string)` | `{}` | no |
| linux\_profile | Username and ssh key for accessing AKS Linux nodes with ssh. | <pre>object({<br>    username = string,<br>    ssh_key  = string<br>  })</pre> | `null` | no |
| location | Azure region to use | `string` | n/a | yes |
| location\_short | Short name of Azure regions to use | `string` | n/a | yes |
| name\_prefix | Prefix used in naming | `string` | `""` | no |
| node\_resource\_group | Name of the resource group in which to put AKS nodes. If null default to MC\_<AKS RG Name> | `string` | `null` | no |
| nodes\_pools | A list of nodes pools to create, each item supports same properties as `local.default_agent_profile` | `list(any)` | n/a | yes |
| nodes\_subnet\_id | Id of the subnet used for nodes | `string` | n/a | yes |
| outbound\_type | The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are `loadBalancer` and `userDefinedRouting`. | `string` | `"loadBalancer"` | no |
| private\_dns\_zone\_id | Id of the private DNS Zone when <private\_dns\_zone\_type> is custom | `string` | `null` | no |
| private\_dns\_zone\_type | Set AKS private dns zone if needed and if private cluster is enabled (privatelink.<region>.azmk8s.io)<br>- "Custom" : You will have to deploy a private Dns Zone on your own and pass the id with <private\_dns\_zone\_id> variable<br>If this settings is used, aks user assigned identity will be "userassigned" instead of "systemassigned"<br>and the aks user must have "Private DNS Zone Contributor" role on the private DNS Zone<br>- "System" : AKS will manage the private zone and create it in the same resource group as the Node Resource Group<br>- "None" : In case of None you will need to bring your own DNS server and set up resolving, otherwise cluster will have issues after provisioning.<br><br>https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_dns_zone_id | `string` | `"System"` | no |
| private\_ingress | Private ingress boolean variable. When `true`, the default http listener will listen on private IP instead of the public IP. | `bool` | `false` | no |
| resource\_group\_name | Name of the AKS resource group | `string` | n/a | yes |
| service\_cidr | CIDR used by kubernetes services (kubectl get svc). | `string` | n/a | yes |
| stack | Project stack name | `string` | n/a | yes |
| velero\_chart\_repository | URL of the Helm chart repository | `string` | `"https://vmware-tanzu.github.io/helm-charts"` | no |
| velero\_chart\_version | Velero helm chart version to use | `string` | `"2.12.13"` | no |
| velero\_namespace | Kubernetes namespace in which to deploy Velero | `string` | `"system-velero"` | no |
| velero\_storage\_settings | Settings for Storage account and blob container for Velero<pre>map(object({ <br>  name                     = string <br>  resource_group_name      = string <br>  location                 = string <br>  account_tier             = string <br>  account_replication_type = string <br>  tags                     = map(any) <br>  allowed_cidrs            = list(string) <br>  allowed_subnet_ids       = list(string) <br>  container_name           = string <br>}))</pre> | `map(any)` | `{}` | no |
| velero\_values | Settings for Velero helm chart:<pre>map(object({<br>  configuration.backupStorageLocation.bucket                = string <br>  configuration.backupStorageLocation.config.resourceGroup  = string <br>  configuration.backupStorageLocation.config.storageAccount = string <br>  configuration.backupStorageLocation.name                  = string <br>  configuration.provider                                    = string <br>  configuration.volumeSnapshotLocation.config.resourceGroup = string <br>  configuration.volumeSnapshotLocation.name                 = string <br>  credential.exstingSecret                                  = string <br>  credentials.useSecret                                     = string <br>  deployRestic                                              = string <br>  env.AZURE_CREDENTIALS_FILE                                = string <br>  metrics.enabled                                           = string <br>  rbac.create                                               = string <br>  schedules.daily.schedule                                  = string <br>  schedules.daily.template.includedNamespaces               = string <br>  schedules.daily.template.snapshotVolumes                  = string <br>  schedules.daily.template.ttl                              = string <br>  serviceAccount.server.create                              = string <br>  snapshotsEnabled                                          = string <br>  initContainers[0].name                                    = string <br>  initContainers[0].image                                   = string <br>  initContainers[0].volumeMounts[0].mountPath               = string <br>  initContainers[0].volumeMounts[0].name                    = string <br>  image.repository                                          = string <br>  image.tag                                                 = string <br>  image.pullPolicy                                          = string <br><br>}))</pre> | `map(string)` | `{}` | no |
| vnet\_id | Id of the vnet used for AKS | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aad\_pod\_identity\_azure\_identity | Identity object for AAD Pod Identity |
| aad\_pod\_identity\_namespace | Namespace used for AAD Pod Identity |
| agic\_namespace | Namespace used for AGIC |
| aks\_id | AKS resource id |
| aks\_kube\_config | Kube configuration of AKS Cluster |
| aks\_kube\_config\_raw | Raw kube config to be used by kubectl command |
| aks\_name | Name of the AKS cluster |
| aks\_nodes\_pools\_ids | Ids of AKS nodes pools |
| aks\_nodes\_pools\_names | Names of AKS nodes pools |
| aks\_nodes\_rg | Name of the resource group in which AKS nodes are deployed |
| aks\_user\_managed\_identity | The User Managed Identity used by AKS Agents |
| application\_gateway\_id | Id of the application gateway used by AKS |
| application\_gateway\_identity\_principal\_id | Id of the managed service identity of the application gateway used by AKS |
| application\_gateway\_name | Name of the application gateway used by AKS |
| cert\_manager\_namespace | Namespace used for Cert Manager |
| kured\_namespace | Namespace used for Kured |
| public\_ip\_id | Id of the public ip used by AKS application gateway |
| public\_ip\_name | Name of the public ip used by AKS application gateway |
| velero\_identity | Azure Identity used for Velero pods |
| velero\_namespace | Namespace used for Velero |
| velero\_storage\_account | Storage Account on which Velero data is stored. |
| velero\_storage\_account\_container | Container in Storage Account on which Velero data is stored. |
<!-- END_TF_DOCS -->