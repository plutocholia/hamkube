terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.12.1"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "/root/.kube/config"
  }
}

provider "kubectl" {
  config_path = "/root/.kube/config"
}