resource "kubernetes_namespace" "velero" {
  count = var.enable_velero ? 1 : 0
  metadata {
    name = var.velero_namespace
    labels = {
      deployed-by = "Terraform"
    }
  }
}

resource "kubernetes_secret" "velero" {
  count = var.enable_velero ? 1 : 0
  metadata {
    name      = "cloud-credentials"
    namespace = kubernetes_namespace.velero.0.metadata.0.name
  }
  data = {
    cloud = local.velero_credentials
  }
}

resource "azurerm_storage_account" "velero" {
  count                    = var.enable_velero ? 1 : 0
  name                     = local.velero_storage.name
  resource_group_name      = local.velero_storage.resource_group_name
  location                 = local.velero_storage.location
  account_tier             = local.velero_storage.account_tier
  account_replication_type = local.velero_storage.account_replication_type
  account_kind             = "BlockBlobStorage"

  tags = merge(local.default_tags, local.velero_storage.tags)

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [var.nodes_subnet_id]
    ip_rules                   = local.velero_storage.allowed_cidrs
  }
}

resource "azurerm_storage_container" "velero" {
  count                 = var.enable_velero ? 1 : 0
  name                  = local.velero_storage.container_name
  storage_account_name  = azurerm_storage_account.velero.0.name
  container_access_type = "private"
}

resource "helm_release" "velero" {
  depends_on = [kubernetes_secret.velero, kubernetes_namespace.velero, azurerm_storage_account.velero,
  azurerm_storage_container.velero]
  name       = "velero"
  chart      = "velero"
  repository = data.helm_repository.vmware-tanzu.metadata.0.name
  namespace  = kubernetes_namespace.velero.0.metadata.0.name
  version    = var.velero_chart_version

  dynamic "set" {
    for_each = local.velero_values
    iterator = setting
    content {
      name  = setting.key
      value = setting.value
    }
  }
}