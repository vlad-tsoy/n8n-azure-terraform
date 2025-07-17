# Random password for PostgreSQL admin user
resource "random_password" "postgres_admin_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

# Azure PostgreSQL Flexible Server for n8n database backend
resource "azurerm_postgresql_flexible_server" "this" {
  location                      = azurerm_resource_group.this.location
  name                          = module.naming.postgresql_server.name_unique
  resource_group_name           = azurerm_resource_group.this.name
  administrator_login           = "psqladmin"
  administrator_password        = random_password.postgres_admin_password.result
  backup_retention_days         = local.current_config.postgres_backup_retention
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = true
  sku_name                      = local.current_config.postgres_sku
  storage_mb                    = local.current_config.postgres_storage_mb
  storage_tier                  = "P10"
  version                       = "16"
  zone                          = "1"
  tags                          = local.common_tags

  # High availability is disabled for cost optimization (no block needed)

  # Maintenance window configuration
  maintenance_window {
    day_of_week  = 0
    start_hour   = 8
    start_minute = 0
  }
}

# PostgreSQL database for n8n
resource "azurerm_postgresql_flexible_server_database" "n8n" {
  name      = "n8n"
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

# Firewall rule to allow Azure services access
resource "azurerm_postgresql_flexible_server_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
