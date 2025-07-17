# Project Structure

```
n8n-azure-terraform/
├── README.md                    # Project overview and quick start guide
├── DEPLOYMENT.md               # Detailed deployment instructions
├── CONFIGURATION.md            # n8n and AI service configuration examples
├── .gitignore                  # Git ignore file for Terraform projects
├── deploy.sh                   # Automated deployment script
├── terraform.tfvars.example    # Example configuration file
│
├── providers.tf                # Terraform provider configuration
├── variables.tf                # Input variable definitions
├── locals.tf                   # Local values and environment config
├── outputs.tf                  # Output value definitions
│
├── main.tf                     # Core resources (resource group, identity)
├── postgresql.tf               # PostgreSQL database configuration
├── storage.tf                  # Azure Storage Account setup
├── key-vault.tf               # Azure Key Vault for secrets
├── openai.tf                  # Azure OpenAI service setup
└── container-apps.tf          # Container Apps (n8n and Qdrant)
```

## Quick Start

1. **Prerequisites**: Install Terraform and Azure CLI
2. **Configure**: Copy `terraform.tfvars.example` to `terraform.tfvars`
3. **Deploy**: Run `./deploy.sh` or use manual Terraform commands
4. **Access**: Use the URLs from Terraform outputs

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Key Vault    │    │ PostgreSQL DB   │    │ Storage Account │
│   (Secrets)     │    │  (n8n data)     │    │(Persistent data)│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
    ┌────▼───────────────────────▼───────────────────────▼────┐
    │              Container Apps Environment                  │
    │  ┌─────────────────┐      ┌─────────────────┐          │
    │  │      n8n        │      │     Qdrant      │          │
    │  │  (Workflows)    │      │ (Vector Store)  │          │
    │  └─────────────────┘      └─────────────────┘          │
    └─────────────────────────────────────────────────────────┘
```

## Features Delivered

✅ **Complete AI Stack**: n8n + Qdrant for vector operations  
✅ **Production Ready**: Managed services, scaling, monitoring  
✅ **Secure**: Key Vault, Managed Identity, encrypted connections  
✅ **Cost Optimized**: Consumption-based pricing, right-sized resources  
✅ **Environment Aware**: Dev/staging/prod configurations  
✅ **Infrastructure as Code**: Version controlled, repeatable deployments  

## Next Steps

1. **Deploy**: Follow DEPLOYMENT.md for step-by-step instructions
2. **Configure**: Use CONFIGURATION.md for n8n and AI setup
3. **Build**: Start creating your AI-powered automation workflows
4. **Scale**: Adjust resources based on your usage patterns

## Support

This project combines the best of:
- [n8n AI Starter Kit](https://docs.n8n.io/hosting/starter-kits/ai-starter-kit/)
- [Azure Container Apps](https://docs.microsoft.com/en-us/azure/container-apps/)
- [Azure OpenAI Service](https://docs.microsoft.com/en-us/azure/cognitive-services/openai/)
- [Qdrant Vector Database](https://qdrant.tech/)

For issues and questions, refer to the documentation links above.
