terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}