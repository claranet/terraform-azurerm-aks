locals {
  credentials = <<EOF
AZURE_SUBSCRIPTION_ID = ${data.azurerm_subscription.current.0.subscription_id}
AZURE_RESOURCE_GROUP = ${var.aks_nodes_resource_group_name}
AZURE_CLOUD_NAME = AzurePublicCloud
EOF

  name_prefix = var.name_prefix != "" ? replace(var.name_prefix, "/[a-z0-9]/", "$0-") : ""

  storage_defaults_settings = {
    name                     = lower(substr(replace("velero${local.name_prefix}${var.stack}${var.client_name}${var.location_short}${var.environment}", "/[._\\- ]/", ""), 0, 24))
    resource_group_name      = var.resource_group_name
    location                 = var.location
    account_tier             = "Premium"
    account_replication_type = "LRS"
    tags                     = {}
    allowed_cidrs            = []
    container_name           = "velero"
  }


  velero_default_values = {
    "configuration.backupStorageLocation.bucket"                = var.enable_velero ? azurerm_storage_container.velero.0.name : ""
    "configuration.backupStorageLocation.config.resourceGroup"  = var.enable_velero ? azurerm_storage_account.velero.0.resource_group_name : ""
    "configuration.backupStorageLocation.config.storageAccount" = var.enable_velero ? azurerm_storage_account.velero.0.name : ""
    "configuration.backupStorageLocation.name"                  = "azure"
    "configuration.provider"                                    = "azure"
    "configuration.volumeSnapshotLocation.config.resourceGroup" = var.enable_velero ? var.aks_nodes_resource_group_name : ""
    "configuration.volumeSnapshotLocation.name"                 = "azure"
    "credentials.existingSecret"                                = var.enable_velero ? kubernetes_secret.velero.0.metadata.0.name : ""
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
    "initContainers[0].image"                                   = "velero/velero-plugin-for-microsoft-azure:master"
    "initContainers[0].volumeMounts[0].mountPath"               = "/target"
    "initContainers[0].volumeMounts[0].name"                    = "plugins"
    "image.repository"                                          = "velero/velero"
    "image.tag"                                                 = "master"
    "image.pullPolicy"                                          = "IfNotPresent"
    "podAnnotations.aadpodidbinding"                            = local.velero_identity_name
  }


  velero_credentials = local.credentials
  velero_storage     = merge(local.storage_defaults_settings, var.velero_storage_settings)
  velero_values      = merge(local.velero_default_values, var.velero_values)

  velero_identity_name = "velero"
}
