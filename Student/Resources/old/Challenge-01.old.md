# Challenge 01 - Environment Setup & First Steps

**[< Previous Challenge](./Challenge-00.md)** - **[Home](../README.md)** - **[Next Challenge >](./Challenge-02.md)**

## Introduction

Now that you have your development environment ready, it's time to deploy your first Azure Cosmos DB environment and get familiar with the basic setup. In this challenge, you'll deploy a complete banking application infrastructure that includes Azure Cosmos DB, Azure OpenAI, and supporting services.

## Description

You need to deploy a multi-agent banking application that uses Azure Cosmos DB as its data foundation. This application demonstrates real-world patterns for using Cosmos DB with AI services.

The deployment will create:
- Azure Cosmos DB account with multiple containers
- Azure OpenAI service with required models
- User-assigned managed identity with proper RBAC permissions
- Pre-seeded sample data for the banking application

**NOTE:** All resources will be automatically configured with proper security settings and RBAC permissions. This includes a managed identity that will have access to both Cosmos DB and Azure OpenAI services.

## Success Criteria

To complete this challenge successfully, you should:

- Successfully authenticate with Azure using `azd auth login`
- Deploy all Azure resources using Azure Developer CLI
- Verify that the following Azure resources are created:
  - Azure Cosmos DB account 
  - Azure OpenAI service with deployed models (GPT-4o and text-embedding-3-small)
  - User-assigned managed identity with proper permissions
- Confirm that Azure Cosmos DB contains the following containers with data:
  - `OffersData` (banking offers)
  - `AccountsData` (customer accounts)  
  - `Users` (customer information)
  - `Chat` (for storing chat conversations)
  - `ChatHistory` (conversation history)
  - `Checkpoints` (application state)
  - `Debug` (debugging information)
- Can access the Azure Cosmos DB Data Explorer in the Azure portal
- Can see sample data in the containers using Data Explorer

## Learning Resources

- [Azure Developer CLI Documentation](https://docs.microsoft.com/azure/developer/azure-developer-cli/)
- [Azure Cosmos DB Data Explorer](https://docs.microsoft.com/azure/cosmos-db/data-explorer)
- [Azure OpenAI Service Overview](https://docs.microsoft.com/azure/cognitive-services/openai/)
- [User-Assigned Managed Identity](https://learn.microsoft.com/entra/identity/managed-identities-azure-resources/overview)

## Tips

- The Azure Developer CLI (`azd`) automates the entire deployment process
- Use `workshop` as your environment name when prompted
- Accept the default subscription and region unless you have specific requirements
- The deployment may take 10-15 minutes to complete
- If deployment fails, check the Azure portal for any quota or permission issues
- You can re-run `azd up` if the deployment fails partway through

## Advanced Challenges (Optional)

- Explore the Azure Cosmos DB metrics and monitoring capabilities in the Azure portal
- Review the RBAC permissions that were automatically assigned to the managed identity
- Use the Azure CLI to query the Cosmos DB containers and explore the data structure
- Compare the different consistency levels available in your Cosmos DB account

**[< Previous Challenge](./Challenge-00.md)** - **[Home](../README.md)** - **[Next Challenge >](./Challenge-02.md)**