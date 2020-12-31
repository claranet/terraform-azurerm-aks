# v3.3.0/v4.0.0 - unreleased

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

