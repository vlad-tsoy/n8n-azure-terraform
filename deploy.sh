#!/bin/bash

# n8n Azure Terraform Deployment Script
# This script automates the deployment process with proper validation

set -e  # Exit on any error

echo "🚀 Starting n8n Azure deployment..."

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first:"
    echo "   macOS: brew install terraform"
    echo "   Windows: winget install HashiCorp.Terraform"
    exit 1
fi

# Check if Azure CLI is installed and user is logged in
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first:"
    echo "   macOS: brew install azure-cli"
    echo "   Windows: winget install Microsoft.AzureCLI"
    exit 1
fi

# Check if logged into Azure
if ! az account show &> /dev/null; then
    echo "❌ Not logged into Azure. Please run 'az login' first."
    exit 1
fi

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "❌ terraform.tfvars file not found."
    echo "Please copy terraform.tfvars.example to terraform.tfvars and customize it:"
    echo "   cp terraform.tfvars.example terraform.tfvars"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Validate configuration
echo "🔍 Validating Terraform configuration..."
terraform validate

# Format code
echo "🎨 Formatting Terraform code..."
terraform fmt

# Plan deployment
echo "📋 Creating deployment plan..."
terraform plan -out=tfplan

# Ask for confirmation
echo ""
echo "🤔 Ready to deploy? This will create Azure resources that may incur costs."
read -p "Do you want to proceed? (yes/no): " -r
echo ""

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "❌ Deployment cancelled"
    rm -f tfplan
    exit 1
fi

# Apply deployment
echo "🚀 Deploying infrastructure..."
terraform apply tfplan

# Clean up plan file
rm -f tfplan

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Important URLs and information:"
terraform output

echo ""
echo "🔗 Next steps:"
echo "1. Open the n8n URL in your browser"
echo "2. Create your admin account"
echo "3. Configure Azure OpenAI integration"
echo "4. Start building your workflows!"
echo ""
echo "📚 For detailed configuration, see DEPLOYMENT.md"
