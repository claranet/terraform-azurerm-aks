terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm    = "< 2.0"
    helm       = ">= 1.0.0"
    kubernetes = "~> 1.11.1"
  }
}