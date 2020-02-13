# Azure Kubernetes Service
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/aks/azurerm/)

This terraform module create an [Azure Kubernetes Service](https://azure.microsoft.com/fr-fr/services/kubernetes-service/) and associated [Azure Application Gateway](https://azure.microsoft.com/fr-fr/services/application-gateway/) as ingress controller.

Inside the cluster, velero, kured and cert-manager are also installed.


## Requirements and limitations

  * [Azurerm Terraform provider](https://registry.terraform.io/providers/hashicorp/azurerm/1.43.0) >= 1.43
  * [Helm Terraform provider](https://registry.terraform.io/providers/hashicorp/helm/1.0.0) >= 1.0.0
  * [Kubernetes Terraform provider](https://registry.terraform.io/providers/hashicorp/kubernetes/1.11.0) >= 1.11
  * [Kubectl command](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
  * A Microsoft.Storage [service endpoint](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview) into the nodes subnet
  
## Terraform version compatibility

| Module version | Terraform version |
| -------------- | ----------------- |
| >= 2.x.x       | 0.12.x            |
| < 2.x.x        | 0.11.x            |

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
  kubernetes_version = "1.14.8"

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
    dashboard              = false,
    oms_agent              = true,
    oms_agent_workspace_id = module.global_run.log_analytics_workspace_id
    policy                 = false
  }

  diagnostics = {
    enabled       = true
    destination   = module.global_run.log_analytics_workspace_id
    eventhub_name = null
    logs          = ["all"]
    metrics       = ["all"]
  }

  appgw_subnet_id   = module.azure-network-subnet.subnet_ids[1]

  appgw_ingress_controller_values   = { "verbosityLevel" = "5", "appgw.shared" = "true" }
  cert_manager_settings             = { "cainjector.nodeSelector.agentpool" = "default", "nodeSelector.agentpool" = "default", "webhook.nodeSelector.agentpool" = "default" }
  velero_storage_settings           = { allowed_cidrs = local.allowed_cidrs }

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
  application_id = azuread_application.aks-sp.id
}

resource "random_password" "aks-sp" {
  length  = 32
  special = true
}

resource "azuread_service_principal_password" "aks-sp" {
  service_principal_id = azuread_service_principal.aks-sp.id
  value                = random_password.aks-sp.result
}

data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "aks-sp-contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.aks-sp.object_id
}
```

## Inputs


| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| aadpodidentity\_values | (Optional) Settings for Add Pod identity helm Chart | `map(string)` | `{}` | no |
| addons | (Optional) Kubernetes addons to enable /disable | <pre>object({<br>    dashboard              = bool,<br>    oms_agent              = bool,<br>    oms_agent_workspace_id = string,<br>    policy                 = bool<br>  })</pre> | <pre>{<br>  "dashboard": false,<br>  "oms_agent": true,<br>  "oms_agent_workspace_id": null,<br>  "policy": false<br>}</pre> | no |
| api\_server\_authorized\_ip\_ranges | (Optional) Ip ranges allowed to interract with Kubernetes API. Default no restrictions | `list(string)` | `[]` | no |
| appgw\_ingress\_controller\_settings | (Optional) Application Gateway Ingress Controller settings | `map(string)` | `{}` | no |
| appgw\_settings | (Optional) Application gateway configuration settings. Default dummy configuration | `map(any)` | `{}` | no |
| appgw\_subnet\_id | Application gateway subnet id | `string` | n/a | yes |
| cert\_manager\_settings | (Optional) Settings for cert-manager helm chart | `map(string)` | `{}` | no |
| client\_name | Client name/account used in naming | `string` | n/a | yes |
| container\_registries | (Optional) List of Azure Container Registries ids where AKS needs pull access. | `list(string)` | `[]` | no |
| custom\_aks\_name | (Optional) Custom aks name | `string` | `""` | no |
| custom\_appgw\_name | (Optional) Custom name for aks ingress application gateway | `string` | `""` | no |
| default\_node\_pool | (Optional) Default node pool configuration | `map(any)` | `{}` | no |
| diag\_custom\_name | (Optionnal) Custom name for Azure Diagnostics for AKS. | `string` | null | no |
| diagnostics | Enable diagnostics logs on AKS | <pre>object({<br>    enabled       = bool,<br>    destination   = string,<br>    eventhub_name = string,<br>    logs          = list(string),<br>    metrics       = list(string)<br>  })</pre> | n/a | yes |
| docker\_bridge\_cidr | (Optional) IP address for docker with Network CIDR. | `string` | `"172.16.0.1/16"` | no |
| enable\_cert\_manager | (Optional) Enable cert-manager on AKS cluster | `bool` | `true` | no |
| enable\_kured | (Optional) Enable kured daemon on AKS cluster | `bool` | `true` | no |
| enable\_pod\_security\_policy | (Optional) Enable pod security policy or not. https://docs.microsoft.com/fr-fr/azure/aks/use-pod-security-policies | `bool` | `false` | no |
| enable\_velero | (Optional) Enable velero on AKS cluster | `bool` | `true` | no |
| environment | Project environment | `string` | n/a | yes |
| extra\_tags | (Optional) Extra tags to add | `map(string)` | `{}` | no |
| kubernetes\_version | Version of Kubernetes to deploy | `string` | n/a | yes |
| kured\_settings | (Optional) Settings for kured helm chart | `map(string)` | `{}` | no |
| linux\_profile | Username and ssh key for accessing AKS Linux nodes with ssh. | <pre>object({<br>    username = string,<br>    ssh_key  = string<br>  })</pre> | n/a | yes |
| location | Azure region to use | `string` | n/a | yes |
| location\_short | Short name of Azure regions to use | `any` | n/a | yes |
| managed\_identities | (Optional) List of managed identities where the AKS service principal should have access. | `list(string)` | `[]` | no |
| node\_resource\_group | (Optional) Name of the resource group in which to put AKS nodes. If null default to MC\_<AKS RG Name> | `string` | null | no |
| nodes\_pools | A list of nodes pools to create, each item supports same properties as `local.default_agent_profile` | `list(any)` | n/a | yes |
| nodes\_subnet\_id | Id of the subnet used for nodes | `string` | n/a | yes |
| resource\_group\_name | Name of the AKS resource group | `string` | n/a | yes |
| service\_accounts | (Optionnal) List of service accounts to create and their roles. | <pre>list(object({<br>    name      = string,<br>    namespace = string,<br>    role      = string<br>  }))</pre> | `[]` | no |
| service\_cidr | CIDR of service subnet. If subnet has UDR make sure this is routed correctly | `any` | n/a | yes |
| service\_principal | Service principal used by AKS to interract with Azure API | <pre>object({<br>    client_id     = string,<br>    client_secret = string,<br>    object_id     = string<br>  })</pre> | n/a | yes |
| stack | Project stack name | `string` | n/a | yes |
| storage\_contributor | (Optional) List of storage accounts ids where the AKS service principal should have access. | `list(string)` | `[]` | no |
| velero\_settings | (Optional) Settings for Velero helm chart | `map(string)` | `{}` | no |
| velero\_storage\_settings | (Optional) Settings for Storage account and blob container for Velero | `map(any)` | `{}` | no |
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

## Related documentation

- Azure Kubernetes Service documentation : [docs.microsoft.com/en-us/azure/aks/](https://docs.microsoft.com/en-us/azure/aks/)
- Terraform AKS resource documentation: [www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html](https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html)
- Terraform AKS Node pool resource documentation: [www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster_node_pool.html](https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster_node_pool.html)
- Terraform Kubernetes provider documentation: [www.terraform.io/docs/providers/kubernetes/index.html](https://www.terraform.io/docs/providers/kubernetes/index.html)
- Terraform Helm provider documentation: [www.terraform.io/docs/providers/helm/index.html](https://www.terraform.io/docs/providers/helm/index.html)
- Kured documentation: [github.com/weaveworks/kured](https://github.com/weaveworks/kured)
- Velero documentation: [velero.io/docs/v1.2.0/](https://velero.io/docs/v1.2.0/)
- Velero Azure specific documentation: [github.com/vmware-tanzu/velero-plugin-for-microsoft-azure](https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure)
- cert-manager documentation : [cert-manager.io/docs/](https://cert-manager.io/docs/)

