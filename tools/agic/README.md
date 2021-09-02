<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| azurerm | >= 2.10 |
| helm | >=2.3.0 |
| kubernetes | >= 1.11.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| diagnostic\_settings\_appgw | claranet/diagnostic-settings/azurerm | 4.0.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.app_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_public_ip.ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_role_assignment.agic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.agic_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [helm_release.agic](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.agic](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| agic\_chart\_repository | Helm chart repository URL | `string` | `"https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"` | no |
| agic\_chart\_version | Version of the Helm chart | `string` | `"1.2.0"` | no |
| agic\_helm\_version | [DEPRECATED] Version of Helm chart to deploy | `string` | `null` | no |
| aks\_aad\_pod\_identity\_client\_id | AAD Identity client\_id used by AKS | `string` | n/a | yes |
| aks\_aad\_pod\_identity\_id | AAD Identity id used by AKS | `string` | n/a | yes |
| aks\_aad\_pod\_identity\_principal\_id | AAD Identity principal\_id used by AKS | `string` | n/a | yes |
| app\_gateway\_subnet\_id | ID of the subnet to use with the application gateway | `string` | n/a | yes |
| app\_gateway\_tags | Tags to apply on the Application gateway | `map(string)` | n/a | yes |
| appgw\_backend\_http\_settings | List of maps including backend http settings configurations | `any` | <pre>[<br>  {<br>    "fake": "fake"<br>  }<br>]</pre> | no |
| appgw\_backend\_pools | List of maps including backend pool configurations | `any` | <pre>[<br>  {<br>    "fake": "fake"<br>  }<br>]</pre> | no |
| appgw\_http\_listeners | List of maps including http listeners configurations | `list(map(string))` | <pre>[<br>  {<br>    "fake": "fake"<br>  }<br>]</pre> | no |
| appgw\_ingress\_values | Application Gateway Ingress Controller settings | `map(string)` | `{}` | no |
| appgw\_private\_ip | Private IP for Application Gateway. Used when variable `private_ingress` is set to `true`. | `string` | `null` | no |
| appgw\_probes | List of maps including request probes configurations | `any` | <pre>[<br>  {<br>    "fake": "fake"<br>  }<br>]</pre> | no |
| appgw\_redirect\_configuration | List of maps including redirect configurations | `list(map(string))` | `[]` | no |
| appgw\_rewrite\_rule\_set | Application gateway's rewrite rules | `any` | `[]` | no |
| appgw\_routings | List of maps including request routing rules configurations | `list(map(string))` | <pre>[<br>  {<br>    "fake": "fake"<br>  }<br>]</pre> | no |
| appgw\_url\_path\_map | List of maps including url path map configurations | `any` | `[]` | no |
| authentication\_certificate\_configs | List of maps including authentication certificate configurations | `list(map(string))` | `[]` | no |
| client\_name | Client name/account used in naming | `string` | n/a | yes |
| diagnostic\_settings\_custom\_name | Custom name for Azure Diagnostics for AKS. | `string` | `"default"` | no |
| diagnostic\_settings\_event\_hub\_name | Event hub name used with diagnostics settings | `string` | `null` | no |
| diagnostic\_settings\_log\_categories | List of log categories | `list(string)` | `null` | no |
| diagnostic\_settings\_logs\_destination\_ids | List of destination resources IDs for logs diagnostic destination. Can be Storage Account, Log Analytics Workspace and Event Hub. No more than one of each can be set. | `list(string)` | `[]` | no |
| diagnostic\_settings\_metric\_categories | List of metric categories | `list(string)` | `null` | no |
| diagnostic\_settings\_retention\_days | The number of days to keep diagnostic logs. | `number` | `30` | no |
| disabled\_rule\_group\_settings | Appgw WAF rules group to disable. | <pre>list(object({<br>    rule_group_name = string<br>    rules           = list(string)<br>  }))</pre> | `[]` | no |
| enable\_agic | Enable application gateway ingress controller | `bool` | `true` | no |
| enabled\_waf | Enable WAF or not | `bool` | `false` | no |
| environment | Project's environment | `string` | n/a | yes |
| file\_upload\_limit\_mb | WAF configuration of the file upload limit in MB | `number` | `100` | no |
| firewall\_mode | Appgw WAF mode | `string` | `"Detection"` | no |
| frontend\_ip\_configuration\_name | Name of the appgw frontend ip configuration | `string` | n/a | yes |
| frontend\_port\_settings | Appgw frontent port settings | `list(map(string))` | <pre>[<br>  {<br>    "fake": "fake"<br>  }<br>]</pre> | no |
| frontend\_priv\_ip\_configuration\_name | Name of the appgw frontend private ip configuration | `string` | `null` | no |
| gateway\_identity\_id | Id of the application gateway MSI | `string` | `null` | no |
| gateway\_ip\_configuration\_name | Name of the appgw gateway ip configuration | `string` | n/a | yes |
| ip\_allocation\_method | Allocation method of the IP address | `string` | `"Static"` | no |
| ip\_name | Name of the applications gateway's public ip address | `string` | n/a | yes |
| ip\_sku | SKU of the public ip address | `string` | `"Standard"` | no |
| ip\_tags | Specific tags for the public ip address | `map(string)` | n/a | yes |
| location | Location of application gateway | `string` | n/a | yes |
| location\_short | Short name of Azure regions to use | `string` | n/a | yes |
| max\_request\_body\_size\_kb | WAF configuration of the max request body size in KB | `number` | `128` | no |
| name | Name of the application gateway | `string` | n/a | yes |
| name\_prefix | prefix used in naming | `string` | `""` | no |
| policy\_name | Name of the SSLPolicy to use with Appgw | `string` | `"AppGwSslPolicy20170401S"` | no |
| private\_ingress | Private ingress boolean variable. When `true`, the default http listener will listen on private IP instead of the public IP. | `bool` | `false` | no |
| request\_body\_check | WAF should check the request body | `bool` | `true` | no |
| resource\_group\_name | Name of the resource group in which to deploy the application gateway | `string` | n/a | yes |
| rule\_set\_type | WAF rules set type | `string` | `"OWASP"` | no |
| rule\_set\_version | WAF rules set version | `string` | `"3.0"` | no |
| sku\_capacity | Application gateway's SKU capacity | `string` | `2` | no |
| sku\_name | Application gateway's SKU name | `string` | `"Standard_v2"` | no |
| sku\_tier | Application gateway's SKU tier | `string` | `"Standard_v2"` | no |
| ssl\_certificates\_configs | List of maps including ssl certificates configurations | `list(map(string))` | `[]` | no |
| stack | Project's stack | `string` | n/a | yes |
| trusted\_root\_certificate\_configs | Trusted root certificate configurations | `list(map(string))` | `[]` | no |
| waf\_exclusion\_settings | Appgw WAF exclusion settings | `list(map(string))` | `[]` | no |
| zones | Application gateway's Zones to use | `list(string)` | <pre>[<br>  "1",<br>  "2",<br>  "3"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| application\_gateway\_id | Application gateway Id |
| application\_gateway\_name | Application gateway name |
| namespace | Namespace used for AGIC |
| public\_ip\_id | Application gateway public ip Id |
| public\_ip\_name | Application gateway public ip name |
<!-- END_TF_DOCS -->