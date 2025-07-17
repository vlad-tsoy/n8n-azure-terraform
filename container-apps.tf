# Container Apps Environment for hosting containers
resource "azurerm_container_app_environment" "this" {
  name                = module.naming.container_app_environment.name_unique
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

# Storage configuration for Container Apps Environment
resource "azurerm_container_app_environment_storage" "n8n_config" {
  name                         = "n8nconfig"
  container_app_environment_id = azurerm_container_app_environment.this.id
  account_name                 = azurerm_storage_account.this.name
  share_name                   = azurerm_storage_share.n8n_config.name
  access_key                   = azurerm_storage_account.this.primary_access_key
  access_mode                  = "ReadWrite"
}

# n8n Container App
resource "azurerm_container_app" "n8n" {
  name                         = "${module.naming.container_app.name_unique}-n8n"
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = azurerm_resource_group.this.name
  revision_mode                = "Single"
  tags                         = var.tags

  # Managed identity configuration
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  # Container configuration
  template {
    min_replicas = local.current_config.container_min_replicas
    max_replicas = local.current_config.container_max_replicas

    container {
      name   = "n8n"
      image  = "docker.io/n8nio/n8n:latest"
      cpu    = 0.5
      memory = "1.0Gi"

      # Environment variables for n8n configuration
      env {
        name  = "DB_TYPE"
        value = "postgresdb"
      }

      env {
        name  = "DB_POSTGRESDB_HOST"
        value = azurerm_postgresql_flexible_server.this.fqdn
      }

      env {
        name  = "DB_POSTGRESDB_PORT"
        value = "5432"
      }

      env {
        name  = "DB_POSTGRESDB_DATABASE"
        value = azurerm_postgresql_flexible_server_database.n8n.name
      }

      env {
        name  = "DB_POSTGRESDB_USER"
        value = azurerm_postgresql_flexible_server.this.administrator_login
      }

      env {
        name        = "DB_POSTGRESDB_PASSWORD"
        secret_name = "postgres-password"
      }

      env {
        name  = "N8N_PROTOCOL"
        value = "https"
      }

      env {
        name  = "N8N_HOST"
        value = "0.0.0.0"
      }

      env {
        name  = "N8N_PORT"
        value = "5678"
      }

      env {
        name  = "N8N_RUNNERS_ENABLED"
        value = "true"
      }

      env {
        name  = "WEBHOOK_URL"
        value = "https://${module.naming.container_app.name_unique}-n8n.${azurerm_container_app_environment.this.default_domain}"
      }

      env {
        name  = "DB_POSTGRESDB_SSL_ENABLED"
        value = "true"
      }

      env {
        name  = "AZURE_CLIENT_ID"
        value = azurerm_user_assigned_identity.this.client_id
      }

      env {
        name  = "AZURE_TENANT_ID"
        value = data.azurerm_client_config.current.tenant_id
      }

      # Volume mount for persistent data
      volume_mounts {
        name = "n8nconfig"
        path = "/home/node/.n8n"
      }
    }

    # Volume configuration
    volume {
      name         = "n8nconfig"
      storage_type = "AzureFile"
      storage_name = azurerm_container_app_environment_storage.n8n_config.name
    }
  }

  # Ingress configuration for external access
  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 5678

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  # Secret configuration
  secret {
    name                = "postgres-password"
    key_vault_secret_id = azurerm_key_vault_secret.postgres_password.versionless_id
    identity            = azurerm_user_assigned_identity.this.id
  }
}

# Qdrant Vector Database Container App
resource "azurerm_container_app" "qdrant" {
  name                         = "${module.naming.container_app.name_unique}-qdrant"
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = azurerm_resource_group.this.name
  revision_mode                = "Single"
  tags                         = var.tags

  # Managed identity configuration
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  # Container configuration
  template {
    min_replicas = 1
    max_replicas = 2

    container {
      name   = "qdrant"
      image  = "docker.io/qdrant/qdrant:latest"
      cpu    = 0.5
      memory = "1.0Gi"

      # Environment variables for Qdrant configuration
      env {
        name  = "QDRANT__SERVICE__HTTP_PORT"
        value = "6333"
      }

      env {
        name  = "QDRANT__SERVICE__GRPC_PORT"
        value = "6334"
      }

      env {
        name  = "QDRANT__LOG_LEVEL"
        value = "INFO"
      }

      # Volume mount for persistent data
      volume_mounts {
        name = "qdrant-storage"
        path = "/qdrant/storage"
      }
    }

    # Volume configuration for persistent storage
    volume {
      name         = "qdrant-storage"
      storage_type = "AzureFile"
      storage_name = azurerm_container_app_environment_storage.qdrant_storage.name
    }
  }

  # Ingress configuration for API access
  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 6333

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

# Storage configuration for Qdrant
resource "azurerm_storage_share" "qdrant_storage" {
  name                 = "qdrant-storage"
  storage_account_name = azurerm_storage_account.this.name
  quota                = 10
  access_tier          = "Hot"
}

resource "azurerm_container_app_environment_storage" "qdrant_storage" {
  name                         = "qdrant-storage"
  container_app_environment_id = azurerm_container_app_environment.this.id
  account_name                 = azurerm_storage_account.this.name
  share_name                   = azurerm_storage_share.qdrant_storage.name
  access_key                   = azurerm_storage_account.this.primary_access_key
  access_mode                  = "ReadWrite"
}
