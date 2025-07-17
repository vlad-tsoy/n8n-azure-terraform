# Deployment Guide

This guide walks you through deploying the n8n AI platform on Azure using Terraform.

## Prerequisites

### 1. Install Required Tools

**Terraform:**
```bash
# On macOS using Homebrew
brew install terraform

# On Windows using winget
winget install HashiCorp.Terraform

# Verify installation
terraform version
```

**Azure CLI:**
```bash
# On macOS using Homebrew
brew install azure-cli

# On Windows using winget
winget install Microsoft.AzureCLI

# Login to Azure
az login
```

### 2. Verify Azure Permissions

Ensure your account has the following permissions in your Azure subscription:
- Contributor role on the subscription or resource group
- User Access Administrator role (for managed identity assignments)
- Key Vault Contributor role

## Step-by-Step Deployment

### 1. Clone and Configure

```bash
# Navigate to your project directory
cd /path/to/n8n-azure-terraform

# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars
```

### 2. Edit Configuration

Edit `terraform.tfvars` with your specific values:

```hcl
# Required: Your Azure subscription ID
subscription_id = "your-subscription-id-here"

# Optional: Customize other settings
location = "eastus2"
environment_name = "dev"
project_name = "n8n-ai"

tags = {
  Environment = "development"
  Project     = "n8n-ai-platform"
  Owner       = "your-team-name"
}
```

### 3. Initialize Terraform

```bash
terraform init
```

This will:
- Download required provider plugins
- Initialize the backend
- Prepare the working directory

### 4. Validate Configuration

```bash
terraform validate
```

This checks your configuration for syntax errors and consistency.

### 5. Plan Deployment

```bash
terraform plan
```

Review the planned changes carefully. You should see resources being created for:
- Resource Group
- Container Apps Environment
- PostgreSQL Flexible Server
- Key Vault
- Storage Account
- Container Apps (n8n and Qdrant)
- Managed Identity

### 6. Deploy Resources

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

**Expected deployment time: 10-15 minutes**

### 7. Verify Deployment

After successful deployment, you'll see outputs including:

```
n8n_url = "https://your-n8n-app.azurecontainerapps.io"
qdrant_url = "https://your-qdrant-app.azurecontainerapps.io"
```

## Post-Deployment Configuration

### 1. Access n8n

1. Open the `n8n_url` from the output in your browser
2. Create your first admin user account
3. Configure your n8n instance

### 2. Configure External AI Services (Optional)

If you want to use AI capabilities with n8n, you can configure external AI services:
- OpenAI API (requires external API key)
- Anthropic Claude (requires external API key)
- Other AI providers supported by n8n

Configure these in n8n's credentials section with your external API keys.

### 3. Configure Qdrant Vector Database

In n8n, configure Qdrant connection:
- **Host**: Use the `qdrant_url` from output
- **Port**: 6333 (default)
- **API Key**: Not required for this deployment

## Troubleshooting

### Common Issues

**1. Insufficient Permissions**
```
Error: creating Cognitive Account: authorization.RoleAssignmentNotFound
```
Solution: Ensure you have Contributor role on the subscription.

**2. Quota Exceeded**
```
Error: creating PostgreSQL Flexible Server: QuotaExceeded
```
Solution: Check Azure quotas in the selected region or try a different region.

**3. Container App Startup Issues**
Check container logs:
```bash
az containerapp logs show \
  --name your-n8n-app-name \
  --resource-group your-resource-group-name \
  --follow
```

### Getting Help

1. **Check Azure Portal**: Monitor deployment progress and resource status
2. **View Logs**: Use Azure Log Analytics or container app logs
3. **Review Configuration**: Ensure all environment variables are set correctly

## Cleanup

To remove all resources:

```bash
terraform destroy
```

Type `yes` when prompted to confirm resource deletion.

## Next Steps

1. **Configure Workflows**: Start building your automation workflows in n8n
2. **Set up AI Integrations**: Connect to external AI services for AI-powered workflows
3. **Configure Vector Storage**: Use Qdrant for RAG (Retrieval-Augmented Generation) workflows
4. **Monitor Usage**: Set up Azure Monitor for observability
5. **Scale**: Adjust container app scaling rules based on usage patterns

## Cost Optimization Tips

1. **Use Consumption Plan**: Container Apps automatically scale down when not in use
2. **Monitor Usage**: Set up Azure Cost Management alerts
3. **Optimize Database**: Consider pausing PostgreSQL during development
4. **Review Storage**: Clean up unused files in storage accounts regularly

## Security Recommendations

1. **Network Security**: Consider implementing private endpoints for production
2. **Access Control**: Set up proper RBAC roles for team members
3. **Secret Rotation**: Implement automated secret rotation for sensitive credentials
4. **Monitoring**: Enable Azure Security Center recommendations
