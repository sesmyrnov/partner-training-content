# What The Hack - Azure Cosmos DB for AI & Modern Applications - Coach Guide

## Introduction

Welcome to the coach's guide for Azure Cosmos DB for AI & Modern Applications. Here you will find links to specific guidance for coaches for each of the challenges.

This hack includes optional lecture presentations that feature short presentations to introduce key topics associated with each challenge. It is recommended that the host present each short presentation before attendees kick off that challenge.

**NOTE:** `Kickoff & Overview.pptx` presentation deck has linked Demo videos which are located in the same folder to reduce overall file size based on GitHub limits. They work automatically if repo is cloned any local Letter Drive, but if copied to OneDrive - links need to be updated for videos to work.

**NOTE:** If you are a Hackathon participant, this is the answer guide. Don't cheat yourself by looking at these during the hack! Go learn something. :)

## Coach's Guides

- Challenge 00: **[Prerequisites - Ready, Set, GO!](./Solutions/Solution-00.md)**
  - Prepare development environment and Azure subscription access
- Challenge 01: **[Environment Setup & First Steps](./Solutions/Solution-01.md)**
  - Provision Cosmos DB accounts, configure basics, and validate connectivity
- Challenge 02: **[Data Modeling & Query Optimization](./Solutions/Solution-02.md)**
  - Design partitioned data models, write efficient queries, and analyze performance
- Challenge 03: **[AI-Powered Search with Vector Embeddings](./Solutions/Solution-03.md)**
  - Build AI agents with full-text, vector, and hybrid search capabilities
- Challenge 04: **[Security & Cost Optimization](./Solutions/Solution-04.md)**
  - Implement security best practices and cost-saving strategies

## Coach Prerequisites

Before coaching this hack, you should:

- Have experience with Azure Cosmos DB in production environments
- Understand NoSQL data modeling concepts and best practices
- Be familiar with AI/ML concepts, particularly vector embeddings and search
- Have hands-on experience with Azure OpenAI services
- Understand Azure security models and cost optimization strategies
- Be comfortable troubleshooting Azure services and application performance

## Azure Requirements

Coaches and students will need:

- Azure subscription with **Owner** rights
- Access to Azure OpenAI service
- Sufficient quota for:
  - GPT-4o: 30K tokens per minute
  - text-embedding-3-small: 5K tokens per minute
- Access to create Azure Cosmos DB accounts in multiple regions

## Suggested Hack Agenda

Join us for a full-day Azure Cosmos DB Hands-on Workshop designed to equip you with the skills to build scalable, high-performance, and cost-optimised applications. This workshop blends technical deep dives with guided labs covering data modelling, full text and vector search, and real-world cost optimisation strategies. You'll also explore the latest innovations in Cosmos DB, including its integration with Microsoft Fabric. Ideal for developers, architects, and data professionals looking to deepen their expertise with Cosmos DB.

