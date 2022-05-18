terraform {
  required_version = ">= 1.1"
  required_providers {
    # tflint-ignore: terraform_unused_required_providers
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.5.1"
    }
    # tflint-ignore: terraform_unused_required_providers
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }
  }
}
