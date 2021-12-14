terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.87.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "terraform_remote_state" "rg" {
  backend = "remote"

  config = {
    organization = "greensugarcake"
    workspaces = {
      name = "resource-groups"
    }
  }
}

data "terraform_remote_state" "aks" {
  backend = "remote"

  config = {
    organization = "greensugarcake"
    workspaces = {
      name = "private-aks-cluster"
    }
  }
}

# Bastion service
module "azure-bastion" {
  source  = "kumarvna/azure-bastion/azurerm"
  version = "1.1.0"

  # Resource Group, location, VNet and Subnet details
  resource_group_name  = data.terraform_remote_state.rg.outputs.resource_group_vnet_name
  virtual_network_name = data.terraform_remote_state.aks.outputs.hub_vnet_name

  # Azure bastion server requireemnts
  azure_bastion_service_name          = "${random_pet.prefix.id}-bastion"
  azure_bastion_subnet_address_prefix = ["10.10.2.0/26"]

  # Adding TAG's to your Azure resources (Required)
  tags = {
    env = "dev"
  }
}
