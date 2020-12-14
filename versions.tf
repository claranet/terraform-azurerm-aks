terraform {
  required_version = "> 0.12.26"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "1.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.11.1"
    }
  }
}
