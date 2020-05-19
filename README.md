# Azure Kubernetes Service
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/aks/azurerm/)

This terraform module create an [Azure Kubernetes Service](https://azure.microsoft.com/fr-fr/services/kubernetes-service/) and associated [Azure Application Gateway](https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview) as ingress controller.

Inside the cluster default node pool, [velero](https://velero.io/docs/) and [cert-manager](https://cert-manager.io/docs/) are installed.
Inside each node pool, [Kured](https://github.com/weaveworks/kured) is installed as a daemonset.

## Requirements and limitations

  * [Azurerm Terraform provider](https://registry.terraform.io/providers/hashicorp/azurerm/2.10.0) >= 2.10.0
  * [Helm Terraform provider](https://registry.terraform.io/providers/hashicorp/helm/1.0.0) >= 1.1.1
  * [Kubernetes Terraform provider](https://registry.terraform.io/providers/hashicorp/kubernetes/1.11.1) >= 1.11.1
  * [Kubectl command](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
  * A Microsoft.Storage [service endpoint](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview) into the nodes subnet
  
## Terraform version compatibility

| Module version | Terraform version | AzureRM Version |
| -------------- | ----------------- | --------------- |
| >= 3.x.x       | 0.12.x            | ~>2.10.0        |
| >= 2.x.x       | 0.12.x            | < 2.0.0         |
| < 2.x.x        | 0.11.x            | < 2.0.0         |

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) too which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

You can use this module by including it this way:

```hcl
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

  client_name    = var.client_name
  location       = module.azure-region.location
  location_short = module.azure-region.location_short
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  tenant_id = var.azure_tenant_id

}

provider "azuread" {}

resource "azuread_application" "aks-sp" {
  name = "MySPName"
}

resource "azuread_service_principal" "aks-sp" {
  application_id = azuread_application.aks-sp.application_id
}

resource "random_password" "aks-sp" {
  length  = 32
  special = true
}

resource "azuread_service_principal_password" "aks-sp" {
  service_principal_id = azuread_service_principal.aks-sp.id
  value                = random_password.aks-sp.result
  end_date             = "2050-01-01T01:02:03Z"

}

data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "aks-sp-contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.aks-sp.object_id
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
  kubernetes_version = "1.15.7"

  service_principal = {
    object_id     = azuread_service_principal.aks-sp.object_id
    client_id     = azuread_service_principal.aks-sp.application_id
    client_secret = random_password.aks-sp.result
  }

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

  diagnostics = {
    enabled       = true
    destination   = var.log_analytic_workspace_id
    eventhub_name = null
    logs          = ["all"]
    metrics       = ["all"]
  }

  appgw_subnet_id   = module.azure-network-subnet.subnet_ids[1]

  appgw_ingress_controller_values   = { "verbosityLevel" = "5", "appgw.shared" = "true" }
  cert_manager_settings             = { "cainjector.nodeSelector.agentpool" = "default", "nodeSelector.agentpool" = "default", "webhook.nodeSelector.agentpool" = "default" }
  velero_storage_settings           = { allowed_cidrs = local.allowed_cidrs }

}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aadpodidentity\_chart\_version | AAD Pod Identity helm chart version to use | `string` | `"1.6.0"` | no |
| aadpodidentity\_namespace | Kubernetes namespace in which to deploy AAD Pod Identity | `string` | `"system-aadpodid"` | no |
| aadpodidentity\_values | Settings for AAD Pod identity helm Chart <br /><br><pre>map(object({ <br /><br>  nmi.nodeSelector.agentpool  = string <br /><br>  mic.nodeSelector.agentpool  = string <br /><br>  azureIdentity.enabled       = bool <br /><br>  azureIdentity.type          = string <br /><br>  azureIdentity.resourceID    = string <br /><br>  azureIdentity.clientID      = string <br /><br>  nmi.micNamespace            = string <br /><br>}))<br /><br></pre> | `map(string)` | `{}` | no |
| addons | Kubernetes addons to enable /disable | <pre>object({<br>    dashboard              = bool,<br>    oms_agent              = bool,<br>    oms_agent_workspace_id = string,<br>    policy                 = bool<br>  })</pre> | <pre>{<br>  "dashboard": false,<br>  "oms_agent": true,<br>  "oms_agent_workspace_id": null,<br>  "policy": false<br>}</pre> | no |
| api\_server\_authorized\_ip\_ranges | Ip ranges allowed to interract with Kubernetes API. Default no restrictions | `list(string)` | `[]` | no |
| appgw\_ingress\_controller\_values | Application Gateway Ingress Controller settings | `map(string)` | `{}` | no |
| appgw\_settings | Application gateway configuration settings. Default dummy configuration | `map(any)` | `{}` | no |
| appgw\_subnet\_id | Application gateway subnet id | `string` | n/a | yes |
| cert\_manager\_chart\_version | Cert Manager helm chart version to use | `string` | `"v0.13.0"` | no |
| cert\_manager\_namespace | Kubernetes namespace in which to deploy Cert Manager | `string` | `"system-cert-manager"` | no |
| cert\_manager\_settings | Settings for cert-manager helm chart | `map(string)` | `{}` | no |
| client\_name | Client name/account used in naming | `string` | n/a | yes |
| container\_registries | List of Azure Container Registries ids where AKS needs pull access. | `list(string)` | `[]` | no |
| custom\_aks\_name | Custom AKS name | `string` | `""` | no |
| custom\_appgw\_name | Custom name for AKS ingress application gateway | `string` | `""` | no |
| default\_node\_pool | Default node pool configuration. <br /><br><pre>map(object({ <br /><br>    name                  = string<br /><br>    count                 = number<br /><br>    vm\_size               = string<br /><br>    os\_type               = string<br /><br>    availability\_zones    = list(number)<br /><br>    enable\_auto\_scaling   = bool<br /><br>    min\_count             = number<br /><br>    max\_count             = number<br /><br>    type                  = string<br /><br>    node\_taints           = list(string)<br /><br>    vnet\_subnet\_id        = string<br /><br>    max\_pods              = number<br /><br>    os\_disk\_size\_gb       = number<br /><br>    enable\_node\_public\_ip = bool<br /><br>}))<br /></pre> | `map(any)` | `{}` | no |
| diag\_custom\_name | Custom name for Azure Diagnostics for AKS. | `string` | `null` | no |
| diagnostics | Enable and configure diagnostics logs on AKS. | <pre>object({<br>    enabled       = bool,<br>    destination   = string,<br>    eventhub_name = string,<br>    logs          = list(string),<br>    metrics       = list(string)<br>  })</pre> | n/a | yes |
| docker\_bridge\_cidr | IP address for docker with Network CIDR. | `string` | `"172.16.0.1/16"` | no |
| enable\_agic | Enable Application gateway ingress controller | `bool` | `true` | no |
| enable\_cert\_manager | Enable cert-manager on AKS cluster | `bool` | `true` | no |
| enable\_kured | Enable kured daemon on AKS cluster | `bool` | `true` | no |
| enable\_pod\_security\_policy | Enable pod security policy or not. https://docs.microsoft.com/fr-fr/azure/AKS/use-pod-security-policies | `bool` | `false` | no |
| enable\_velero | Enable velero on AKS cluster | `bool` | `true` | no |
| environment | Project environment | `string` | n/a | yes |
| extra\_tags | Extra tags to add | `map(string)` | `{}` | no |
| kubernetes\_version | Version of Kubernetes to deploy | `string` | `"1.15.7"` | no |
| kured\_settings | Settings for kured helm chart <br /><br><pre><br>map(object({ <br /><br>  image.repository         = string <br /><br>  image.tag                = string <br /><br>  image.pullPolicy         = string <br /><br>  extraArgs.reboot-days    = string <br /><br>  extraArgs.start-time     = string <br /><br>  extraArgs.end-time       = string <br /><br>  extraArgs.time-zone      = string <br /><br>  rbac.create              = string <br /><br>  podSecurityPolicy.create = string <br /><br>  serviceAccount.create    = string <br /><br>  autolock.enabled         = string <br /><br>}))<br /><br></pre> | `map(string)` | `{}` | no |
| linux\_profile | Username and ssh key for accessing AKS Linux nodes with ssh. | <pre>object({<br>    username = string,<br>    ssh_key  = string<br>  })</pre> | `null` | no |
| location | Azure region to use | `string` | n/a | yes |
| location\_short | Short name of Azure regions to use | `string` | n/a | yes |
| managed\_identities | List of managed identities where the AKS service principal should have access. | `list(string)` | `[]` | no |
| name\_prefix | prefix used in naming | `string` | `""` | no |
| node\_resource\_group | Name of the resource group in which to put AKS nodes. If null default to MC\_<AKS RG Name> | `string` | `null` | no |
| nodes\_pools | A list of nodes pools to create, each item supports same properties as `local.default_agent_profile` | `list(any)` | n/a | yes |
| nodes\_subnet\_id | Id of the subnet used for nodes | `string` | n/a | yes |
| resource\_group\_id | Id of the AKS resource group | `string` | n/a | yes |
| resource\_group\_name | Name of the AKS resource group | `string` | n/a | yes |
| service\_cidr | CIDR of service subnet. If subnet has UDR make sure this is routed correctly | `string` | n/a | yes |
| service\_principal | Service principal used by AKS to interract with Azure API | <pre>object({<br>    client_id     = string,<br>    client_secret = string,<br>    object_id     = string<br>  })</pre> | n/a | yes |
| stack | Project stack name | `string` | n/a | yes |
| storage\_contributor | List of storage accounts ids where the AKS service principal should have access. | `list(string)` | `[]` | no |
| velero\_chart\_version | Velero helm chart version to use | `string` | `"2.7.3"` | no |
| velero\_namespace | Kubernetes namespace in which to deploy Velero | `string` | `"system-velero"` | no |
| velero\_storage\_settings | Settings for Storage account and blob container for Velero <br /><br><pre><br>map(object({ <br /><br>  name                     = string <br /><br>  resource\_group\_name      = string <br /><br>  location                 = string <br /><br>  account\_tier             = string <br /><br>  account\_replication\_type = string <br /><br>  tags                     = map(any) <br /><br>  allowed\_cirds            = list(string) <br /><br>  container\_name           = string <br /><br>}))<br /><br></pre> | `map(any)` | `{}` | no |
| velero\_values | Settings for Velero helm chart<br><br><pre><br>map(object({ <br /><br>  configuration.backupStorageLocation.bucket                = string <br /><br>  configuration.backupStorageLocation.config.resourceGroup  = string <br /><br>  configuration.backupStorageLocation.config.storageAccount = string <br /><br>  configuration.backupStorageLocation.name                  = string <br /><br>  configuration.provider                                    = string <br /><br>  configuration.volumeSnapshotLocation.config.resourceGroup = string <br /><br>  configuration.volumeSnapshotLocation.name                 = string <br /><br>  credential.exstingSecret                                  = string <br /><br>  credentials.useSecret                                     = string <br /><br>  deployRestic                                              = string <br /><br>  env.AZURE\_CREDENTIALS\_FILE                                = string <br /><br>  metrics.enabled                                           = string <br /><br>  rbac.create                                               = string <br /><br>  schedules.daily.schedule                                  = string <br /><br>  schedules.daily.template.includedNamespaces               = string <br /><br>  schedules.daily.template.snapshotVolumes                  = string <br /><br>  schedules.daily.template.ttl                              = string <br /><br>  serviceAccount.server.create                              = string <br /><br>  snapshotsEnabled                                          = string <br /><br>  initContainers[0].name                                    = string <br /><br>  initContainers[0].image                                   = string <br /><br>  initContainers[0].volumeMounts[0].mountPath               = string <br /><br>  initContainers[0].volumeMounts[0].name                    = string <br /><br>  image.repository                                          = string <br /><br>  image.tag                                                 = string <br /><br>  image.pullPolicy                                          = string <br /><br><br>}))<br /><br></pre> | `map(string)` | `{}` | no |
| vnet\_id | Id of the vnet used for AKS | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aks\_id | AKS resource id |
| aks\_kube\_config | Kube configuration of AKS Cluster |
| aks\_kube\_config\_raw | Raw kube config to be used by kubectl command |
| aks\_name | Name of the AKS cluster |
| aks\_nodes\_pools\_ids | Ids of AKS nodes pools |
| aks\_nodes\_pools\_names | Names of AKS nodes pools |
| aks\_nodes\_rg | Name of the resource group in which AKS nodes are deployed |
| application\_gateway\_id | Id of the application gateway used by AKS |
| application\_gateway\_name | Name of the application gateway used by AKS |
| public\_ip\_id | Id of the public ip used by AKS application gateway |
| public\_ip\_name | Name of the public ip used by AKS application gateway |

## Related documentation

- Azure Kubernetes Service documentation : [docs.microsoft.com/en-us/azure/aks/](https://docs.microsoft.com/en-us/azure/aks/)
- Terraform AKS resource documentation: [www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html](https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html)
- Terraform AKS Node pool resource documentation: [www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster_node_pool.html](https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster_node_pool.html)
- Terraform Kubernetes provider documentation: [www.terraform.io/docs/providers/kubernetes/index.html](https://www.terraform.io/docs/providers/kubernetes/index.html)
- Terraform Helm provider documentation: [www.terraform.io/docs/providers/helm/index.html](https://www.terraform.io/docs/providers/helm/index.html)
- Kured documentation: [github.com/weaveworks/kured](https://github.com/weaveworks/kured)
- Velero documentation: [velero.io/docs/v1.2.0/](https://velero.io/docs/)
- Velero Azure specific documentation: [github.com/vmware-tanzu/velero-plugin-for-microsoft-azure](https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure)
- cert-manager documentation : [cert-manager.io/docs/](https://cert-manager.io/docs/)

