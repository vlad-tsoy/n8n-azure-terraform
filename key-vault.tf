# Azure Key Vault for secure secret management
resource "azurerm_key_vault" "this" {
  name                = module.naming.key_vault.name_unique
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  public_network_access_enabled = true

  tags = var.tags

  # Network ACLs to allow Azure services
  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }
}

# Key Vault access policy for the current user/service principal
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Purge",
    "Recover"
  ]
}

# Key Vault access policy for the managed identity
resource "azurerm_key_vault_access_policy" "managed_identity" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.this.principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

# Store PostgreSQL admin password in Key Vault
resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-admin-password"
  value        = random_password.postgres_admin_password.result
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [azurerm_key_vault_access_policy.current_user]
}

# Azure OpenAI secret removed - no longer needed
