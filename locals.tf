# Environment-specific configuration
# This file contains settings that can be customized per environment

locals {
  # Common tags applied to all resources
  common_tags = merge(var.tags, {
    "terraform"       = "true"
    "environment"     = var.environment_name
    "project"         = var.project_name
    "deployment-date" = formatdate("YYYY-MM-DD", timestamp())
  })

  # Environment-specific configuration
  environment_config = {
    dev = {
      postgres_sku              = "B_Standard_B1ms"
      postgres_storage_mb       = 32768
      postgres_backup_retention = 7
      container_min_replicas    = 1
      container_max_replicas    = 2
    }
    staging = {
      postgres_sku              = "GP_Standard_D2s_v3"
      postgres_storage_mb       = 65536
      postgres_backup_retention = 14
      container_min_replicas    = 1
      container_max_replicas    = 5
    }
    prod = {
      postgres_sku              = "GP_Standard_D4s_v3"
      postgres_storage_mb       = 131072
      postgres_backup_retention = 30
      container_min_replicas    = 2
      container_max_replicas    = 10
    }
  }

  # Current environment configuration
  current_config = local.environment_config[var.environment_name]

  # Resource naming with environment suffix
  resource_name_prefix = "${var.project_name}-${var.environment_name}"
}
