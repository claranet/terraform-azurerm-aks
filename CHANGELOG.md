# v7.9.0 - 2023-08-18

Added
  * [GH-13](https://github.com/claranet/terraform-azurerm-aks/pull/13): Add `scale_down_mode` on `node_pool` and `default_node_pool` config

# v7.8.0 - 2023-07-21

Added
  * AZ-1120: Add workload_runtime on node_pool config

# v7.7.1 - 2023-07-13

Fixed
  * AZ-1113: Update sub-modules READMEs (according to their example)

# v7.7.0 - 2023-04-28

Added
  * [GH-12](https://github.com/claranet/terraform-azurerm-aks/pull/12): Expose `oidc_issuer_enabled` parameter, output `oidc_issuer_url`

# v7.6.1 - 2023-04-14

Fixed
  * AZ-1059: Fix `key_vault_secrets_provider_identity` output

# v7.6.0 - 2023-03-31

Added
  * AZ-1036: Add `key_vault_secrets_provider` parameter

Fixed
  * AZ-1035: Fix permanent drift when `enable_auto_scaling` is set to `false`

# v7.5.0 - 2023-03-03

Added
  * AZ-1000: Add an option to enable or disable UAI Private DNS Zone role assignment
  * AZ-1001: Add default `no_proxy_url_list` and some information about the parameter
  * [GH-9](https://github.com/claranet/terraform-azurerm-aks/pull/9): Add more configuration options to cluster's node pools
  * AZ-1011: Add AKS Kubelet identity role assignment

Fixed
  * [GH-10](https://github.com/claranet/terraform-azurerm-aks/pull/10): Auto scaler profile fixes
  * AZ-1011: Fix identities outputs
  * [GH-11](https://github.com/claranet/terraform-azurerm-aks/pull/11): Fix node_count error when autoscaler is enabled

# v7.4.0 - 2023-02-10

Changed
  * [GH-7](https://github.com/claranet/terraform-azurerm-aks/pull/7): Fix issues with output and local variables when agic is disabled

# v7.3.0 - 2023-02-08

Added
  * [GH-8](https://github.com/claranet/terraform-azurerm-aks/pull/8): Add HTTP Application Routing option

Changed
  * AZ-992: Prevent the gathering of `kube-audit` and `kube-audit-admin` logs by default.

Fixed
  * AZ-992: Fix examples

# v7.2.0 - 2022-12-02

Added
  * AZ-908/AZ-515: Implement Azure CAF naming (using Microsoft provider)
  * AZ-914: Add AKS `http_proxy` feature

Changed
  * AZ-908: Bump `diagnostic-settings`, uses standard variables names
  * AZ-908: AzureRM provider updated to `v3.22+`
  * AZ-901: Code security check/hardening - change variable default values
  * AZ-914: Update azurerm in provider version to avoid https://github.com/Azure/AKS/issues/3044

Fixed
  * AZ-914: Update kured image tag and repository
  * AZ-914: Fix agic default values

# v7.1.1 - 2022-11-04

Fixed
  * AZ-883 Fix syntax to pass checks with new tflint version

# v7.1.0 - 2022-10-14

Added
  * [GH-6](https://github.com/claranet/terraform-azurerm-aks/pull/6): Allow to choose which expander to use in autoscaler profile
  * AZ-867: Allow to use existing Application Gateway as AGIC

# v7.0.0 - 2022-09-30

Breaking
  * AZ-840: Update to Terraform `v1.3`

Fixed
  * AZ-856: Fix kured_chart_repository variable

# v6.0.0 - 2022-08-05

Breaking
  * AZ-717: Remove providers configurations from module/sub-modules to be compatible with terraform 1.2

Added
  * AZ-615: Add an option to enable or disable default tags
  * AZ-605: Add Kubenet implementation
  * AZ-605: Allow aadpodidentity and Velero MSI custom naming
  * AZ-605: Allow to configure tags on MSIs and node pools
  * AZ-605: Allow to configure permissions on route table when using kubenet and UDR egress
  * AZ-605: Add  `Kubernetes cluster containers should only use allowed capabilities` policy when using Kubenet to avoid security issue

Fixed
  * AZ-605: Fix Velero_storage_settings variable
  * AZ-605: Fix aks_pod_cidr variable
  * AZ-605: Fix Aks Private DNS zone configuration

Changed
  * AZ-605: Change azurerm provider minimal version
  * AZ-717: Bump `aad-pod-identity` helm chart to `4.1.9`
  * AZ-717: Bump `cert-manager` helm chart to `1.8.0`
  * AZ-717: Bump `velero` helm chart to `2.29.5`
  * AZ-717: Bump `agic` helm chart to `1.5.2`
  * AZ-717: Bump `helm` provider min version to `2.5.1`
  * AZ-717: Bump `kubernetes` provider min version to `2.11.0`
  * AZ-717: Add mandatory priority on AGIC Application gateway `request_routing_rule`
  * AZ-717: Add `installCRDs` value to true in `cert-manager` deployment

# v4.5.0 - 2022-03-11

Breaking
  * GITHUB-3: `[module_variable_optional_attrs]` requires terraform `v0.14+`

Changed
  * [GITHUB-3](https://github.com/claranet/terraform-azurerm-aks/pull/3): Fix `velero_storage_settings` type, and make attributes optional


# v4.4.0 - 2021-12-28

Changed
  * AZ-632: Increased default disk size to 128GB for Linux nodes and 256GB for Windows nodes to comply with Microsoft recommendations
  * AZ-637: Add os disk type option to enable the Ephemeral disks

# v4.3.2 - 2021-11-15

Fixed
  * AZ-589: Avoid plan drift when specifying Diagnostic Settings categories

# v4.3.1 - 2021-10-19

Fixed
  * AZ-587: Fix non-working `max_pods` parameter on node pools

# v4.3.0 - 2021-10-18

Breaking
  * AZ-485: Add AKS Private Cluster Feature

Added
  * AZ-485: Add Msi Identity for Applicationg Gateway with Agic
  * AZ-485: Add Private DNS Zone support
  * AZ-485: Add Azure Container Registry Permissions
  * AZ-485: Allow to configure AKS SKU

Changed
  * AZ-532: Revamp README with latest `terraform-docs` tool
  * AZ-530: Cleanup module, fix linter errors

# v4.2.0 - 2021-06-03

Breaking
  * AZ-483: Remove deprecated `load_config_file` parameter from kubernetes provider declaration according to latest provider release (2.0)
  * AZ-483: Update minimal version required for kubernetes provider to `>= 2.1.0`

Added
  * AZ-484: Update CI to cover Terraform 0.15

# v4.1.0 - 2020-12-31

Breaking
  * AZ-404: Rework log management by using diagnostic-settings module

# v3.3.0/v4.0.0 - 2020-12-30

Changed
  * AZ-273: Update README and CI, module compatible Terraform 0.13+ (now requires Terraform 0.12.26 minimum version)

Added
  * AZ-335: Force lower domain name label for the public IP of the agic
  * AZ-377: Core tools as documented sub-module
  * AZ-359: Add `outbound_type` variable to be able to use user defined routing
  * AZ-359: Add ability to have a private ingress with `private_ingress` variable and `appgw_private_ip`

Updated
  * AZ-381: Harmonize variables and add outputs
  * AZ-380: AKS module: pin velero azure image
  * AZ-382: Update of Kured chart version

Fixed
  * AZ-379: Fix kured chart repository
  * AZ-357: Fix issue with AKS user role assignment
  * AZ-357: Fix velero parameter
  * AZ-357: Fix versions in submodules

# v3.2.0 - 2020-10-20

Fixed
  * AZ-251: Update velero helm chart to 2.12.13
  * AZ-251: Align velero 1.4.0 to main branch of velero-plugin-for-microsoft-azure to work with managed identities
  * AZ-251: Remove hack for velero pod labels since it's now supported in chart v2.12.13
  * AZ-252: Update AGIC helm chart to 1.2.0 final
  * AZ-254: Application gateway creation fail with default parameters

Added
  * AZ-253: Update to last stable version of AKS by default

# v3.1.0 - 2020-07-31

Breaking
  * AZ-229: Replace deprecated Services Principals by Managed Identity

Fixed
  * AZ-237: `appgw_subnet_id` variable must not be mandatory

# v3.0.0 - 2020-07-03

Added
  * AZ-123: First version of the AKS module
