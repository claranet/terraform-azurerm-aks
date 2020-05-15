variable "resource_group_name" {
  description = "Name of the resource group for Velero's Storage Account"
  type        = string
}

variable "aks_nodes_resource_group_name" {
  description = "Name of AKS nodes resource group"
  type        = string
}

variable "nodes_subnet_id" {
  description = "Id of the subnet used for nodes"
  type        = string
}
variable "enable_velero" {
  description = "Enable velero on AKS cluster"
  type        = bool
  default     = true
}

variable "velero_storage_settings" {
  description = <<EOVS
Settings for Storage account and blob container for Velero <br />
<pre>
map(object({ <br />
  name                     = string <br />
  resource_group_name      = string <br />
  location                 = string <br />
  account_tier             = string <br />
  account_replication_type = string <br />
  tags                     = map(any) <br />
  allowed_cirds            = list(string) <br />
  container_name           = string <br />
}))<br />
</pre>
EOVS
  type        = map(any)
  default     = {}
}

variable "velero_values" {
  description = <<EOVV
Settings for Velero helm chart

<pre>
map(object({ <br />
  configuration.backupStorageLocation.bucket                = string <br />
  configuration.backupStorageLocation.config.resourceGroup  = string <br />
  configuration.backupStorageLocation.config.storageAccount = string <br />
  configuration.backupStorageLocation.name                  = string <br />
  configuration.provider                                    = string <br />
  configuration.volumeSnapshotLocation.config.resourceGroup = string <br />
  configuration.volumeSnapshotLocation.name                 = string <br />
  credential.exstingSecret                                  = string <br />
  credentials.useSecret                                     = string <br />
  deployRestic                                              = string <br />
  env.AZURE_CREDENTIALS_FILE                                = string <br />
  metrics.enabled                                           = string <br />
  rbac.create                                               = string <br />
  schedules.daily.schedule                                  = string <br />
  schedules.daily.template.includedNamespaces               = string <br />
  schedules.daily.template.snapshotVolumes                  = string <br />
  schedules.daily.template.ttl                              = string <br />
  serviceAccount.server.create                              = string <br />
  snapshotsEnabled                                          = string <br />
  initContainers[0].name                                    = string <br />
  initContainers[0].image                                   = string <br />
  initContainers[0].volumeMounts[0].mountPath               = string <br />
  initContainers[0].volumeMounts[0].name                    = string <br />
  image.repository                                          = string <br />
  image.tag                                                 = string <br />
  image.pullPolicy                                          = string <br />

}))<br />
</pre>
EOVV
  type        = map(string)
  default     = {}
}

variable "velero_namespace" {
  description = "Kubernetes namespace in which to deploy Velero"
  type        = string
  default     = "system-velero"
}

variable "velero_chart_version" {
  description = "Velero helm chart version to use"
  type        = string
  default     = "2.7.3"
}

variable "service_principal" {
  description = "Service principal used by AKS to interract with Azure API"
  type        = object({
    client_id     = string,
    client_secret = string,
    object_id     = string
  })
}

variable "name_prefix" {
  description = "prefix used in naming"
  type        = string
  default     = ""
}

variable "location" {
  description = "Azure region to use"
  type        = string
}

variable "location_short" {
  description = "Short name of Azure regions to use"
  type        = string
}

variable "client_name" {
  description = "Client name/account used in naming"
  type        = string
}

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "stack" {
  description = "Project stack name"
  type        = string
}