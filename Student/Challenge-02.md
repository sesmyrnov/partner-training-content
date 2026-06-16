# Challenge 02 - AI-Powered Search with Vector Embeddings

**[< Previous Challenge](./Challenge-01.md)** - **[Home](../README.md)** - **[Next Challenge >](./Challenge-03.md)**

## Introduction

Modern applications increasingly require intelligent search capabilities that go beyond simple text matching. 
This challenge demonstrates how to build AI-powered applications using Azure Cosmos DB's vector search capabilities. You will explore a multi-agent banking system that combines traditional queries with AI-powered semantic search.
## Creating Database and container

If you are new to Azure Cosmos DB here are the steps to create the container. These are the same steps you have followed in Lab01.

Step-1: Open Cosmos DB Blade in Azure Portal

Step-2: Open Data Explorer

Step-3: Click on New Container.

Step-4: Specify 
- Database id, (new only once subsequently choose from dropdown)
- Container id, 
- Partition Key, 
- Click on Add hierarchical partition key if you need to specify more than one partition key
- Specify Container throughput = Autoscale
- Specify Maximum RU/s = 1000

Step-4a: Only for OffersData expand Container Vector Policy and specify:
- Path = /vector
- Data type = float32
- Distance function = cosine
- Dimensions = 1536
- Index type = diskANN (leave everything else as default)


Step-5: Create the following database and container (Cosmos DB is case sensitive hence ensure correctness):

| Database id | Container id | Partition Key Path(s) | Hierarchical PK | Autoscale | RUs | Notes |
|---|---|---|---|---|---|---|
| MultiAgentBanking | Chat | /tenantId, /userId, /sessionId | Yes | Yes | 1000 | Chat session isolation, high cardinality |
| MultiAgentBanking | AccountsData | /tenantId, /accountId | Yes | Yes | 1000 | Multi-tenant financial data |
| MultiAgentBanking | OffersData | /tenantId | No | Yes | 1000 | Includes vector + full-text indexing |
| MultiAgentBanking | Users | /tenantId | No | Yes | 1000 | User master data |
| MultiAgentBanking | Checkpoints | /partition_key | No | Yes | 1000 | Workflow / agent state checkpoints |
| MultiAgentBanking | ChatHistory | /sessionId | No | Yes | 1000 | Historical chat logs |
| MultiAgentBanking | Debug | /sessionId | No | Yes | 1000 | Debug / troubleshooting data |

## Load the Data
We have created sample data for the lab, follow the stes to upload it.

Step-1: Open the notepad and copy paste the following environment variables.
```bash
set COSMOSDB_ENDPOINT=REPLACE_ME_WITH_UR_COSMOSDB_URI
set AZURE_OPENAI_ENDPOINT=REPLACE_ME_WITH_UR_OPENAI_URI
set AZURE_OPENAI_COMPLETIONSDEPLOYMENTID=gpt-4.1-mini
set AZURE_OPENAI_EMBEDDINGDEPLOYMENTID=text-embedding-3-small
set AZURE_OPENAI_API_VERSION=2024-09-01-preview
```
Let us fill the values:

Step-2: Open the Azure portal --> Cosmos DB Overview page copy the URI and paste against REPLACE_ME_WITH_UR_COSMOSDB_URI in notepad.

Step-3: Navigate to Azure OpenAI blade --> click on "Click here to view endpoints" --> Copy only the endpoint. Paste it against the REPLACE_ME_WITH_UR_OPENAI_URI.

Step-4: Open the command prompt.

Step-5: Goto folder <path where you have cloned the repo>partner-training-content\

