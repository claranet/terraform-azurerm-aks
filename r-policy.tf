# https://docs.microsoft.com/en-us/azure/aks/use-azure-ad-pod-identity#using-kubenet-network-plugin-with-azure-active-directory-pod-managed-identities
# https://azure.github.io/aad-pod-identity/docs/configure/aad_pod_identity_on_kubenet/
data "azurerm_policy_definition" "aks_policy_kubenet_aadpodidentity_definition" {
  for_each = toset(var.aadpodidentity_kubenet_policy_enabled ? ["enabled"] : [])

  name = "c26596ff-4d70-4e6a-9a30-c2506bd2f80c"
}

# https://github.com/hashicorp/terraform-provider-azurerm/issues/8527
resource "azurerm_resource_policy_assignment" "aks_policy_kubenet_aadpodidentity_assignment" {
  for_each = toset(var.aadpodidentity_kubenet_policy_enabled ? ["enabled"] : [])

  name                 = "aks_policy_kubenet_aadpodidentity_assignment"
  resource_id          = azurerm_kubernetes_cluster.aks.id
  policy_definition_id = data.azurerm_policy_definition.aks_policy_kubenet_aadpodidentity_definition["enabled"].id
  enforce              = true

  parameters = <<PARAMETERS
{
  "requiredDropCapabilities": {
    "value": ["NET_RAW"]
  }
}
PARAMETERS
}
