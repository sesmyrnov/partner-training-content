# Challenge 00 - Prerequisites - Ready, Set, GO!

**[Home](../README.md)** - [Next Challenge >](./Challenge-01.md)

## Introduction

Thank you for participating in this Azure Cosmos DB training.

Before you begin the hands-on challenges, please complete a few prerequisite steps.

In this section, you’ll validate your development environment and Azure subscription to ensure you have the required tools, permissions, and access configured correctly.

Make sure all prerequisites are completed before proceeding, as they are essential for successfully working through the upcoming challenges.

## Access Azure Subscription 
You will need an Azure subscription to complete this hack. (for June hack you would have received the credentials in your registered email address). If you don't have one, ask the proctor.

## Setup Development Environment 

You will need a set of developer tools to work with the sample application for this hack. You can use the credentials provided over your registered email.
  
## Access the lab & verify pre-reqs

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
python --version
pip --version
node --version
git --version
npm --version
```
Step-5: Install AZ Cli
  ```bash
 winget install -e --id Microsoft.AzureCLI
  ```

Open New CMD window and validate version
```
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
You need to run the multi-agent banking application that uses Azure Cosmos DB as its data foundation. This application demonstrates real-world patterns for using Cosmos DB with AI services.

The Azure Subscription will already have:
- Azure Cosmos DB account
- Azure OpenAI service with required models
- User-assigned managed identity with proper RBAC permissions
- Pre-seeded sample data for the banking application (you need to upload)

**NOTE:** All resources will be automatically configured with proper security settings and RBAC permissions. This includes a managed identity that will have access to both Cosmos DB and Azure OpenAI services.

Now follow the below mentioned steps:

Step-1: Open the browser and type portal.azure.com

Step-2: Specify domain user (e.g. xxx@mannu2050gmail578.onmicrosoft.com), the same vm password and click next. (This is available in the email sent to you).

Step-3: Now browser will ask you for MFA click next.

Step-4: In your phone 
```Bash
- Install Microsoft Authenticator App.
- Open the camera in your phone. 
- Scan the QR Code flashing on the browser & click next. 
- Now this domain user is added to your authenticator app.
- Check the phone which will now start displaying the code. It has limited expiry, if the code expires specify the new one.
- Input the code in the browser screen and login. 
```

Step-5: Click on View All resources.

Step-5: You should see OpenAI, Cosmos DB & VM in which you are logged in and supporting services.

All Services belong to the same resource group please stick to the same.

## Learning Resources

- [Azure Developer CLI Installation](https://aka.ms/install-azd)

**[Home](../README.md)** - [Next Challenge >](./Challenge-01.md)