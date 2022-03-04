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

variable "velero_chart_repository" {
  description = "Helm chart repository URL"
  type        = string
  default     = "https://vmware-tanzu.github.io/helm-charts"
}

variable "velero_storage_settings" {
  description = <<EOVS
Settings for Storage account and blob container for Velero

map(object({
  name                     = string 
  resource_group_name      = string 
  location                 = string 
  account_tier             = string 
  account_replication_type = string 
  tags                     = map(any) 
  allowed_cidrs            = list(string) 
  allowed_subnet_ids       = list(string) 
  container_name           = string 
}))

EOVS
  type = object({
    name                     = string 
    resource_group_name      = string 
    location                 = string 
    account_tier             = string 
    account_replication_type = string 
    tags                     = map(any) 
    allowed_cidrs            = list(string) 
    allowed_subnet_ids       = list(string) 
    container_name           = string 
  })
  default     = null
}

variable "velero_values" {
  description = <<EOVV
Settings for Velero helm chart

map(object({ 
  configuration.backupStorageLocation.bucket                = string 
  configuration.backupStorageLocation.config.resourceGroup  = string 
  configuration.backupStorageLocation.config.storageAccount = string 
  configuration.backupStorageLocation.name                  = string 
  configuration.provider                                    = string 
  configuration.volumeSnapshotLocation.config.resourceGroup = string 
  configuration.volumeSnapshotLocation.name                 = string 
  credential.exstingSecret                                  = string 
  credentials.useSecret                                     = string 
  deployRestic                                              = string 
  env.AZURE_CREDENTIALS_FILE                                = string 
  metrics.enabled                                           = string 
  rbac.create                                               = string 
  schedules.daily.schedule                                  = string 
  schedules.daily.template.includedNamespaces               = string 
  schedules.daily.template.snapshotVolumes                  = string 
  schedules.daily.template.ttl                              = string 
  serviceAccount.server.create                              = string 
  snapshotsEnabled                                          = string 
  initContainers[0].name                                    = string 
  initContainers[0].image                                   = string 
  initContainers[0].volumeMounts[0].mountPath               = string 
  initContainers[0].volumeMounts[0].name                    = string 
  image.repository                                          = string 
  image.tag                                                 = string 
  image.pullPolicy                                          = string
  podAnnotations.aadpodidbinding                            = string
  podLabels.aadpodidbinding                                 = string

}))
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
  default     = "2.12.13"
}

variable "name_prefix" {
  description = "Prefix used in naming"
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