- 📅 **PST:** 29-Oct-2025, 9:30 AM – 5:00 PM (PST)
- 🕤 **IST:** 31-Oct-2025, 9:30 AM – 5:00 PM (IST)
- 📍 **Location:** [[Teams Link to join, Common for both TZ]](https://aka.ms/cdbtrainingjoininfo)
- 🎯 **Audience:** Technical Architects, Developers, Data Engineers, and AI Practitioners
- 🧠 **Prerequisites:** Basic familiarity with NoSQL and Azure Portal

## Agenda

| Time           | Session Title & Description | Presentation
|----------------|----------------------------|--------------|
| **09:30 – 10:15** | **Kickoff & Azure Cosmos DB Overview**<br>Introduction to Cosmos DB’s architecture, global distribution, consistency model, use cases, AI, Full Text Search & Hybrid Search. Use cases in real-time analytics, IoT, and AI. |[Kickoff & Azure Cosmos DB Overview](Presentations/Kickoff%20&%20Overview.pptx)|
| **10:15 – 11:00** | **Hands-on Lab 1: Environment Setup**<br>Provision Cosmos DB accounts, configure indexing and partitioning, install SDKs (Node.js, .NET, Python), and validate access. |
| **11:00 – 12:30** | **Data Modelling & Optimization**<br>Deep dive into indexing policies, partitioning strategies, schema design, and query tuning. Learn to model for access patterns and avoid common anti-patterns. |[Cosmos DB Data Modeling & Optimization](Presentations/Cosmos%20DB%20Data%20Modeling%20&%20Optimization.pptx)|
| **12:30 – 01:00** | **Hands-on Lab 2: Data Modelling & Querying**<br>Design partitioned data models, write SQL queries, and analyse RU consumption. Use diagnostic logs to identify performance bottlenecks. |
| **01:00 – 01:30** | 🍽️ **Lunch Break** |
| **01:30 – 02:15** | **Developing AI Agents with Azure Cosmos DB**<br>Explore how to implement AI Agents, including Full Text Search, Vector Search, Hybrid Search using Azure Cosmos DB. Learn hybrid search patterns and use cases. |[Cosmos DB for AI](Presentations/CosmosDBForAI.pptx)|
| **02:15 – 03:15** | **Hands-on Lab 3: AI-Powered Search**<br>Build AI Agent based on Azure Cosmos DB, vectorise the data, create vector indexes, perform full text, vector and hybrid queries with & without filters. Also optimise the search, and evaluate the data modelling techniques with it. |
| **03:15 – 04:00** | **Security & Cost Optimisation**<br>Understand RBAC, private endpoints, encryption, and cost-saving strategies like autoscale, TTL, and indexing tuning. |[Azure CosmosDB Security](Presentations/Azure_CosmosDB_Security_Protection_CostOptimization.pptx)|
| **04:00 – 05:00** | **Hands-on Lab 4: Try out Security & Cost Optimisation techniques**<br>Apply cost-saving techniques in a live Cosmos DB environment. Use diagnostic tools to monitor RU usage, simulate autoscale, and optimise indexing policies. |
| **05:00 – 05:15** | **Latest Updates in Azure Cosmos DB + Wrap-up**<br>Explore recent feature releases (burst capacity, hierarchical partitioning, integrated vector indexing), recap key learnings, and open Q&A. |


## Coach Notes

### General Guidance

- Encourage students to work in teams of 3-5 people
- Each challenge builds on the previous one - ensure teams complete challenges in order
- Monitor Azure costs during the hack and help students clean up resources
- Be prepared to help with Azure OpenAI quota issues
- Have backup Azure subscriptions available if needed

### Common Challenges

1. **Azure OpenAI Access**: Some students may not have immediate access. Help them request access or provide temporary shared resources.

2. **Quota Limitations**: Azure OpenAI quota can be a bottleneck. Monitor usage and help students optimize their requests.

3. **Data Modeling Concepts**: Students may struggle with NoSQL thinking. Be ready to provide guidance on denormalization and embedding vs. referencing.

4. **Vector Search Understanding**: The concept of embeddings and similarity search may be new. Use analogies and visual explanations.

5. **Cost Optimization**: Help students understand the difference between provisioned and serverless throughput models.

### Key Teaching Points

- Emphasize the importance of understanding your data access patterns before designing your model
- Highlight the difference between RDBMS and NoSQL design approaches
- Explain how partition key choice affects performance and cost
- Demonstrate the power of combining different search types (full-text, vector, hybrid)
- Show real-world cost optimization techniques that can save significant money

## Repository Contents

- `./Coach`
  - Coach's Guide and related files
  - `/Solutions`
    - Solution files with completed example answers to each challenge
- `./Student`
  - Student's Challenge Guide
  - `/Resources`
    - Banking workshop application code
    - Infrastructure as Code templates
    - Sample data files
    - Presentation materials (provided to coaches for reference)

## Additional Resources

- [Azure Cosmos DB Documentation](https://docs.microsoft.com/azure/cosmos-db/)
- [Azure OpenAI Service Documentation](https://docs.microsoft.com/azure/cognitive-services/openai/)
- [Azure Developer CLI Documentation](https://docs.microsoft.com/azure/developer/azure-developer-cli/)
- [Cosmos DB Best Practices](https://docs.microsoft.com/azure/cosmos-db/sql/best-practice-nosql)
- [Vector Search in Cosmos DB](https://docs.microsoft.com/azure/cosmos-db/sql/vector-search)