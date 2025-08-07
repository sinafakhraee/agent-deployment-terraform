terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = ">=2.5.0"
    }
  }
}

provider "azapi" {}  # only here so Terraform is happy; we won’t use it below
