terraform {
  required_version = "~> 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.9.0"
    }
  }
}

provider "azurerm" {
  features {

    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = true
    }

  }
}

provider "azurerm" {
  features {}
  alias           = "secondary"
  subscription_id = "fac4f989-bd54-4dcd-91c1-c5da1f3ccf86"
}