Step-6: Copy the environment variables from notepad where you have  updated values to command prompt and press enter. This will set the environment variables.
```bash
set COSMOSDB_ENDPOINT=REPLACE_ME_WITH_UR_COSMOSDB_URI
set AZURE_OPENAI_ENDPOINT=REPLACE_ME_WITH_UR_OPENAI_URI
set AZURE_OPENAI_COMPLETIONSDEPLOYMENTID=gpt-4.1-mini
set AZURE_OPENAI_EMBEDDINGDEPLOYMENTID=text-embedding-3-small
set AZURE_OPENAI_API_VERSION=2024-09-01-preview
```
Step-7: Let us install dependencies and upgrade NodeJS.

```bash
cd Student/Resources/banking-workshop/backend

python -m venv .venv
.venv\Scripts\activate

pip install -r src/app/requirements.txt

winget install --id OpenJS.NodeJS.22 --accept-package-agreements --accept-source-agreements
```

Step-8: Load the data (assuming you are in folder ..Student\Resources\banking-workshop\infra\data):
```bash
cd..
python ./infra/data/load.py
```

Step-9: Start the FastAPI service:

```bash
uvicorn src.app.banking_agents_api:app --host 0.0.0.0 --port 63280
```

You should see output similar to the following:

```text
INFO:     Started server process [69449]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:63280 (Press CTRL+C to quit)
```

## Start the web application

In a new terminal, navigate to the `/frontend` folder, and install dependencies:

```bash
cd Student/Resources/banking-workshop/frontend
npm install
```

Start the web app:

```bash
ng serve --proxy-config proxy.conf.json
```

Open a browser and navigate to `http://localhost:4200` to view the frontend.

You should be able to create a chat session, send messages, and receive completions from the agents.

![Final User Interface](./images/frontend.png)

## Start a conversation

Each agent is equipped with the ability to delegate tasks and transfer control to other relevant agents when needed.

In your browser, create a new conversation and try transferring money.

1. Type the following text:

```text
I want to transfer money
```

1. When prompted provide the amount and the accounts to transfer from and to.

```text
I want to transfer 500 from Acc001 to Acc003
```

1. When prompted, confirm the transaction (enter `Yes`).
1. The conversation should look similar to this.

![transfer](./images/transfer.png)

Navigate to the Azure Portal, and open the Azure Cosmos DB account. Open the `AccountsData` container and verify the transaction was successful.

Return to the frontend in your browser, Let's test a new scenario that will invoke a vector search for banking offers. Close the existing conversation and open a new one.

1. Type the following text to enquire about banking offers:

```text
Tell me about your banking offers
```

1. When transferred to the sales agent (which handles queries about product information) it will respond with a range of offers to choose from.

2. Type the following text:

```text
credit card
```

The conversation should look similar to this.

![offers](./images/offers.png)

## Bonus Activity: Test with Swagger

This solution is built as a backend that exposes API's called by the frontend. With the API layer ready, let's explore simple testing against our API layer in our application.

Open a new browser tab and navigate to <http://localhost:63280/docs> to view the swagger UI.

![Swagger UI](./images/swagger_ui.png)

This app comes with a few pre-created tenant and user ids that you can use to test with.

| Tenant Id | User Id  |
|-----------|----------|
| Contoso   | Mark     |
| Contoso   | Manish   |
| Contoso   | Sandeep  |
| Contoso   | Theo     |
| Fabrikam  | Sajee    |
| Fabrikam  | Abhishek |
| Fabrikam  | David    |

We will demonstrate this doing manual testing using the Swagger UI with these operations below. To automate this, you'd take the URIs you see in Swagger and write REST API calls using a testing tool.

Create a new session with tenantId = `Contoso` and userId = `Mark`

![Create a new session](./images/post_create_session.png)

Click Execute.

Capture the value of the new sessionId

```json
{
  "id": "653cc488-e9d5-4af4-9175-9410e501acb9",
  "type": "session",
  "sessionId": "653cc488-e9d5-4af4-9175-9410e501acb9",
  "tenantId": "Contoso",
  "userId": "Mark",
  "tokensUsed": 0,
  "name": "Mark Brown",
  "messages": []
}
```

