# Challenge 00 - Prerequisites - Ready, Set, GO!

**[Home](../README.md)** - [Next Challenge >](./Challenge-01.md)

## Introduction

Thank you for participating in this Cosmos DB training. Before you can hack, you will need to set up some prerequisites.

In this challenge, we need to set up your development environment and Azure subscription to ensure you have all the necessary tools and access for the upcoming challenges.

Before you can start working on the challenges, you need to make sure you have the right prerequisites in place.
- [Challenge 00 - Prerequisites - Ready, Set, GO!](#challenge-00---prerequisites---ready-set-go)
  - [Introduction](#introduction)
  - [Access Azure Subscription](#access-azure-subscription)
  - [Setup Development Environment](#setup-development-environment)
    - [Use Local Workstation (For June hack it is Preferred)](#use-local-workstation)
    - [Use Github Codespaces](#use-github-codespaces)
    - [Student Resources](#student-resources)
  - [Setup the Banking Application](#setup-the-banking-application)
  - [Deploy Azure Services](#deploy-azure-services)
  - [Success Criteria](#success-criteria)
  - [Learning Resources](#learning-resources)

## Access Azure Subscription 
You will need an Azure subscription to complete this hack. (for June hack you would have received the credentials in your registered email address) If you don't have one, get a free trial here...
- [Azure Subscription](https://azure.microsoft.com/en-us/free/)

## Setup Development Environment 

You will need a set of developer tools to work with the sample application for this hack. 

You can use GitHub Codespaces where we have a pre-configured development environment set up and ready to go for you, or you can setup the developer tools on your local workstation.

A GitHub Codespace is a development environment that is hosted in the cloud that you access via a browser. All of the pre-requisite developer tools for this hack are pre-installed and available in the codespace.


- [Use Local Workstation](#use-local-workstation)
- [Use GitHub Codespaces](#use-github-codespaces)

**NOTE:** We highly recommend using GitHub Codespaces to make it easier to complete this hack.

### Use Github Codespaces

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/AzureCosmosDB/partner-training-content) <BR>
You must have a GitHub account to use GitHub Codespaces. If you do not have a GitHub account, you can [Sign Up Here](https://github.com/signup).

GitHub Codespaces is available for developers in every organization. All personal GitHub.com accounts include a monthly quota of free usage each month. GitHub will provide users in the Free plan 120 core hours, or 60 hours of run time on a 2 core codespace, plus 15 GB of storage each month.

Please open this link and sign in with your personal Github account. 
**NOTE:** Make sure you do not sign in with your enterprise managed Github account.

You can see your balance of available codespace hours on the [GitHub billing page](https://github.com/settings/billing/summary).

The GitHub Codespace for this hack will host the developer tools, sample application code, configuration files, and other data files needed for this hack. Here are the steps you will need to follow:

Your Codespace environment should load in a new browser tab. It will take approximately 3-5 minutes the first time you create the codespace for it to load.

- When the codespace completes loading, you should find an instance of Visual Studio Code running in your browser with the files needed for this hackathon.

Your developer environment is ready, hooray! Skip to section: [Deploy Azure Resources](#deploy-azure-resources)

**NOTE:** If you close your Codespace window, or need to return to it later, you can go to [GitHub Codespaces](https://github.com/codespaces) and you should find your existing Codespaces listed with a link to re-launch it.

**NOTE:** GitHub Codespaces time out after 20 minutes if you are not actively interacting with it in the browser. If your codespace times out, you can restart it and the developer environment and its files will return with its state intact within seconds. If you want to have a better experience, you can also update the default timeout value in your personal setting page on Github. Refer to this page for instructions: [Default-Timeout-Period](https://docs.github.com/en/codespaces/setting-your-user-preferences/setting-your-timeout-period-for-github-codespaces#setting-your-default-timeout-period) 

**NOTE:** Codespaces expire after 30 days unless you extend the expiration date. When a Codespace expires, the state of all files in it will be lost.

### Use Local Workstation

**NOTE:** You can skip this section and continue on to "Setup Banking Application" if are using GitHub Codespaces!

If you want to setup your environment on your local workstation, expand the section below and follow the requirements listed. 

<details markdown=1>
<summary markdown="span">Click to expand/collapse Local Workstation Requirements</summary>
  
### Student Resources

The sample application code, Azure deployment scripts, and sample data sources for this hack are available in a Student Resources package.

You will need to install these on your local workstation:

- [Git](https://git-scm.com/downloads)
  - [Azure Developer CLI (azd)](https://aka.ms/install-azd)
  - [Python 3.12+](https://www.python.org/downloads/)
  - [Node.js](https://nodejs.org/en/download/)
  - [Angular CLI](https://angular.dev/installation#install-angular-cli)
  - [VS Code](https://code.visualstudio.com/Download) with [Python Extension](https://marketplace.visualstudio.com/items?itemName=ms-python.python)

</details>

## Setup the Banking Application
You need to deploy a multi-agent banking application that uses Azure Cosmos DB as its data foundation. This application demonstrates real-world patterns for using Cosmos DB with AI services.

The deployment will create:
- Azure Cosmos DB account with multiple containers
- Azure OpenAI service with required models
- User-assigned managed identity with proper RBAC permissions
- Pre-seeded sample data for the banking application

**NOTE:** All resources will be automatically configured with proper security settings and RBAC permissions. This includes a managed identity that will have access to both Cosmos DB and Azure OpenAI services.
## Deploy Azure Services

Log in with your Azure credentials using the Azure Developer CLI (`azd`):

   ```shell
   azd auth login
   ```

Navigate to the banking-workshop folder:

```bash
cd Student/Resources/banking-workshop
```
Deploy the Azure services using `azd up`:

   ```shell
   azd up
   ```

When prompted for the environment name, enter: `workshop`.

Use the default selections for the Azure subscription and region.

## Success Criteria

Before you proceed, make sure all Azure resources are deployed successfully. Navigate to the Azure Cosmos DB account in the Azure portal to view the containers. You should see pre-seeded transactional data in the `OffersData`, `AccountsData`, and `Users` containers, as well as other containers `Chat`, `ChatHistory`, `Checkpoints`, and `Debug`.

## Learning Resources

- [Request Access to Azure OpenAI Service](https://aka.ms/oaiapply)
- [Manage Azure OpenAI Service Quota](https://learn.microsoft.com/azure/ai-services/openai/how-to/quota)
- [Azure Subscription Permission Requirements](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles/privileged#owner)
- [Azure Developer CLI Installation](https://aka.ms/install-azd)

**[Home](../README.md)** - [Next Challenge >](./Challenge-01.md)