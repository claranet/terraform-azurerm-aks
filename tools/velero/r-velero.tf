data "azurerm_subscription" "current" {
  count = var.enable_velero ? 1 : 0
}

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
    namespace = kubernetes_namespace.velero[0].metadata[0].name
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
  min_tls_version          = "TLS1_2"
  tags                     = local.velero_storage.tags

  lifecycle {
    ignore_changes = [network_rules]
  }
}

resource "azurerm_storage_account_network_rules" "velero" {
  count = var.enable_velero ? 1 : 0

  storage_account_id = azurerm_storage_account.velero[0].id

  default_action             = "Deny"
  bypass                     = local.velero_storage.bypass
  virtual_network_subnet_ids = concat(local.velero_storage.allowed_subnet_ids, [var.nodes_subnet_id])
  ip_rules                   = local.velero_storage.allowed_cidrs
}

resource "azurerm_storage_container" "velero" {
  count                 = var.enable_velero ? 1 : 0
  name                  = local.velero_storage.container_name
  storage_account_name  = azurerm_storage_account.velero[0].name
  container_access_type = "private"
}

resource "helm_release" "velero" {
  count = var.enable_velero ? 1 : 0
  depends_on = [
    kubernetes_secret.velero,
    kubernetes_namespace.velero,
    azurerm_storage_account.velero,
  azurerm_storage_container.velero]
  name       = "velero"
  chart      = "velero"
  repository = var.velero_chart_repository
  namespace  = kubernetes_namespace.velero[0].metadata[0].name
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
