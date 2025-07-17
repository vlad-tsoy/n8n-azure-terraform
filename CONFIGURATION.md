# n8n Configuration Examples

This document provides examples of how to configure n8n with the deployed Azure resources.

## External AI Service Configuration

To use AI capabilities with n8n, you can configure external AI services:

### OpenAI API Configuration
- **API Key**: Your OpenAI API key
- **Base URL**: https://api.openai.com/v1
- **Model**: gpt-4o-mini, gpt-4, or other models
- **Organization**: Your OpenAI organization ID (optional)

### Anthropic Claude Configuration  
- **API Key**: Your Anthropic API key
- **Base URL**: https://api.anthropic.com
- **Model**: claude-3-sonnet, claude-3-haiku, etc.

### Example Environment Variables
```bash
# Add these to your n8n container if needed
OPENAI_API_KEY=your-openai-api-key
ANTHROPIC_API_KEY=your-anthropic-api-key
```

## Qdrant Vector Database Configuration

### Connection Settings
- **Host**: `{qdrant_url}` (from Terraform output)
- **Port**: 6333
- **Collection**: Create as needed in your workflows
- **API Key**: Not required (internal access)

### Example n8n Qdrant Node Configuration
```json
{
  "host": "https://your-qdrant-app.azurecontainerapps.io",
  "port": 6333,
  "apiKey": "",
  "collection": "my-vectors"
}
```

## PostgreSQL Database Configuration

The n8n database is automatically configured, but for reference:

- **Host**: `{postgresql_server_fqdn}` (from Terraform output)
- **Port**: 5432
- **Database**: n8n
- **Username**: psqladmin
- **Password**: Stored in Key Vault as `postgres-admin-password`

## Example Workflows

### 1. AI-Powered Document Processing

```json
{
  "name": "AI Document Processor",
  "nodes": [
    {
      "name": "Webhook Trigger",
      "type": "n8n-nodes-base.webhook",
      "parameters": {
        "path": "process-document"
      }
    },
    {
      "name": "Extract Text",
      "type": "n8n-nodes-base.extractFromFile"
    },
    {
      "name": "Generate Embeddings",
      "type": "n8n-nodes-langchain.embeddingsopenai",
      "parameters": {
        "options": {
          "openAiApiKey": "{{$credentials.openai.apiKey}}",
          "modelName": "text-embedding-3-small"
        }
      }
    },
    {
      "name": "Store in Qdrant",
      "type": "n8n-nodes-langchain.vectorstoreqdrant",
      "parameters": {
        "qdrantConfig": {
          "qdrantUrl": "https://your-qdrant-app.azurecontainerapps.io",
          "collectionName": "documents"
        }
      }
    }
  ]
}
```

### 2. AI Chat with Vector Search

```json
{
  "name": "RAG Chat Assistant",
  "nodes": [
    {
      "name": "Chat Trigger",
      "type": "n8n-nodes-langchain.chattrigger"
    },
    {
      "name": "Search Similar Documents",
      "type": "n8n-nodes-langchain.vectorstoreqdrant",
      "parameters": {
        "mode": "retrieve",
        "qdrantConfig": {
          "qdrantUrl": "https://your-qdrant-app.azurecontainerapps.io",
          "collectionName": "documents"
        },
        "topK": 5
      }
    },
    {
      "name": "AI Chat Response",
      "type": "n8n-nodes-langchain.lmchatopenai",
      "parameters": {
        "options": {
          "openAiApiKey": "{{$credentials.openai.apiKey}}",
          "modelName": "gpt-4o-mini"
        }
      }
    }
  ]
}
```

### 3. Automated Content Analysis

```json
{
  "name": "Content Analyzer",
  "nodes": [
    {
      "name": "Schedule Trigger",
      "type": "n8n-nodes-base.scheduletrigger",
      "parameters": {
        "rule": {
          "interval": [{"field": "hours", "value": 1}]
        }
      }
    },
    {
      "name": "Fetch Content",
      "type": "n8n-nodes-base.httprequest",
      "parameters": {
        "url": "https://api.example.com/content"
      }
    },
    {
      "name": "Analyze Sentiment",
      "type": "n8n-nodes-langchain.sentimentanalysis",
      "parameters": {
        "model": {
          "openAiApiKey": "{{$credentials.openai.apiKey}}",
          "modelName": "gpt-4o-mini"
        }
      }
    },
    {
      "name": "Store Results",
      "type": "n8n-nodes-base.postgres",
      "parameters": {
        "host": "your-postgresql-server.postgres.database.azure.com",
        "database": "n8n",
        "user": "psqladmin",
        "password": "{{$secrets.postgres_password}}"
      }
    }
  ]
}
```

## Security Best Practices

### 1. Use External AI Service Credentials
Instead of hardcoded values, configure credentials in n8n's credential manager:
- OpenAI API credentials
- Anthropic API credentials
- Other AI service credentials

### 2. Managed Identity
The deployment uses Azure Managed Identity for secure authentication between services without storing credentials.

### 3. Network Security
All communication between services uses HTTPS and Azure's internal networking.

## Monitoring and Troubleshooting

### Check Container Logs
```bash
# n8n logs
az containerapp logs show \
  --name your-n8n-app \
  --resource-group your-resource-group \
  --follow

# Qdrant logs  
az containerapp logs show \
  --name your-qdrant-app \
  --resource-group your-resource-group \
  --follow
```

### Monitor Resource Usage
```bash
# Check container app metrics
az monitor metrics list \
  --resource /subscriptions/{subscription}/resourceGroups/{rg}/providers/Microsoft.App/containerApps/{app-name} \
  --metric "Requests,CpuUsage,MemoryUsage"
```

### Database Performance
```bash
# Check PostgreSQL metrics
az postgres flexible-server parameter show \
  --resource-group your-resource-group \
  --server-name your-postgres-server \
  --name log_statement
```

## Scaling Considerations

### Container Apps Scaling
The deployment includes automatic scaling based on:
- HTTP requests
- CPU usage
- Memory usage

### Database Scaling
For production workloads, consider:
- Upgrading to General Purpose or Memory Optimized tiers
- Enabling read replicas
- Implementing connection pooling

### Vector Database Scaling
Qdrant can be scaled by:
- Increasing memory allocation
- Using multiple replicas
- Implementing collection sharding
