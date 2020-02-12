locals {
  credentials = <<EOF
AZURE_SUBSCRIPTION_ID = ${data.azurerm_subscription.current.subscription_id}
AZURE_TENANT_ID = ${data.azurerm_subscription.current.tenant_id}
AZURE_CLIENT_ID = ${var.service_principal.client_id}
AZURE_CLIENT_SECRET = ${var.service_principal.client_secret}
AZURE_RESOURCE_GROUP = ${azurerm_kubernetes_cluster.aks.node_resource_group}
AZURE_CLOUD_NAME = AzurePublicCloud
EOF

  storage_defaults_settings = {
    name                     = lower(substr(replace("velero${var.stack}${var.client_name}${var.location_short}${var.environment}", "/[._\\- ]/", ""), 0, 24))
    resource_group_name      = var.resource_group_name
    location                 = var.location
    account_tier             = "Premium"
    account_replication_type = "LRS"
    tags                     = {}
    allowed_cidrs            = []
    container_name           = "velero"
  }

  velero_default_values = {
    version                                                     = "2.7.3"
    "configuration.backupStorageLocation.bucket"                = azurerm_storage_container.velero.0.name
    "configuration.backupStorageLocation.config.resourceGroup"  = azurerm_storage_account.velero.0.resource_group_name
    "configuration.backupStorageLocation.config.storageAccount" = azurerm_storage_account.velero.0.name
    "configuration.backupStorageLocation.name"                  = "azure"
    "configuration.provider"                                    = "azure"
    "configuration.volumeSnapshotLocation.config.resourceGroup" = azurerm_kubernetes_cluster.aks.node_resource_group
    "configuration.volumeSnapshotLocation.name"                 = "azure"
    "credentials.existingSecret"                                = kubernetes_secret.velero.0.metadata.0.name
    "credentials.useSecret"                                     = "true"
    "deployRestic"                                              = "false"
    "env.AZURE_CREDENTIALS_FILE"                                = "/credentials"
    "metrics.enabled"                                           = "false"
    "rbac.create"                                               = "true"
    "schedules.daily.schedule"                                  = "0 23 * * *"
    "schedules.daily.template.includedNamespaces"               = "{'*'}"
    "schedules.daily.template.snapshotVolumes"                  = "true"
    "schedules.daily.template.ttl"                              = "240h"
    "serviceAccount.server.create"                              = "true"
    "snapshotsEnabled"                                          = "true"
    "initContainers[0].name"                                    = "velero-plugin-for-azure"
    "initContainers[0].image"                                   = "velero/velero-plugin-for-microsoft-azure:v1.0.0"
    "initContainers[0].volumeMounts[0].mountPath"               = "/target"
    "initContainers[0].volumeMounts[0].name"                    = "plugins"
    "image.repository"                                          = "velero/velero"
    "image.tag"                                                 = "v1.2.0"
    "image.pullPolicy"                                          = "IfNotPresent"
  }


  velero_credentials = local.credentials
  velero_storage     = merge(local.storage_defaults_settings, var.velero_storage_settings)
  velero_values      = merge(local.velero_default_values, var.velero_settings)
}
