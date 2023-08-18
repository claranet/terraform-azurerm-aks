# Azure Kubernetes Service
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/aks/azurerm/)

This terraform module creates an [Azure Kubernetes Service](https://azure.microsoft.com/fr-fr/services/kubernetes-service/) and its associated [Azure Application Gateway](https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview) as ingress controller.

Inside the cluster default node pool, [velero](https://velero.io/docs/) and [cert-manager](https://cert-manager.io/docs/) are installed.

Inside each node pool, [Kured](https://github.com/weaveworks/kured) is installed as a daemonset.

This module also configures logging to a [Log Analytics Workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/learn/quick-create-workspace),
deploys the [Azure Active Directory Pod Identity](https://github.com/Azure/aad-pod-identity) and creates some
[Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/) with different types of Azure managed disks (Standard HDD retain and delete, Premium SSD retain and delete).

## Version compatibility

| Module version | Terraform version | AzureRM version |
| -------------- | ----------------- | --------------- |
| >= 5.x.x       | 0.15.x & 1.0.x    | >= 2.10         |
| >= 4.x.x       | 0.13.x            | >= 2.10         |
| >= 3.x.x       | 0.12.x            | >= 2.10         |
| >= 2.x.x       | 0.12.x            | < 2.0           |
| <  2.x.x       | 0.11.x            | < 2.0           |

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) too which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

The helm and kubernetes providers must be defined at the root level and then passed to the module via the provider block as in the examples.

<!-- BEGIN_TF_DOCS -->
## Global versioning rule for Claranet Azure modules

| Module version | Terraform version | AzureRM version |
| -------------- | ----------------- | --------------- |
| >= 7.x.x       | 1.3.x             | >= 3.0          |
| >= 6.x.x       | 1.x               | >= 3.0          |
| >= 5.x.x       | 0.15.x            | >= 2.0          |
| >= 4.x.x       | 0.13.x / 0.14.x   | >= 2.0          |
| >= 3.x.x       | 0.12.x            | >= 2.0          |
| >= 2.x.x       | 0.12.x            | < 2.0           |
| <  2.x.x       | 0.11.x            | < 2.0           |

## Contributing

If you want to contribute to this repository, feel free to use our [pre-commit](https://pre-commit.com/) git hook configuration
which will help you automatically update and format some files for you by enforcing our Terraform code module best-practices.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) tool
which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform-wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

```hcl
locals {
  allowed_cidrs = ["x.x.x.x", "y.y.y.y"]
}

module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "x.x.x"

  azure_region = var.azure_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "x.x.x"

  location    = module.azure_region.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack
}

module "azure_virtual_network" {
  source  = "claranet/vnet/azurerm"
  version = "x.x.x"

  environment    = var.environment
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  vnet_cidr = ["10.0.0.0/19"]
}

module "node_network_subnet" {
  source  = "claranet/subnet/azurerm"
  version = "x.x.x"

  environment    = var.environment
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  stack          = var.stack

  resource_group_name  = module.rg.resource_group_name
  virtual_network_name = module.azure_virtual_network.virtual_network_name

  name_suffix = "nodes"

  subnet_cidr_list = ["10.0.0.0/20"]

  service_endpoints = ["Microsoft.Storage"]
}

module "appgw_network_subnet" {
  source  = "claranet/subnet/azurerm"
  version = "x.x.x"

  environment    = var.environment
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  stack          = var.stack

  resource_group_name  = module.rg.resource_group_name
  virtual_network_name = module.azure_virtual_network.virtual_network_name

  name_suffix = "appgw"

  subnet_cidr_list = ["10.0.20.0/24"]
}

module "global_run" {
  source  = "claranet/run/azurerm"
  version = "x.x.x"

  client_name    = var.client_name
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  environment    = var.environment
  stack          = var.stack

  monitoring_function_splunk_token = var.monitoring_function_splunk_token

  resource_group_name = module.rg.resource_group_name

  tenant_id = var.azure_tenant_id
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

module "aks" {
  source  = "claranet/aks/azurerm"
  version = "x.x.x"

  providers = {
    kubernetes = kubernetes.aks-module
    helm       = helm.aks-module
  }

  client_name = var.client_name
  environment = var.environment
  stack       = var.stack

  resource_group_name = module.rg.resource_group_name
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short

  private_cluster_enabled = false
  service_cidr            = "10.0.16.0/22"
  kubernetes_version      = "1.19.7"

  vnet_id         = module.azure_virtual_network.virtual_network_id
  nodes_subnet_id = module.node_network_subnet.subnet_id
  nodes_pools = [
    {
      name            = "pool1"
      count           = 1
      vm_size         = "Standard_D1_v2"
      os_type         = "Linux"
      os_disk_type    = "Ephemeral"
      os_disk_size_gb = 30
      vnet_subnet_id  = module.node_network_subnet.subnet_id
    },
    {
      name                = "bigpool1"
      count               = 3
      vm_size             = "Standard_F8s_v2"
      os_type             = "Linux"
      os_disk_size_gb     = 30
      vnet_subnet_id      = module.node_network_subnet.subnet_id
      enable_auto_scaling = true
      min_count           = 3
      max_count           = 9
    }
  ]

  linux_profile = {
    username = "nodeadmin"
    ssh_key  = tls_private_key.key.public_key_openssh
  }

  oms_log_analytics_workspace_id = module.global_run.log_analytics_workspace_id
  azure_policy_enabled           = false

  logs_destinations_ids = [module.global_run.log_analytics_workspace_id]

  appgw_subnet_id = module.appgw_network_subnet.subnet_id

  appgw_ingress_controller_values = { "verbosityLevel" = 5, "appgw.shared" = true }
  cert_manager_settings           = { "cainjector.nodeSelector.agentpool" = "default", "nodeSelector.agentpool" = "default", "webhook.nodeSelector.agentpool" = "default" }
  velero_storage_settings         = { allowed_cidrs = local.allowed_cidrs }

  container_registries_id = [module.acr.acr_id]

  key_vault_secrets_provider = {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }
}

module "acr" {
  source  = "claranet/acr/azurerm"
  version = "x.x.x"

  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  resource_group_name = module.rg.resource_group_name
  sku                 = "Standard"

  client_name = var.client_name
  environment = var.environment
  stack       = var.stack

  logs_destinations_ids = [module.global_run.log_analytics_workspace_id]
}
```

## Providers

| Name | Version |
|------|---------|
| azuread | ~> 2.31 |
| azurecaf | ~> 1.2, >= 1.2.22 |
| azurerm | ~> 3.39 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| appgw | ./tools/agic | n/a |
| certmanager | ./tools/cert-manager | n/a |
| diagnostic\_settings | claranet/diagnostic-settings/azurerm | ~> 6.4.1 |
| infra | ./modules/infra | n/a |
| kured | ./tools/kured | n/a |
| velero | ./tools/velero | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.node_pools](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_resource_policy_assignment.aks_policy_kubenet_aadpodidentity_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_policy_assignment) | resource |
| [azurerm_role_assignment.aad_pod_identity_mio_appgw_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aci_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_acr_pull_allowed](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_kubelet_uai_vnet_network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_uai_private_dns_zone_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_uai_route_table_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_uai_vnet_network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_user_assigned](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.aks_user_assigned_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.appgw_assigned_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azuread_service_principal.aci_identity](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azurecaf_name.aks](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.aks_identity](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.appgw](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.appgw_identity](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurerm_policy_definition.aks_policy_kubenet_aadpodidentity_definition](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [azurerm_virtual_network.aks_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aadpodidentity\_chart\_repository | AAD Pod Identity Helm chart repository URL | `string` | `"https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"` | no |
| aadpodidentity\_chart\_version | AAD Pod Identity helm chart version to use | `string` | `"4.1.9"` | no |
| aadpodidentity\_custom\_name | Custom name for aad pod identity MSI | `string` | `"aad-pod-identity"` | no |
| aadpodidentity\_extra\_tags | Extra Tags to add to aad pod identity MSI | `map(string)` | `{}` | no |
| aadpodidentity\_kubenet\_policy\_enabled | Boolean to wether deploy or not a built-in Azure Policy at the cluster level<br>  to mitigate potential security issue with aadpodidentity used with kubenet :<br>  https://docs.microsoft.com/en-us/azure/aks/use-azure-ad-pod-identity#using-kubenet-network-plugin-with-azure-active-directory-pod-managed-identities " | `bool` | `false` | no |
| aadpodidentity\_namespace | Kubernetes namespace in which to deploy AAD Pod Identity | `string` | `"system-aadpodid"` | no |
| aadpodidentity\_values | Settings for AAD Pod identity helm Chart:<pre>map(object({<br>  nmi.nodeSelector.agentpool    = string<br>  mic.nodeSelector.agentpool    = string<br>  azureIdentity.enabled         = bool<br>  azureIdentity.type            = string<br>  azureIdentity.resourceID      = string<br>  azureIdentity.clientID        = string<br>  nmi.micNamespace              = string<br>}))</pre> | `map(string)` | `{}` | no |
| aci\_subnet\_id | Optional subnet Id used for ACI virtual-nodes | `string` | `null` | no |
| agic\_chart\_repository | Helm chart repository URL | `string` | `"https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"` | no |
| agic\_chart\_version | Version of the Helm chart | `string` | `"1.5.2"` | no |
| agic\_enabled | Enable Application gateway ingress controller | `bool` | `true` | no |
| agic\_helm\_version | [DEPRECATED] Version of Helm chart to deploy | `string` | `null` | no |
| aks\_http\_proxy\_settings | AKS HTTP proxy settings. URLs must be in format `http(s)://fqdn:port/`. When setting the `no_proxy_url_list` parameter, the AKS Private Endpoint domain name and the AKS VNet CIDR must be added to the URLs list. | <pre>object({<br>    http_proxy_url    = optional(string)<br>    https_proxy_url   = optional(string)<br>    no_proxy_url_list = optional(list(string), [])<br>    trusted_ca        = optional(string)<br>  })</pre> | `null` | no |
| aks\_network\_plugin | AKS network plugin to use. Possible values are `azure` and `kubenet`. Changing this forces a new resource to be created | `string` | `"azure"` | no |
| aks\_network\_policy | AKS network policy to use. | `string` | `"calico"` | no |
| aks\_pod\_cidr | CIDR used by pods when network plugin is set to `kubenet`. https://docs.microsoft.com/en-us/azure/aks/configure-kubenet | `string` | `"172.17.0.0/16"` | no |
| aks\_route\_table\_id | Provide an existing route table when `outbound_type variable` is set to `userdefinedrouting` with kubenet : https://docs.microsoft.com/fr-fr/azure/aks/configure-kubenet#bring-your-own-subnet-and-route-table-with-kubenet | `string` | `null` | no |
| aks\_sku\_tier | aks sku tier. Possible values are Free ou Paid | `string` | `"Free"` | no |
| aks\_user\_assigned\_identity\_custom\_name | Custom name for the aks user assigned identity resource | `string` | `null` | no |
| aks\_user\_assigned\_identity\_resource\_group\_name | Resource Group where to deploy the aks user assigned identity resource. Used when private cluster is enabled and when Azure private dns zone is not managed by aks | `string` | `null` | no |
| aks\_user\_assigned\_identity\_tags | Tags to add to AKS MSI | `map(string)` | `{}` | no |
| api\_server\_authorized\_ip\_ranges | Ip ranges allowed to interract with Kubernetes API. Default no restrictions | `list(string)` | `[]` | no |
| appgw\_identity\_enabled | Configure a managed service identity for Application gateway used with AGIC (useful to configure ssl cert into appgw from keyvault) | `bool` | `false` | no |
| appgw\_ingress\_controller\_values | Application Gateway Ingress Controller settings | `map(string)` | `{}` | no |
| appgw\_private\_ip | Private IP for Application Gateway. Used when variable `private_ingress` is set to `true`. | `string` | `null` | no |
| appgw\_settings | Application gateway configuration settings. Default dummy configuration | `map(any)` | `{}` | no |
| appgw\_ssl\_certificates\_configs | Application gateway ssl certificates configuration | `list(map(string))` | `[]` | no |
| appgw\_subnet\_id | Application gateway subnet id | `string` | `""` | no |
| appgw\_user\_assigned\_identity\_custom\_name | Custom name for the application gateway user assigned identity resource | `string` | `null` | no |
| appgw\_user\_assigned\_identity\_resource\_group\_name | Resource Group where to deploy the Application Gateway User Assigned Identity resource. | `string` | `null` | no |
| application\_gateway\_id | ID of an existing Application Gateway to use as an AGIC. `use_existing_application_gateway` must be set to `true`. | `string` | `null` | no |
| auto\_scaler\_profile | Configuration of `auto_scaler_profile` block object | <pre>object({<br>    balance_similar_node_groups      = optional(bool, false)<br>    expander                         = optional(string, "random")<br>    max_graceful_termination_sec     = optional(number, 600)<br>    max_node_provisioning_time       = optional(string, "15m")<br>    max_unready_nodes                = optional(number, 3)<br>    max_unready_percentage           = optional(number, 45)<br>    new_pod_scale_up_delay           = optional(string, "10s")<br>    scale_down_delay_after_add       = optional(string, "10m")<br>    scale_down_delay_after_delete    = optional(string, "10s")<br>    scale_down_delay_after_failure   = optional(string, "3m")<br>    scan_interval                    = optional(string, "10s")<br>    scale_down_unneeded              = optional(string, "10m")<br>    scale_down_unready               = optional(string, "20m")<br>    scale_down_utilization_threshold = optional(number, 0.5)<br>    empty_bulk_delete_max            = optional(number, 10)<br>    skip_nodes_with_local_storage    = optional(bool, true)<br>    skip_nodes_with_system_pods      = optional(bool, true)<br>  })</pre> | `null` | no |
| azure\_policy\_enabled | Should the Azure Policy Add-On be enabled? | `bool` | `false` | no |
| cert\_manager\_chart\_repository | Helm chart repository URL | `string` | `"https://charts.jetstack.io"` | no |
| cert\_manager\_chart\_version | Cert Manager helm chart version to use | `string` | `"v1.8.0"` | no |
| cert\_manager\_namespace | Kubernetes namespace in which to deploy Cert Manager | `string` | `"system-cert-manager"` | no |
| cert\_manager\_settings | Settings for cert-manager helm chart | `map(string)` | `{}` | no |
| client\_name | Client name/account used in naming | `string` | n/a | yes |
| container\_registries\_id | List of Azure Container Registries ids where AKS needs pull access. | `list(string)` | `[]` | no |
| custom\_aks\_name | Custom AKS name | `string` | `""` | no |
| custom\_appgw\_name | Custom name for AKS ingress application gateway | `string` | `""` | no |
| custom\_diagnostic\_settings\_name | Custom name of the diagnostics settings, name will be 'default' if not set. | `string` | `"default"` | no |
| default\_node\_pool | Default node pool configuration | <pre>object({<br>    name                   = optional(string, "default")<br>    node_count             = optional(number, 1)<br>    vm_size                = optional(string, "Standard_D2_v3")<br>    os_type                = optional(string, "Linux")<br>    workload_runtime       = optional(string, null)<br>    zones                  = optional(list(number), [1, 2, 3])<br>    enable_auto_scaling    = optional(bool, false)<br>    min_count              = optional(number, 1)<br>    max_count              = optional(number, 10)<br>    type                   = optional(string, "VirtualMachineScaleSets")<br>    node_taints            = optional(list(any), null)<br>    node_labels            = optional(map(any), null)<br>    orchestrator_version   = optional(string, null)<br>    priority               = optional(string, null)<br>    enable_host_encryption = optional(bool, null)<br>    eviction_policy        = optional(string, null)<br>    max_pods               = optional(number, 30)<br>    os_disk_type           = optional(string, "Managed")<br>    os_disk_size_gb        = optional(number, 128)<br>    enable_node_public_ip  = optional(bool, false)<br>    scale_down_mode        = optional(string, "Delete")<br>  })</pre> | `{}` | no |
| default\_node\_pool\_tags | Specific tags for default node pool | `map(string)` | `{}` | no |
| default\_tags\_enabled | Option to enable or disable default tags | `bool` | `true` | no |
| docker\_bridge\_cidr | IP address for docker with Network CIDR. | `string` | `"172.16.0.1/16"` | no |
| enable\_cert\_manager | Enable cert-manager on AKS cluster | `bool` | `true` | no |
| enable\_kured | Enable kured daemon on AKS cluster | `bool` | `true` | no |
| enable\_pod\_security\_policy | Enable pod security policy or not. https://docs.microsoft.com/fr-fr/azure/AKS/use-pod-security-policies | `bool` | `false` | no |
| enable\_velero | Enable velero on AKS cluster | `bool` | `true` | no |
| environment | Project environment | `string` | n/a | yes |
| extra\_tags | Extra tags to add | `map(string)` | `{}` | no |
| http\_application\_routing\_enabled | Whether HTTP Application Routing is enabled. | `bool` | `false` | no |
| key\_vault\_secrets\_provider | Enable AKS built-in Key Vault secrets provider. If enabled, an identity is created by the AKS itself and exported from this module. | <pre>object({<br>    secret_rotation_enabled  = optional(bool)<br>    secret_rotation_interval = optional(string)<br>  })</pre> | `null` | no |
| kubernetes\_version | Version of Kubernetes to deploy | `string` | `"1.17.9"` | no |
| kured\_chart\_repository | Helm chart repository URL | `string` | `"https://kubereboot.github.io/charts"` | no |
| kured\_chart\_version | Version of the Helm chart | `string` | `"2.2.0"` | no |
| kured\_settings | Settings for kured helm chart:<pre>map(object({<br>  image.repository         = string<br>  image.tag                = string<br>  image.pullPolicy         = string<br>  extraArgs.reboot-days    = string<br>  extraArgs.start-time     = string<br>  extraArgs.end-time       = string<br>  extraArgs.time-zone      = string<br>  rbac.create              = string<br>  podSecurityPolicy.create = string<br>  serviceAccount.create    = string<br>  autolock.enabled         = string<br>}))</pre> | `map(string)` | `{}` | no |
| linux\_profile | Username and ssh key for accessing AKS Linux nodes with ssh. | <pre>object({<br>    username = string,<br>    ssh_key  = string<br>  })</pre> | `null` | no |
| location | Azure region to use | `string` | n/a | yes |
| location\_short | Short name of Azure regions to use | `string` | n/a | yes |
| logs\_categories | Log categories to send to destinations. | `list(string)` | `null` | no |
| logs\_destinations\_ids | List of destination resources IDs for logs diagnostic destination.<br>Can be `Storage Account`, `Log Analytics Workspace` and `Event Hub`. No more than one of each can be set.<br>If you want to specify an Azure EventHub to send logs and metrics to, you need to provide a formated string with both the EventHub Namespace authorization send ID and the EventHub name (name of the queue to use in the Namespace) separated by the `|` character. | `list(string)` | n/a | yes |
| logs\_kube\_audit\_enabled | Whether to include `kube-audit` and `kube-audit-admin` logs from diagnostics settings collection. Enabling this can increase your Azure billing. | `bool` | `false` | no |
| logs\_metrics\_categories | Metrics categories to send to destinations. | `list(string)` | `null` | no |
| logs\_retention\_days | Number of days to keep logs on storage account. | `number` | `30` | no |
| name\_prefix | Optional prefix for the generated name | `string` | `""` | no |
| name\_suffix | Optional suffix for the generated name | `string` | `""` | no |
| node\_pool\_tags | Specific tags for node pool | `map(string)` | `{}` | no |
| node\_resource\_group | Name of the resource group in which to put AKS nodes. If null default to MC\_<AKS RG Name> | `string` | `null` | no |
| nodes\_pools | A list of nodes pools to create, each item supports same properties as `local.default_agent_profile` | `list(any)` | `[]` | no |
| nodes\_subnet\_id | ID of the subnet used for nodes | `string` | n/a | yes |
| oidc\_issuer\_enabled | Whether to enable OpenID Connect issuer or not. https://learn.microsoft.com/en-us/azure/aks/use-oidc-issuer | `bool` | `false` | no |
| oms\_log\_analytics\_workspace\_id | The ID of the Log Analytics Workspace used to send OMS logs | `string` | n/a | yes |
| outbound\_type | The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are `loadBalancer` and `userDefinedRouting`. | `string` | `"loadBalancer"` | no |
| private\_cluster\_enabled | Configure AKS as a Private Cluster: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_cluster_enabled | `bool` | `true` | no |
| private\_dns\_zone\_id | Id of the private DNS Zone when <private\_dns\_zone\_type> is custom | `string` | `null` | no |
| private\_dns\_zone\_role\_assignment\_enabled | Option to enable or disable Private DNS Zone role assignment. | `bool` | `true` | no |
| private\_dns\_zone\_type | Set AKS private dns zone if needed and if private cluster is enabled (privatelink.<region>.azmk8s.io)<br>- "Custom" : You will have to deploy a private Dns Zone on your own and pass the id with <private\_dns\_zone\_id> variable<br>If this settings is used, aks user assigned identity will be "userassigned" instead of "systemassigned"<br>and the aks user must have "Private DNS Zone Contributor" role on the private DNS Zone<br>- "System" : AKS will manage the private zone and create it in the same resource group as the Node Resource Group<br>- "None" : In case of None you will need to bring your own DNS server and set up resolving, otherwise cluster will have issues after provisioning.<br><br>https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_dns_zone_id | `string` | `"System"` | no |
| private\_ingress | Private ingress boolean variable. When `true`, the default http listener will listen on private IP instead of the public IP. | `bool` | `false` | no |
| resource\_group\_name | Name of the AKS resource group | `string` | n/a | yes |
| service\_cidr | CIDR used by kubernetes services (kubectl get svc). | `string` | n/a | yes |
| stack | Project stack name | `string` | n/a | yes |
| use\_caf\_naming | Use the Azure CAF naming provider to generate default resource name. `custom_aks_name` override this if set. Legacy default name is used if this is set to `false`. | `bool` | `true` | no |
| use\_existing\_application\_gateway | True to use an existing Application Gateway instead of creating a new one.<br>If true you may use `appgw_ingress_controller_values = { appgw.shared = true }` to tell AGIC to not erase the whole Application Gateway configuration with its own configuration.<br>You also have to deploy AzureIngressProhibitedTarget CRD.<br>https://github.com/Azure/application-gateway-kubernetes-ingress/blob/072626cb4e37f7b7a1b0c4578c38d1eadc3e8701/docs/setup/install-existing.md#multi-cluster--shared-app-gateway | `bool` | `false` | no |
| velero\_chart\_repository | URL of the Helm chart repository | `string` | `"https://vmware-tanzu.github.io/helm-charts"` | no |
| velero\_chart\_version | Velero helm chart version to use | `string` | `"2.29.5"` | no |
| velero\_identity\_custom\_name | Name of the Velero MSI | `string` | `"velero"` | no |
| velero\_identity\_extra\_tags | Extra tags to add to velero MSI | `map(string)` | `{}` | no |
| velero\_namespace | Kubernetes namespace in which to deploy Velero | `string` | `"system-velero"` | no |
| velero\_storage\_settings | Settings for Storage account and blob container for Velero | <pre>object({<br>    name                     = optional(string)<br>    resource_group_name      = optional(string)<br>    location                 = optional(string)<br>    account_tier             = optional(string)<br>    account_replication_type = optional(string)<br>    tags                     = optional(map(any))<br>    allowed_cidrs            = optional(list(string))<br>    allowed_subnet_ids       = optional(list(string))<br>    container_name           = optional(string)<br>  })</pre> | `{}` | no |
| velero\_values | Settings for Velero helm chart:<pre>map(object({<br>  configuration.backupStorageLocation.bucket                = string<br>  configuration.backupStorageLocation.config.resourceGroup  = string<br>  configuration.backupStorageLocation.config.storageAccount = string<br>  configuration.backupStorageLocation.name                  = string<br>  configuration.provider                                    = string<br>  configuration.volumeSnapshotLocation.config.resourceGroup = string<br>  configuration.volumeSnapshotLocation.name                 = string<br>  credential.exstingSecret                                  = string<br>  credentials.useSecret                                     = string<br>  deployRestic                                              = string<br>  env.AZURE_CREDENTIALS_FILE                                = string<br>  metrics.enabled                                           = string<br>  rbac.create                                               = string<br>  schedules.daily.schedule                                  = string<br>  schedules.daily.template.includedNamespaces               = string<br>  schedules.daily.template.snapshotVolumes                  = string<br>  schedules.daily.template.ttl                              = string<br>  serviceAccount.server.create                              = string<br>  snapshotsEnabled                                          = string<br>  initContainers[0].name                                    = string<br>  initContainers[0].image                                   = string<br>  initContainers[0].volumeMounts[0].mountPath               = string<br>  initContainers[0].volumeMounts[0].name                    = string<br>  image.repository                                          = string<br>  image.tag                                                 = string<br>  image.pullPolicy                                          = string<br>}))</pre> | `map(string)` | `{}` | no |
| vnet\_id | Vnet id that Aks MSI should be network contributor in a private cluster | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| aad\_pod\_identity\_azure\_identity | Identity object for AAD Pod Identity |
| aad\_pod\_identity\_namespace | Namespace used for AAD Pod Identity |
| agic\_namespace | Namespace used for AGIC |
| aks\_id | AKS resource id |
| aks\_kube\_config | Kube configuration of AKS Cluster |
| aks\_kube\_config\_raw | Raw kube config to be used by kubectl command |
| aks\_kubelet\_user\_managed\_identity | The Kubelet User Managed Identity used by the AKS cluster. |
| aks\_name | Name of the AKS cluster |
| aks\_nodes\_pools\_ids | Ids of AKS nodes pools |
| aks\_nodes\_pools\_names | Names of AKS nodes pools |
| aks\_nodes\_rg | Name of the resource group in which AKS nodes are deployed |
| aks\_user\_managed\_identity | The User Managed Identity used by the AKS cluster. |
| application\_gateway\_id | Id of the application gateway used by AKS |
| application\_gateway\_identity\_principal\_id | Id of the managed service identity of the application gateway used by AKS |
| application\_gateway\_name | Name of the application gateway used by AKS |
| cert\_manager\_namespace | Namespace used for Cert Manager |
| key\_vault\_secrets\_provider\_identity | The User Managed Identity used by the Key Vault secrets provider. |
| kured\_namespace | Namespace used for Kured |
| oidc\_issuer\_url | The URL of the OpenID Connect issuer. |
| public\_ip\_id | Id of the public ip used by AKS application gateway |
| public\_ip\_name | Name of the public ip used by AKS application gateway |
| velero\_identity | Azure Identity used for Velero pods |
| velero\_namespace | Namespace used for Velero |
| velero\_storage\_account | Storage Account on which Velero data is stored. |
| velero\_storage\_account\_container | Container in Storage Account on which Velero data is stored. |
<!-- END_TF_DOCS -->
## Related documentation

- Azure Kubernetes Service documentation : [docs.microsoft.com/en-us/azure/aks/](https://docs.microsoft.com/en-us/azure/aks/)
- Azure Kubernetes Service MSI Usage : [docs.microsoft.com/en-us/azure/aks/use-managed-identity](https://docs.microsoft.com/en-us/azure/aks/use-managed-identity)
- Azure Kubernetes Service User-Defined Route usage : [docs.microsoft.com/en-us/azure/aks/egress-outboundtype](https://docs.microsoft.com/en-us/azure/aks/egress-outboundtype)
- Terraform Kubernetes provider documentation: [www.terraform.io/docs/providers/kubernetes/index.html](https://www.terraform.io/docs/providers/kubernetes/index.html)
- Terraform Helm provider documentation: [www.terraform.io/docs/providers/helm/index.html](https://www.terraform.io/docs/providers/helm/index.html)
- Kured documentation: [github.com/weaveworks/kured](https://github.com/weaveworks/kured)
- Velero documentation: [velero.io/docs/v1.2.0/](https://velero.io/docs/)
- Velero Azure specific documentation: [github.com/vmware-tanzu/velero-plugin-for-microsoft-azure](https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure)
- cert-manager documentation : [cert-manager.io/docs/](https://cert-manager.io/docs/)
