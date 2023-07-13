# Azure Kubernetes Service - Core Azure tools
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/aks/azurerm/latest/submodules/infra)

This module deploys the [Azure Active Directory Pod Identity](https://github.com/Azure/aad-pod-identity) and creates some
[Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/) with different types of Azure managed disks (Standard HDD retain and delete, Premium SSD retain and delete).

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

More details are available in the [CONTRIBUTING.md](../../CONTRIBUTING.md#pull-request-process) file.

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

  private_cluster_enabled = true
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
| azurerm | >= 2.51 |
| helm | >= 2.5.1 |
| kubernetes | >= 2.11.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.aad_pod_identity_msi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.aad_pod_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [helm_release.aad_pod_identity](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_cluster_role.containerlogs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.containerlogs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_namespace.add_pod_identity](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_storage_class.managed_premium_delete](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |
| [kubernetes_storage_class.managed_premium_retain](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |
| [kubernetes_storage_class.managed_standard_delete](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |
| [kubernetes_storage_class.managed_standard_retain](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aadpodidentity\_chart\_repository | URL of the Helm chart repository | `string` | `"https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"` | no |
| aadpodidentity\_chart\_version | Azure Active Directory Pod Identity Chart version | `string` | `"4.1.9"` | no |
| aadpodidentity\_custom\_name | Custom name for aad pod identity MSI | `string` | `"aad-pod-identity"` | no |
| aadpodidentity\_extra\_tags | Extra tags to add to aad pod identity MSI | `map(string)` | `{}` | no |
| aadpodidentity\_namespace | Kubernetes namespace in which to deploy AAD Pod Identity | `string` | `"system-aadpodid"` | no |
| aadpodidentity\_values | Settings for AAD Pod identity helm Chart <br /><br><pre>map(object({ <br /><br>  nmi.nodeSelector.agentpool  = string <br /><br>  mic.nodeSelector.agentpool  = string <br /><br>  azureIdentity.enabled       = bool <br /><br>  azureIdentity.type          = string <br /><br>  azureIdentity.resourceID    = string <br /><br>  azureIdentity.clientID      = string <br /><br>  nmi.micNamespace            = string <br /><br>}))<br /><br></pre> | `map(string)` | `{}` | no |
| aks\_network\_plugin | AKS network plugin to use. Possible values are `azure` and `kubenet`.<br>  Changing this forces a new resource to be created. | `string` | `"azure"` | no |
| aks\_resource\_group\_name | Name of the AKS Managed resource group. Eg MC\_xxxx | `string` | n/a | yes |
| location | AKS Cluster location | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aad\_pod\_identity\_azure\_identity | Identity object for AAD Pod Identity |
| aad\_pod\_identity\_client\_id | Client ID of the User MSI used for AAD Pod Identity |
| aad\_pod\_identity\_id | ID of the User MSI used for AAD Pod Identity |
| aad\_pod\_identity\_namespace | Namespace used for AAD Pod Identity |
| aad\_pod\_identity\_principal\_id | Principal ID of the User MSI used for AAD Pod Identity |
<!-- END_TF_DOCS -->
## Related documentation

- AAD Pod Identity : [github.com/Azure/aad-pod-identity](https://github.com/Azure/aad-pod-identity)
