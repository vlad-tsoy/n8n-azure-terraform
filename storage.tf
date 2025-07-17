# Azure Storage Account for persistent data and file storage
resource "azurerm_storage_account" "this" {
  name                          = module.naming.storage_account.name_unique
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  https_traffic_only_enabled    = true
  min_tls_version               = "TLS1_2"
  shared_access_key_enabled     = true
  public_network_access_enabled = true
  tags                          = var.tags

  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["DELETE", "GET", "HEAD", "MERGE", "POST", "OPTIONS", "PUT"]
      allowed_origins    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }
}

# File share for n8n configuration and persistent data
resource "azurerm_storage_share" "n8n_config" {
  name                 = "n8nconfig"
  storage_account_name = azurerm_storage_account.this.name
  quota                = 2
  access_tier          = "Hot"
}

# Container for storing n8n workflows and data
resource "azurerm_storage_container" "n8n_data" {
  name                  = "n8n-data"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}
