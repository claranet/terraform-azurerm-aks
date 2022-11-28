locals {
  credentials = <<EOF
AZURE_SUBSCRIPTION_ID = ${try(data.azurerm_subscription.current[0].subscription_id, "")}
AZURE_RESOURCE_GROUP = ${var.aks_nodes_resource_group_name}
AZURE_CLOUD_NAME = AzurePublicCloud
EOF

  velero_identity_name = coalesce(var.velero_identity_custom_name, "velero")

  name_prefix = var.name_prefix != "" ? replace(var.name_prefix, "/[a-z0-9]/", "$0-") : ""

  storage_defaults_settings = {
    name                     = lower(substr(replace("velero${local.name_prefix}${var.stack}${var.client_name}${var.location_short}${var.environment}", "/[._\\- ]/", ""), 0, 24))
    resource_group_name      = var.resource_group_name
    location                 = var.location
    account_tier             = "Premium"
    account_replication_type = "LRS"
    tags                     = {}
    allowed_cidrs            = []
    allowed_subnet_ids       = []
    bypass                   = ["Logging", "Metrics", "AzureServices"]
    container_name           = "velero"
  }


  velero_default_values = {
    "configuration.backupStorageLocation.bucket"                = try(azurerm_storage_container.velero[0].name, "")
    "configuration.backupStorageLocation.config.resourceGroup"  = try(azurerm_storage_account.velero[0].resource_group_name, "")
    "configuration.backupStorageLocation.config.storageAccount" = try(azurerm_storage_account.velero[0].name, "")
    "configuration.backupStorageLocation.name"                  = "default"
    "configuration.provider"                                    = "azure"
    "configuration.volumeSnapshotLocation.config.resourceGroup" = try(var.aks_nodes_resource_group_name, "")
    "configuration.volumeSnapshotLocation.name"                 = "default"
    "credentials.existingSecret"                                = try(kubernetes_secret.velero[0].metadata[0].name, "")
    "credentials.useSecret"                                     = "true"
    "deployRestic"                                              = "false"
    "env.AZURE_CREDENTIALS_FILE"                                = "/credentials"
    "metrics.enabled"                                           = "true"
    "rbac.create"                                               = "true"
    "schedules.daily.schedule"                                  = "0 23 * * *"
    "schedules.daily.template.includedNamespaces"               = "{*}"
    "schedules.daily.template.snapshotVolumes"                  = "true"
    "schedules.daily.template.ttl"                              = "240h"
    "serviceAccount.server.create"                              = "true"
    "snapshotsEnabled"                                          = "true"
    "initContainers[0].name"                                    = "velero-plugin-for-azure"
    "initContainers[0].image"                                   = "velero/velero-plugin-for-microsoft-azure:v1.1.1"
    "initContainers[0].volumeMounts[0].mountPath"               = "/target"
    "initContainers[0].volumeMounts[0].name"                    = "plugins"
    "image.repository"                                          = "velero/velero"
    "image.pullPolicy"                                          = "IfNotPresent"
    "podAnnotations.aadpodidbinding"                            = local.velero_identity_name
    "podLabels.aadpodidbinding"                                 = local.velero_identity_name
  }


  velero_credentials = local.credentials
  velero_storage     = var.enable_velero ? merge(local.storage_defaults_settings, { for k, v in var.velero_storage_settings : k => v if v != null }) : null
  velero_values      = var.enable_velero ? merge(local.velero_default_values, var.velero_values) : null
}
