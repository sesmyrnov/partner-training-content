# Challenge 00 - Prerequisites - Ready, Set, GO!

**[Home](../README.md)** - [Next Challenge >](./Challenge-01.md)

## Introduction

Thank you for participating in this Cosmos DB training. Before you can hack, you will need to verify & set up some prerequisites.

In this challenge, we need you to set up your development environment and Azure subscription to ensure you have all the necessary tools and access for the upcoming challenges.

Before you can start working on the challenges, you need to make sure you have the right prerequisites in place.
- [Challenge 00 - Prerequisites - Ready, Set, GO!](#challenge-00---prerequisites---ready-set-go)
  - [Introduction](#introduction)
  - [Access Azure Subscription](#access-azure-subscription)
  - [Setup Development Environment](#setup-development-environment)
    - [Use Local Workstation (For June hack it is Preferred)](#use-local-workstation)
    - [Student Resources](#student-resources)
  - [Setup the Banking Application](#setup-the-banking-application)
  - [Deploy Azure Services](#deploy-azure-services)
  - [Success Criteria](#success-criteria)
  - [Learning Resources](#learning-resources)

## Access Azure Subscription 
You will need an Azure subscription to complete this hack. (for June hack you would have received the credentials in your registered email address). If you don't have one, ask proctor.

## Setup Development Environment 

You will need a set of developer tools to work with the sample application for this hack. You can use the credentials provided over your registered email.
  
## Setup the Banking Application
You need to run the multi-agent banking application that uses Azure Cosmos DB as its data foundation. This application demonstrates real-world patterns for using Cosmos DB with AI services.

The Azure Subscription will already have:
- Azure Cosmos DB account
- Azure OpenAI service with required models
- User-assigned managed identity with proper RBAC permissions
- Pre-seeded sample data for the banking application (you need to upload)

**NOTE:** All resources will be automatically configured with proper security settings and RBAC permissions. This includes a managed identity that will have access to both Cosmos DB and Azure OpenAI services.

## Verify Pre-req Installation 
Step-1: Open Remote Desktop / Windows + run --> type mstsc.

Step-2: Specify the Computer Name & credentials shared to you via email (UserName & Password).

Step-3: Once connected to VM, first step is that you need to add npm to Your Windows Environment PATH.

Press the Windows Key, type "Environment Variables" in the search, and select Edit the system environment variables.
  - Click the Environment Variables... button at the bottom right
  - Under User variables, look for the variable named Path (or PATH), select it, and click Edit.
  - Click New and paste the following path
			%AppData%\npm
  - Press Ok to close, repeat for another dialogue

Step-4: Open Command prompt in the VM and execute the following to check if the pre-requisites are installed:
```bash
python –-version
pip –-version
node –-version
git –-version
npm --version
```
Step-5: Install AZ Cli
  ```bash
 winget install -e --id Microsoft.AzureCLI
  az --version
  ```

Step-6: Close the command prompt

Step-7: open git bash and run the following command to clone (this command will clone the content in the download folder, you can choose any other and remember it)
```bash
cd downloads
git clone https://github.com/AzureCosmosDB/partner-training-content
```
Now you have validated that the VM have following components successfully installed:
- [Git](https://git-scm.com/downloads)
- [Azure Developer CLI (azd)](https://aka.ms/install-azd)
- [Python 3.12+](https://www.python.org/downloads/)
- [Node.js](https://nodejs.org/en/download/)
- [Angular CLI](https://angular.dev/installation#install-angular-cli)
- [VS Code](https://code.visualstudio.com/Download) with [Python Extension](https://marketplace.visualstudio.com/items?itemName=ms-python.python)



## Verify Azure Services
Step-1: Open the browser and type portal.azure.com

Step-2: Specify domain user and the same vm password

Step-3: In your phone install Authenticator, scan the QR Code flash on the browser, click next and specify the code in the browser shown in Authenticator app against the account.

Step-4: Click on View All resources.

Step-5: You should see OpenAI, Cosmos DB & VM in which you are logged in and supporting services.

All Services belong to the same resource group please stick to the same.

## Learning Resources

- [Request Access to Azure OpenAI Service](https://aka.ms/oaiapply)
- [Manage Azure OpenAI Service Quota](https://learn.microsoft.com/azure/ai-services/openai/how-to/quota)
- [Azure Subscription Permission Requirements](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles/privileged#owner)
- [Azure Developer CLI Installation](https://aka.ms/install-azd)

**[Home](../README.md)** - [Next Challenge >](./Challenge-01.md)