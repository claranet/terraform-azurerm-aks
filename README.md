# Azure Kubernetes Service
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/aks/azurerm/)

This terraform module creates an [Azure Kubernetes Service](https://azure.microsoft.com/fr-fr/services/kubernetes-service/) and its associated [Azure Application Gateway](https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview) as ingress controller.

This module can create the Azure Kubernetes Service cluster as private or public. In case of an  [AKS private cluster](https://docs.microsoft.com/fr-fr/azure/aks/private-clusters) , the Terraform code including this module should be executed from a device that has access to the Azure Virtual Network where AKS Api Server stands. 

Inside the cluster default node pool, [velero](https://velero.io/docs/) and [cert-manager](https://cert-manager.io/docs/) are installed.

Inside each node pool, [Kured](https://github.com/weaveworks/kured) is installed as a daemonset.

This module also configures logging to a [Log Analytics Workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/learn/quick-create-workspace), 
deploys the [Azure Active Directory Pod Identity](https://github.com/Azure/aad-pod-identity) and creates some 
[Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/) with different types of Azure managed disks (Standard HDD retain and delete, Premium SSD retain and delete).

## Requirements and limitations

  * [Azurerm Terraform provider](https://registry.terraform.io/providers/hashicorp/azurerm/2.51.0) >= 2.51.0
  * [Helm Terraform provider](https://registry.terraform.io/providers/hashicorp/helm/1.0.0) >= 1.1.1
  * [Kubernetes Terraform provider](https://registry.terraform.io/providers/hashicorp/kubernetes/2.1.0) >= 2.1.0
  * [Kubectl command](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
  * A Microsoft.Storage [service endpoint](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview) into the nodes subnet
  
## Version compatibility

| Module version | Terraform version | AzureRM version |
|----------------|-------------------| --------------- |
| >= 4.x.x       | 0.13.x            | >= 2.10.0       |
| >= 3.x.x       | 0.12.x            | >= 2.10.0       |
| >= 2.x.x       | 0.12.x            | < 2.0           |
| <  2.x.x       | 0.11.x            | < 2.0           |

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) too which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

You can use this module by including it this way:

```hcl
locals {

  allowed_cidr = ["x.x.x.x", "y.y.y.y"]

}

module "azure-region" {
  source  = "claranet/regions/azurerm"
  version = "x.x.x"

  azure_region = var.azure_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "x.x.x"

  location    = module.azure-region.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack
}

module "azure-virtual-network" {
  source  = "claranet/vnet/azurerm"
  version = "x.x.x"

  environment    = var.environment
  location       = module.azure-region.location
  location_short = module.azure-region.location_short
  client_name    = var.client_name
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  vnet_cidr = ["10.0.0.0/19"]

}

module "azure-network-subnet" {
  source  = "claranet/subnet/azurerm"
  version = "x.x.x"

  environment    = var.environment
  location_short = module.azure-region.location_short
  client_name    = var.client_name
  stack          = var.stack

  resource_group_name  = module.rg.resource_group_name
  virtual_network_name = module.azure-virtual-network.virtual_network_name

  subnet_cidr_list = ["10.0.0.0/20", "10.0.20.0/24"]

  service_endpoints = ["Microsoft.Storage"]

}
module "global_run" {
  source = "claranet/run-common/azurerm"
  version = "x.x.x"

  client_name    = var.client_name
  location       = module.azure-region.location
  location_short = module.azure-region.location_short
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  tenant_id = var.azure_tenant_id

}

module "aks" {
  source  = "claranet/aks/azurerm"
  version = "x.x.x"

  client_name = var.client_name
  environment = var.environment
  stack       = var.stack

  resource_group_name = module.rg.resource_group_name
  location            = module.azure-region.location
  location_short      = module.azure-region.location_short

  service_cidr       = "10.0.16.0/22"
  kubernetes_version = "1.19.7"

  vnet_id         = module.azure-virtual-network.virtual_network_id
  nodes_subnet_id = module.azure-network-subnet.subnet_ids[0]
  nodes_pools = [
    {
      name            = "pool1"
      count           = 1
      vm_size         = "Standard_D1_v2"
      os_type         = "Linux"
      os_disk_size_gb = 30
      vnet_subnet_id  = module.azure-network-subnet.subnet_ids[0]
    },
    {
      name                = "bigpool1"
      count               = 3
      vm_size             = "Standard_F8s_v2"
      os_type             = "Linux"
      os_disk_size_gb     = 30
      vnet_subnet_id      = module.azure-network-subnet.subnet_ids[0]
      enable_auto_scaling = true
      min_count           = 3
      max_count           = 9
    }

  ]

  linux_profile = {
    username = "user"
    ssh_key  = file("~/.ssh/id_rsa.pub")
  }

  addons = {
    dashboard              = false
    oms_agent              = true
    oms_agent_workspace_id = var.log_analytic_workspace_id
    policy                 = false
  }

  diagnostic_settings_logs_destination_ids = [var.log_analytic_workspace_id]


  appgw_subnet_id   = module.azure-network-subnet.subnet_ids[1]

  appgw_ingress_controller_values   = { "verbosityLevel" = "5", "appgw.shared" = "true" }
  cert_manager_settings             = { "cainjector.nodeSelector.agentpool" = "default", "nodeSelector.agentpool" = "default", "webhook.nodeSelector.agentpool" = "default" }
  velero_storage_settings           = { allowed_cidrs = local.allowed_cidrs }

}

module "acr" {
  source  = "claranet/acr/azurerm"
  version = "x.x.x"

  location            = module.azure-region.location
  location_short      = module.azure-region.location_short
  resource_group_name = module.rg.resource_group_name
  sku_tier                 = "Free"

  client_name  = var.client_name
  environment  = var.environment
  stack        = var.stack
}

resource "azurerm_role_assignment" "allow_ACR" {
  principal_id         = module.aks.aks_user_managed_identity.0.object_id
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
}
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aadpodidentity_chart_repository"></a> [aadpodidentity\_chart\_repository](#input\_aadpodidentity\_chart\_repository) | AAD Pod Identity Helm chart repository URL | `string` | `"https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"` | no |
| <a name="input_aadpodidentity_chart_version"></a> [aadpodidentity\_chart\_version](#input\_aadpodidentity\_chart\_version) | AAD Pod Identity helm chart version to use | `string` | `"2.0.0"` | no |
| <a name="input_aadpodidentity_namespace"></a> [aadpodidentity\_namespace](#input\_aadpodidentity\_namespace) | Kubernetes namespace in which to deploy AAD Pod Identity | `string` | `"system-aadpodid"` | no |
| <a name="input_aadpodidentity_values"></a> [aadpodidentity\_values](#input\_aadpodidentity\_values) | Settings for AAD Pod identity helm Chart:<pre>map(object({ <br>  nmi.nodeSelector.agentpool  = string <br>  mic.nodeSelector.agentpool  = string <br>  azureIdentity.enabled       = bool <br>  azureIdentity.type          = string <br>  azureIdentity.resourceID    = string <br>  azureIdentity.clientID      = string <br>  nmi.micNamespace            = string <br>}))</pre> | `map(string)` | `{}` | no |
| <a name="input_addons"></a> [addons](#input\_addons) | Kubernetes addons to enable /disable | <pre>object({<br>    dashboard              = bool,<br>    oms_agent              = bool,<br>    oms_agent_workspace_id = string,<br>    policy                 = bool<br>  })</pre> | <pre>{<br>  "dashboard": false,<br>  "oms_agent": true,<br>  "oms_agent_workspace_id": null,<br>  "policy": false<br>}</pre> | no |
| <a name="input_agic_chart_repository"></a> [agic\_chart\_repository](#input\_agic\_chart\_repository) | Helm chart repository URL | `string` | `"https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"` | no |
| <a name="input_agic_chart_version"></a> [agic\_chart\_version](#input\_agic\_chart\_version) | Version of the Helm chart | `string` | `"1.2.0"` | no |
| <a name="input_agic_helm_version"></a> [agic\_helm\_version](#input\_agic\_helm\_version) | [DEPRECATED] Version of Helm chart to deploy | `string` | `null` | no |
| <a name="input_aks_sku_tier"></a> [aks\_sku\_tier](#input\_aks\_sku\_tier) | aks sku tier. Possible values are Free ou Paid | `string` | `"Free"` | no |
| <a name="input_aks_user_assigned_identity_custom_name"></a> [aks\_user\_assigned\_identity\_custom\_name](#input\_aks\_user\_assigned\_identity\_custom\_name) | Custom name for the aks user assigned identity resource | `string` | `null` | no |
| <a name="input_aks_user_assigned_identity_resource_group_name"></a> [aks\_user\_assigned\_identity\_resource\_group\_name](#input\_aks\_user\_assigned\_identity\_resource\_group\_name) | Resource Group where to deploy the aks user assigned identity resource. Used when private cluster is enabled and when Azure private dns zone is not managed by aks | `string` | `null` | no |
| <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges) | Ip ranges allowed to interract with Kubernetes API. Default no restrictions | `list(string)` | `[]` | no |
| <a name="input_appgw_ingress_controller_values"></a> [appgw\_ingress\_controller\_values](#input\_appgw\_ingress\_controller\_values) | Application Gateway Ingress Controller settings | `map(string)` | `{}` | no |
| <a name="input_appgw_private_ip"></a> [appgw\_private\_ip](#input\_appgw\_private\_ip) | Private IP for Application Gateway. Used when variable `private_ingress` is set to `true`. | `string` | `null` | no |
| <a name="input_appgw_settings"></a> [appgw\_settings](#input\_appgw\_settings) | Application gateway configuration settings. Default dummy configuration | `map(any)` | `{}` | no |
| <a name="input_appgw_ssl_certificates_configs"></a> [appgw\_ssl\_certificates\_configs](#input\_appgw\_ssl\_certificates\_configs) | Application gateway ssl certificates configuration | `list(map(string))` | `[]` | no |
| <a name="input_appgw_subnet_id"></a> [appgw\_subnet\_id](#input\_appgw\_subnet\_id) | Application gateway subnet id | `string` | `""` | no |
| <a name="input_appgw_user_assigned_identity_custom_name"></a> [appgw\_user\_assigned\_identity\_custom\_name](#input\_appgw\_user\_assigned\_identity\_custom\_name) | Custom name for the application gateway user assigned identity resource | `string` | `null` | no |
| <a name="input_appgw_user_assigned_identity_resource_group_name"></a> [appgw\_user\_assigned\_identity\_resource\_group\_name](#input\_appgw\_user\_assigned\_identity\_resource\_group\_name) | Resource Group where to deploy the application gateway user assigned identity resource | `string` | `null` | no |
| <a name="input_cert_manager_chart_repository"></a> [cert\_manager\_chart\_repository](#input\_cert\_manager\_chart\_repository) | Helm chart repository URL | `string` | `"https://charts.jetstack.io"` | no |
| <a name="input_cert_manager_chart_version"></a> [cert\_manager\_chart\_version](#input\_cert\_manager\_chart\_version) | Cert Manager helm chart version to use | `string` | `"v0.13.0"` | no |
| <a name="input_cert_manager_namespace"></a> [cert\_manager\_namespace](#input\_cert\_manager\_namespace) | Kubernetes namespace in which to deploy Cert Manager | `string` | `"system-cert-manager"` | no |
| <a name="input_cert_manager_settings"></a> [cert\_manager\_settings](#input\_cert\_manager\_settings) | Settings for cert-manager helm chart | `map(string)` | `{}` | no |
| <a name="input_client_name"></a> [client\_name](#input\_client\_name) | Client name/account used in naming | `string` | n/a | yes |
| <a name="input_container_registries_id"></a> [container\_registries\_id](#input\_container\_registries\_id) | List of Azure Container Registries ids where AKS needs pull access. | `list(string)` | `null` | no |
| <a name="input_custom_aks_name"></a> [custom\_aks\_name](#input\_custom\_aks\_name) | Custom AKS name | `string` | `""` | no |
| <a name="input_custom_appgw_name"></a> [custom\_appgw\_name](#input\_custom\_appgw\_name) | Custom name for AKS ingress application gateway | `string` | `""` | no |
| <a name="input_default_node_pool"></a> [default\_node\_pool](#input\_default\_node\_pool) | Default node pool configuration:<pre>map(object({<br>    name                  = string<br>    count                 = number<br>    vm_size               = string<br>    os_type               = string<br>    availability_zones    = list(number)<br>    enable_auto_scaling   = bool<br>    min_count             = number<br>    max_count             = number<br>    type                  = string<br>    node_taints           = list(string)<br>    vnet_subnet_id        = string<br>    max_pods              = number<br>    os_disk_size_gb       = number<br>    enable_node_public_ip = bool<br>}))</pre> | `map(any)` | `{}` | no |
| <a name="input_diagnostic_settings_custom_name"></a> [diagnostic\_settings\_custom\_name](#input\_diagnostic\_settings\_custom\_name) | Custom name for Azure Diagnostics for AKS. | `string` | `"default"` | no |
| <a name="input_diagnostic_settings_event_hub_name"></a> [diagnostic\_settings\_event\_hub\_name](#input\_diagnostic\_settings\_event\_hub\_name) | Event hub name used with diagnostics settings | `string` | `null` | no |
| <a name="input_diagnostic_settings_log_categories"></a> [diagnostic\_settings\_log\_categories](#input\_diagnostic\_settings\_log\_categories) | List of log categories | `list(string)` | `null` | no |
| <a name="input_diagnostic_settings_logs_destination_ids"></a> [diagnostic\_settings\_logs\_destination\_ids](#input\_diagnostic\_settings\_logs\_destination\_ids) | List of destination resources IDs for logs diagnostic destination. Can be Storage Account, Log Analytics Workspace and Event Hub. No more than one of each can be set. | `list(string)` | `[]` | no |
| <a name="input_diagnostic_settings_metric_categories"></a> [diagnostic\_settings\_metric\_categories](#input\_diagnostic\_settings\_metric\_categories) | List of metric categories | `list(string)` | `null` | no |
| <a name="input_diagnostic_settings_retention_days"></a> [diagnostic\_settings\_retention\_days](#input\_diagnostic\_settings\_retention\_days) | The number of days to keep diagnostic logs. | `number` | `30` | no |
| <a name="input_docker_bridge_cidr"></a> [docker\_bridge\_cidr](#input\_docker\_bridge\_cidr) | IP address for docker with Network CIDR. | `string` | `"172.16.0.1/16"` | no |
| <a name="input_enable_agic"></a> [enable\_agic](#input\_enable\_agic) | Enable Application gateway ingress controller | `bool` | `true` | no |
| <a name="input_enable_appgw_msi"></a> [enable\_appgw\_msi](#input\_enable\_appgw\_msi) | Configure a managed service identity for Application gateway used with AGIC (useful to configure ssl cert into appgw from keyvault) | `bool` | `false` | no |
| <a name="input_enable_cert_manager"></a> [enable\_cert\_manager](#input\_enable\_cert\_manager) | Enable cert-manager on AKS cluster | `bool` | `true` | no |
| <a name="input_enable_kured"></a> [enable\_kured](#input\_enable\_kured) | Enable kured daemon on AKS cluster | `bool` | `true` | no |
| <a name="input_enable_pod_security_policy"></a> [enable\_pod\_security\_policy](#input\_enable\_pod\_security\_policy) | Enable pod security policy or not. https://docs.microsoft.com/fr-fr/azure/AKS/use-pod-security-policies | `bool` | `false` | no |
| <a name="input_enable_private_cluster"></a> [enable\_private\_cluster](#input\_enable\_private\_cluster) | Configure AKS as a Private Cluster : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_cluster_enabled | `bool` | `false` | no |
| <a name="input_enable_velero"></a> [enable\_velero](#input\_enable\_velero) | Enable velero on AKS cluster | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Project environment | `string` | n/a | yes |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Extra tags to add | `map(string)` | `{}` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Version of Kubernetes to deploy | `string` | `"1.17.9"` | no |
| <a name="input_kured_chart_repository"></a> [kured\_chart\_repository](#input\_kured\_chart\_repository) | Helm chart repository URL | `string` | `"https://weaveworks.github.io/kured"` | no |
| <a name="input_kured_chart_version"></a> [kured\_chart\_version](#input\_kured\_chart\_version) | Version of the Helm chart | `string` | `"2.2.0"` | no |
| <a name="input_kured_settings"></a> [kured\_settings](#input\_kured\_settings) | Settings for kured helm chart:<pre>map(object({ <br>  image.repository         = string <br>  image.tag                = string <br>  image.pullPolicy         = string <br>  extraArgs.reboot-days    = string <br>  extraArgs.start-time     = string <br>  extraArgs.end-time       = string <br>  extraArgs.time-zone      = string <br>  rbac.create              = string <br>  podSecurityPolicy.create = string <br>  serviceAccount.create    = string <br>  autolock.enabled         = string <br>}))</pre> | `map(string)` | `{}` | no |
| <a name="input_linux_profile"></a> [linux\_profile](#input\_linux\_profile) | Username and ssh key for accessing AKS Linux nodes with ssh. | <pre>object({<br>    username = string,<br>    ssh_key  = string<br>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region to use | `string` | n/a | yes |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | Short name of Azure regions to use | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used in naming | `string` | `""` | no |
| <a name="input_node_resource_group"></a> [node\_resource\_group](#input\_node\_resource\_group) | Name of the resource group in which to put AKS nodes. If null default to MC\_<AKS RG Name> | `string` | `null` | no |
| <a name="input_nodes_pools"></a> [nodes\_pools](#input\_nodes\_pools) | A list of nodes pools to create, each item supports same properties as `local.default_agent_profile` | `list(any)` | n/a | yes |
| <a name="input_nodes_subnet_id"></a> [nodes\_subnet\_id](#input\_nodes\_subnet\_id) | Id of the subnet used for nodes | `string` | n/a | yes |
| <a name="input_outbound_type"></a> [outbound\_type](#input\_outbound\_type) | The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are `loadBalancer` and `userDefinedRouting`. | `string` | `"loadBalancer"` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Id of the private DNS Zone when <private\_dns\_zone\_type> is custom | `string` | `null` | no |
| <a name="input_private_dns_zone_type"></a> [private\_dns\_zone\_type](#input\_private\_dns\_zone\_type) | Set AKS private dns zone if needed and if private cluster is enabled (privatelink.<region>.azmk8s.io)<br>- "Custom" : You will have to deploy a private Dns Zone on your own and pass the id with <private\_dns\_zone\_id> variable<br>If this settings is used, aks user assigned identity will be "userassigned" instead of "systemassigned"<br>and the aks user must have "Private DNS Zone Contributor" role on the private DNS Zone<br>- "System" : AKS will manage the private zone and create it in the same resource group as the Node Resource Group<br>- "None" : In case of None you will need to bring your own DNS server and set up resolving, otherwise cluster will have issues after provisioning.<br><br>https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_dns_zone_id | `string` | `"System"` | no |
| <a name="input_private_ingress"></a> [private\_ingress](#input\_private\_ingress) | Private ingress boolean variable. When `true`, the default http listener will listen on private IP instead of the public IP. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the AKS resource group | `string` | n/a | yes |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | CIDR used by kubernetes services (kubectl get svc). | `string` | n/a | yes |
| <a name="input_stack"></a> [stack](#input\_stack) | Project stack name | `string` | n/a | yes |
| <a name="input_velero_chart_repository"></a> [velero\_chart\_repository](#input\_velero\_chart\_repository) | URL of the Helm chart repository | `string` | `"https://vmware-tanzu.github.io/helm-charts"` | no |
| <a name="input_velero_chart_version"></a> [velero\_chart\_version](#input\_velero\_chart\_version) | Velero helm chart version to use | `string` | `"2.12.13"` | no |
| <a name="input_velero_namespace"></a> [velero\_namespace](#input\_velero\_namespace) | Kubernetes namespace in which to deploy Velero | `string` | `"system-velero"` | no |
| <a name="input_velero_storage_settings"></a> [velero\_storage\_settings](#input\_velero\_storage\_settings) | Settings for Storage account and blob container for Velero<pre>map(object({ <br>  name                     = string <br>  resource_group_name      = string <br>  location                 = string <br>  account_tier             = string <br>  account_replication_type = string <br>  tags                     = map(any) <br>  allowed_cidrs            = list(string) <br>  container_name           = string <br>}))</pre> | `map(any)` | `{}` | no |
| <a name="input_velero_values"></a> [velero\_values](#input\_velero\_values) | Settings for Velero helm chart:<pre>map(object({<br>  configuration.backupStorageLocation.bucket                = string <br>  configuration.backupStorageLocation.config.resourceGroup  = string <br>  configuration.backupStorageLocation.config.storageAccount = string <br>  configuration.backupStorageLocation.name                  = string <br>  configuration.provider                                    = string <br>  configuration.volumeSnapshotLocation.config.resourceGroup = string <br>  configuration.volumeSnapshotLocation.name                 = string <br>  credential.exstingSecret                                  = string <br>  credentials.useSecret                                     = string <br>  deployRestic                                              = string <br>  env.AZURE_CREDENTIALS_FILE                                = string <br>  metrics.enabled                                           = string <br>  rbac.create    = string <br>  schedules.daily.schedule                                  = string <br>  schedules.daily.template.includedNamespaces               = string <br>  schedules.daily.template.snapshotVolumes                  = string <br>  schedules.daily.template.ttl                              = string <br>  serviceAccount.server.create                              = string <br>  snapshotsEnabled                                          = string <br>  initContainers[0].name                                    = string <br>  initContainers[0].image                                   = string <br>  initContainers[0].volumeMounts[0].mountPath               = string <br>  initContainers[0].volumeMounts[0].name                    = string <br>  image.repository         = string <br>  image.tag                                                 = string <br>  image.pullPolicy                      = string <br><br>}))</pre> | `map(string)` | `{}` | no |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | Id of the vnet used for AKS | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aad_pod_identity_azure_identity"></a> [aad\_pod\_identity\_azure\_identity](#output\_aad\_pod\_identity\_azure\_identity) | Identity object for AAD Pod Identity |
| <a name="output_aad_pod_identity_namespace"></a> [aad\_pod\_identity\_namespace](#output\_aad\_pod\_identity\_namespace) | Namespace used for AAD Pod Identity |
| <a name="output_agic_namespace"></a> [agic\_namespace](#output\_agic\_namespace) | Namespace used for AGIC |
| <a name="output_aks_id"></a> [aks\_id](#output\_aks\_id) | AKS resource id |
| <a name="output_aks_kube_config"></a> [aks\_kube\_config](#output\_aks\_kube\_config) | Kube configuration of AKS Cluster |
| <a name="output_aks_kube_config_raw"></a> [aks\_kube\_config\_raw](#output\_aks\_kube\_config\_raw) | Raw kube config to be used by kubectl command |
| <a name="output_aks_name"></a> [aks\_name](#output\_aks\_name) | Name of the AKS cluster |
| <a name="output_aks_nodes_pools_ids"></a> [aks\_nodes\_pools\_ids](#output\_aks\_nodes\_pools\_ids) | Ids of AKS nodes pools |
| <a name="output_aks_nodes_pools_names"></a> [aks\_nodes\_pools\_names](#output\_aks\_nodes\_pools\_names) | Names of AKS nodes pools |
| <a name="output_aks_nodes_rg"></a> [aks\_nodes\_rg](#output\_aks\_nodes\_rg) | Name of the resource group in which AKS nodes are deployed |
| <a name="output_aks_user_managed_identity"></a> [aks\_user\_managed\_identity](#output\_aks\_user\_managed\_identity) | The User Managed Identity used by AKS Agents |
| <a name="output_application_gateway_id"></a> [application\_gateway\_id](#output\_application\_gateway\_id) | Id of the application gateway used by AKS |
| <a name="output_application_gateway_identity_principal_id"></a> [application\_gateway\_identity\_principal\_id](#output\_application\_gateway\_identity\_principal\_id) | Id of the managed service identity of the application gateway used by AKS |
| <a name="output_application_gateway_name"></a> [application\_gateway\_name](#output\_application\_gateway\_name) | Name of the application gateway used by AKS |
| <a name="output_cert_manager_namespace"></a> [cert\_manager\_namespace](#output\_cert\_manager\_namespace) | Namespace used for Cert Manager |
| <a name="output_kured_namespace"></a> [kured\_namespace](#output\_kured\_namespace) | Namespace used for Kured |
| <a name="output_public_ip_id"></a> [public\_ip\_id](#output\_public\_ip\_id) | Id of the public ip used by AKS application gateway |
| <a name="output_public_ip_name"></a> [public\_ip\_name](#output\_public\_ip\_name) | Name of the public ip used by AKS application gateway |
| <a name="output_velero_identity"></a> [velero\_identity](#output\_velero\_identity) | Azure Identity used for Velero pods |
| <a name="output_velero_namespace"></a> [velero\_namespace](#output\_velero\_namespace) | Namespace used for Velero |
| <a name="output_velero_storage_account"></a> [velero\_storage\_account](#output\_velero\_storage\_account) | Storage Account on which Velero data is stored. |
| <a name="output_velero_storage_account_container"></a> [velero\_storage\_account\_container](#output\_velero\_storage\_account\_container) | Container in Storage Account on which Velero data is stored. |

## Related documentation

- Azure Kubernetes Service documentation : [docs.microsoft.com/en-us/azure/aks/](https://docs.microsoft.com/en-us/azure/aks/)
- Azure Kubernetes Service MSI Usage : [docs.microsoft.com/en-us/azure/aks/use-managed-identity](https://docs.microsoft.com/en-us/azure/aks/use-managed-identity)
- Azure Kubernetes Service User-Defined Route usage : [docs.microsoft.com/en-us/azure/aks/egress-outboundtype](https://docs.microsoft.com/en-us/azure/aks/egress-outboundtype)
- Terraform AKS resource documentation: [www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html](https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html)
- Terraform AKS Node pool resource documentation: [www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster_node_pool.html](https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster_node_pool.html)
- Azure Kubernetes Service Private Cluster documentation : (https://docs.microsoft.com/fr-fr/azure/aks/private-clusters#options-for-connecting-to-the-private-cluster)
- Terraform Kubernetes provider documentation: [www.terraform.io/docs/providers/kubernetes/index.html](https://www.terraform.io/docs/providers/kubernetes/index.html)
- Terraform Helm provider documentation: [www.terraform.io/docs/providers/helm/index.html](https://www.terraform.io/docs/providers/helm/index.html)
- Kured documentation: [github.com/weaveworks/kured](https://github.com/weaveworks/kured)
- Velero documentation: [velero.io/docs/v1.2.0/](https://velero.io/docs/)
- Velero Azure specific documentation: [github.com/vmware-tanzu/velero-plugin-for-microsoft-azure](https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure)
- cert-manager documentation : [cert-manager.io/docs/](https://cert-manager.io/docs/)

