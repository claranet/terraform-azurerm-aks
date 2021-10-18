# Azure Kubernetes Service - Core Azure tools
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/aks/azurerm/latest/submodules/infra)

This module deploys the [Azure Active Directory Pod Identity](https://github.com/Azure/aad-pod-identity) and creates some 
[Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/) with different types of Azure managed disks (Standard HDD retain and delete, Premium SSD retain and delete).

## Version compatibility

| Module version | Terraform version | AzureRM Version |
| -------------- | ----------------- | --------------- |
| >= 5.x.x       | 0.15.x & 1.0.x    | ~>2.10.0        |
| >= 4.x.x       | 0.13.x            | ~>2.10.0        |
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

resource "azurerm_kubernetes_cluster" "aks" {
  ...
}

data "azurerm_resource_group" "aks_nodes_rg" {
  name = azurerm_kubernetes_cluster.aks.node_resource_group
}

module "aks2_infra" {
  source  = "claranet/aks/azurerm//modules/infra"
  version = "3.2.0"
  
  # Use custom providers here if you have multiple clusters
  providers = {
    kubernetes = kubernetes.my_aks
    helm       = helm.my_aks
  }

  location            = module.rg.resource_group_location
  resource_group_name = module.rg.resource_group_name
  resource_group_id   = module.rg.resource_group_id

  aks_resource_group_id   = data.azurerm_resource_group.aks_nodes_rg.id
  aks_resource_group_name = data.azurerm_resource_group.aks_nodes_rg.name
}
```

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| azurerm | >= 2.51 |
| helm | >= 2.3.0 |
| kubernetes | >= 1.11.1 |

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
| aadpodidentity\_chart\_version | Azure Active Directory Pod Identity Chart version | `string` | `"2.0.0"` | no |
| aadpodidentity\_namespace | Kubernetes namespace in which to deploy AAD Pod Identity | `string` | `"system-aadpodid"` | no |
| aadpodidentity\_values | Settings for AAD Pod identity helm Chart <br /><br><pre>map(object({ <br /><br>  nmi.nodeSelector.agentpool  = string <br /><br>  mic.nodeSelector.agentpool  = string <br /><br>  azureIdentity.enabled       = bool <br /><br>  azureIdentity.type          = string <br /><br>  azureIdentity.resourceID    = string <br /><br>  azureIdentity.clientID      = string <br /><br>  nmi.micNamespace            = string <br /><br>}))<br /><br></pre> | `map(string)` | `{}` | no |
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