Next use the tenantId, userId, and the sessionId created above to say "Hello there!" to our agents.

![Create a new completion](./images/post_create_completion.png)

Fill in the values and click execute.

Here you can see the request from Swagger and the response from our agent.

```json
[
  {
    "id": "1a568dff-43fe-4477-977b-9c21c8bf61f3",
    "type": "ai_response",
    "sessionId": "653cc488-e9d5-4af4-9175-9410e501acb9",
    "tenantId": "Contoso",
    "userId": "Mark",
    "timeStamp": "",
    "sender": "User",
    "senderRole": "User",
    "text": "Hello there!",
    "debugLogId": "a7203518-51d3-4df8-aa43-7c041b553776",
    "tokensUsed": 0,
    "rating": true,
    "completionPromptId": ""
  },
  {
    "id": "10c6daa8-714d-41d8-b564-99a6c8ffdb5d",
    "type": "ai_response",
    "sessionId": "653cc488-e9d5-4af4-9175-9410e501acb9",
    "tenantId": "Contoso",
    "userId": "Mark",
    "timeStamp": "",
    "sender": "Coordinator",
    "senderRole": "Assistant",
    "text": "Hi there! Welcome to our bank. How can I assist you today? Are you looking for help with general inquiries, opening a new account or loan, or managing transactions? Let me know!",
    "debugLogId": "a7203518-51d3-4df8-aa43-7c041b553776",
    "tokensUsed": 265,
    "rating": true,
    "completionPromptId": ""
  }
]
```

## Success Criteria

To complete this challenge successfully, you should:

- Identify and document which Cosmos DB containers store vector embeddings and explain how they are used for semantic search
- Explore the agent coordination flow, explaining how queries are routed between specialized agents and how conversation context is maintained
- Monitor and record RU consumption for vector search operations compared to simple queries
- Analyze and compare query execution times across different search patterns (exact text matching vs. semantic similarity)

## Learning Resources

- [Vector Search in Azure Cosmos DB](https://docs.microsoft.com/azure/cosmos-db/vector-search)
- [Azure OpenAI Embeddings](https://docs.microsoft.com/azure/cognitive-services/openai/concepts/embeddings)
- [Building Multi-Agent Systems](https://docs.microsoft.com/azure/cognitive-services/openai/concepts/advanced-usage)
- [Hybrid Search Patterns](https://docs.microsoft.com/azure/search/hybrid-search-overview)

## Tips

- Use the browser's developer tools to monitor network requests and understand the API calls
- Check the Azure portal's Cosmos DB Data Explorer to see how data is structured
- Pay attention to the different types of messages stored in the `Chat` and `ChatHistory` containers
- The `Debug` container contains useful information about agent decisions and search operations
- Vector searches typically consume more RUs than simple queries - monitor this in the portal
- Each agent has specialized prompts that determine their behavior and capabilities


## Troubleshooting

- If the frontend doesn't start, ensure Node.js and Angular CLI are properly installed
- If the API returns errors, check that your Azure OpenAI service is running and has sufficient quota
- If vector searches aren't working, verify that the embedding model deployment is successful
- Monitor Azure costs during testing as AI services can accumulate charges quickly

## Advanced Challenges (Optional, time permitting)

- **Custom Vector Search:** Implement your own vector search functionality for a new type of banking product
- **Search Optimization:** Experiment with different similarity thresholds and measure their impact on search relevance
- **Hybrid Search Implementation:** Create a search function that combines both vector similarity and full-text search results, experimenting with different ranking and weighting strategies
- **Multi-modal Search:** Enhance the search to combine text vectors with other data types (dates, amounts, categories)
- **Performance Tuning:** Implement caching strategies for frequently accessed vectors to reduce RU consumption
- **Advanced Agents:** Create a new specialized agent that handles investment or insurance products

**[< Previous Challenge](./Challenge-01.md)** - **[Home](../README.md)** - **[Next Challenge >](./Challenge-03.md)**
