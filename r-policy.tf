# https://docs.microsoft.com/en-us/azure/aks/use-azure-ad-pod-identity#using-kubenet-network-plugin-with-azure-active-directory-pod-managed-identities
# https://azure.github.io/aad-pod-identity/docs/configure/aad_pod_identity_on_kubenet/
resource "azurerm_policy_definition" "aks_policy_kubenet_aadpodidentity_definition" {
  for_each = toset(var.aadpodidentity_kubenet_policy_enabled ? ["enabled"] : [])

  name         = "c26596ff-4d70-4e6a-9a30-c2506bd2f80c"
  policy_type  = "BuiltIn"
  mode         = "Microsoft.Kubernetes.Data"
  display_name = "Kubernetes cluster containers should only use allowed capabilities"

  parameters = <<PARAMETERS
    {
      "Namespace exclusions" : [  "kube-system",  "gatekeeper-system",  "azure-arc"]
      "Required drop capabilities": ["NET_RAW"]
    }
PARAMETERS

}

resource "azurerm_resource_policy_assignment" "aks_policy_kubenet_aadpodidentity_assignment" {
  for_each = toset(var.aadpodidentity_kubenet_policy_enabled ? ["enabled"] : [])

  name                 = "aks_policy_kubenet_aadpodidentity_assignment"
  resource_id          = azurerm_kubernetes_cluster.aks.id
  policy_definition_id = azurerm_policy_definition.aks_policy_kubenet_aadpodidentity_definition.id
  enforce              = true
}
