provider "kubernetes" {
  config_path    = "~/.kube/config" 
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.9.0"
    }
  }
}