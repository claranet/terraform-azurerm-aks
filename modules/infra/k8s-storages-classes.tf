resource "kubernetes_storage_class" "managed_standard_retain" {
  storage_provisioner    = "kubernetes.io/azure-disk"
  allow_volume_expansion = true
  metadata {
    name = "standard-hdd-retain"
  }
  reclaim_policy = "Retain"
  parameters = {
    storageaccounttype = "Standard_LRS"
    kind               = "Managed"
  }
}

resource "kubernetes_storage_class" "managed_standard_delete" {
  storage_provisioner    = "kubernetes.io/azure-disk"
  allow_volume_expansion = true
  metadata {
    name = "standard-hdd-delete"
  }
  reclaim_policy = "Delete"
  parameters = {
    storageaccounttype = "Standard_LRS"
    kind               = "Managed"
  }
}

resource "kubernetes_storage_class" "managed_premium_retain" {
  storage_provisioner    = "kubernetes.io/azure-disk"
  allow_volume_expansion = true
  metadata {
    name = "managed-premium-retain"
  }
  reclaim_policy = "Retain"
  parameters = {
    storageaccounttype = "Premium_LRS"
    kind               = "Managed"
  }
}

resource "kubernetes_storage_class" "managed_premium_delete" {
  storage_provisioner = "kubernetes.io/azure-disk"
  metadata {
    name = "managed-premium-delete"
  }
  reclaim_policy = "Delete"
  parameters = {
    storageaccounttype = "Premium_LRS"
    kind               = "Managed"
  }
}
