output "n8n_url" {
  description = "The URL to access the n8n application"
  value       = "https://${azurerm_container_app.n8n.latest_revision_fqdn}"
}

output "qdrant_url" {
  description = "The URL to access the Qdrant vector database"
  value       = "https://${azurerm_container_app.qdrant.latest_revision_fqdn}"
}

output "key_vault_name" {
  description = "The name of the Azure Key Vault"
  value       = azurerm_key_vault.this.name
}

output "key_vault_uri" {
  description = "The URI of the Azure Key Vault"
  value       = azurerm_key_vault.this.vault_uri
}

output "postgresql_server_name" {
  description = "The name of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.this.name
}

output "postgresql_server_fqdn" {
  description = "The FQDN of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "managed_identity_client_id" {
  description = "The client ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.this.client_id
}

output "container_app_environment_name" {
  description = "The name of the Container Apps environment"
  value       = azurerm_container_app_environment.this.name
}
