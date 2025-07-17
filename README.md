# n8n Azure Deployment with Terraform

This Terraform project deploys n8n workflow automation platform on Azure Container Apps with AI capabilities, inspired by the n8n AI Starter Kit but excluding Ollama for a more Azure-native approach.

## Architecture

This deployment creates:

- **n8n** - Workflow automation platform running on Azure Container Apps
- **Azure PostgreSQL Flexible Server** - Database backend for n8n
- **Qdrant Vector Database** - Vector storage for AI/RAG capabilities  
- **Azure Key Vault** - Secure secret management
- **Azure Storage Account** - File storage and persistence
- **Azure Container Apps Environment** - Container hosting platform
- **User-Assigned Managed Identity** - Secure authentication

## Features

✅ **Self-hosted n8n**: Low-code platform with 400+ integrations and advanced AI components  
✅ **Qdrant Vector Store**: High-performance vector database for embeddings and similarity search  
✅ **PostgreSQL Database**: Reliable data storage for workflows and execution history  
✅ **Secure Configuration**: Azure Key Vault integration for secrets management  
✅ **Cost Optimized**: Azure Container Apps for efficient resource utilization  
✅ **Azure-Native**: Leverages Azure's managed services and security features

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) ~> 1.11
- Azure CLI configured with appropriate permissions
- Azure subscription with sufficient quota for the resources

## Quick Start

1. Clone this repository and navigate to the project directory
2. Copy the example variables file and customize it:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
3. Edit `terraform.tfvars` with your specific values
4. Initialize and deploy:
   ```bash
   terraform init
   terraform validate
   terraform plan
   terraform apply
   ```

## Configuration

### Required Variables

- `subscription_id` - Your Azure subscription ID
- `location` - Azure region (default: "East US 2")

### Optional Variables

- `tags` - Custom tags for resources
- `enable_telemetry` - Enable Azure telemetry (default: false)

## Outputs

After successful deployment, you'll receive:

- `n8n_url` - URL to access your n8n instance
- `qdrant_url` - Qdrant vector database endpoint
- `key_vault_name` - Key Vault name for secrets

## Security

- All secrets are stored in Azure Key Vault
- Managed Identity is used for authentication between services
- Network access is configured for secure communication
- SSL/TLS encryption is enabled for all endpoints

## Cost Optimization

This deployment uses:
- Azure Container Apps (consumption-based pricing)
- PostgreSQL Flexible Server (Burstable B1ms tier)
- Basic tier storage accounts

## Cleanup

To remove all resources:
```bash
terraform destroy
```

## Support

This project is based on the [n8n AI Starter Kit](https://docs.n8n.io/hosting/starter-kits/ai-starter-kit/) and [n8n Azure Container App deployment](https://github.com/pjpaulor/n8n-azure-container-app).

For issues and questions:
- [n8n Documentation](https://docs.n8n.io/)
- [Azure Container Apps Documentation](https://docs.microsoft.com/en-us/azure/container-apps/)
