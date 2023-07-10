terraform {
  required_version = ">= 0.13.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.51"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  alias                  = "aks-module"
  host                   = module.aks.aks_kube_config[0].host
  client_certificate     = base64decode(module.aks.aks_kube_config[0].client_certificate)
  client_key             = base64decode(module.aks.aks_kube_config[0].client_key)
  cluster_ca_certificate = base64decode(module.aks.aks_kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  alias = "aks-module"
  kubernetes {
    host                   = module.aks.aks_kube_config[0].host
    client_certificate     = base64decode(module.aks.aks_kube_config[0].client_certificate)
    client_key             = base64decode(module.aks.aks_kube_config[0].client_key)
    cluster_ca_certificate = base64decode(module.aks.aks_kube_config[0].cluster_ca_certificate)
  }
}
