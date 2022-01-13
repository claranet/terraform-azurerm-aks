<<<<<<< HEAD
# v4.5.0 - 2022-03-11

Breaking
  * GITHUB-3: `[module_variable_optional_attrs]` requires terraform `v0.14+`

Changed
  * [GITHUB-3](https://github.com/claranet/terraform-azurerm-aks/pull/3): Fix `velero_storage_settings` type, and make attributes optional
=======
# Unreleased
>>>>>>> AZ-615: Add an option to enable or disable default tags

Added
  * AZ-615: Add an option to enable or disable default tags

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
