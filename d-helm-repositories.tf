data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

data "helm_repository" "vmware-tanzu" {
  name = "vmware-tanzu"
  url  = "https://vmware-tanzu.github.io/helm-charts"
}

data "helm_repository" "add_pod_identity" {
  name = "aad-pod-identity"
  url  = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
}