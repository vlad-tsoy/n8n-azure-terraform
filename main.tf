# Azure naming convention module for consistent resource naming
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
  suffix  = [var.environment_name]
  prefix  = [var.project_name]
}

# Data source to get current Azure client configuration
data "azurerm_client_config" "current" {}

# Resource group to contain all resources
resource "azurerm_resource_group" "this" {
  location = var.location
  name     = module.naming.resource_group.name_unique
  tags     = local.common_tags
}

# User-assigned managed identity for secure authentication between services
resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.common_tags
}
