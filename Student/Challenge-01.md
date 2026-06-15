# Challenge 01 - Data Modeling & Query Optimization

**[< Previous Challenge](./Challenge-00.md)** - **[Home](../README.md)** - **[Next Challenge >](./Challenge-02.md)**

## Introduction

Understanding how to properly model data in Azure Cosmos DB is crucial for building high-performance, cost-effective applications. In this challenge, you'll learn how partition key choices, indexing policies, and query patterns dramatically impact both performance and cost.

Unlike relational databases, NoSQL databases like Cosmos DB require you to think differently about data modeling. You need to model your data based on how you plan to query it, not just on the relationships between entities.

## Description

You'll work with an e-commerce dataset containing customers, products, categories, tags, and sales orders. Through hands-on experimentation, you'll discover how different modeling decisions affect Request Unit (RU) consumption and query performance.

The goal is to understand the trade-offs between different partition key strategies and indexing policies by measuring actual RU consumption and latency for various query patterns.

You can find sample data documents in the `Challenge01/` folder of the under the `/Student/Resources` folder. 

**Please note for all the containers use Autoscale and specify 1000 RUs as upper bound**

Follow the steps as:
Step-1: Goto the browser you have opened in the previous lab and click on Azure Cosmos DB.
Step-2: Click on Data Explorer --> Click on New --> Container. Specify the Database name as lab01 so you can differentiate with other lab.
Step-3: Follow the steps as below
### Part 1: Container Design Experiments

- **Experiment A: Customers & Sales Orders Container**
  - Create a container named `customers` with `/id` as the partition key
  - Insert customer and sales order documents (use the provided sample data)
  - Run queries to retrieve a customer by ID and all sales orders for a customer
  - Record RU consumption and latency
  - Recreate the container with `/customerId` as the partition key and repeat
  - Compare the results and explain the differences

- **Experiment B: Products Container**
  - Create a container named `products` with `/categoryId` as the partition key
  - Insert product documents (use the provided sample data)
  - Run queries to list all products in a category and retrieve a product by ID
  - Record RU consumption and latency
  - Recreate the container with `/id` as the partition key and repeat
  - Compare the results and identify which approach works better for each query type

- **Experiment C: Product Metadata Container**
  - Create a container named `productMeta` with `/type` as the partition key
  - Insert category and tag documents (use the provided sample data)
  - Query all categories: `SELECT * FROM c WHERE c.type = 'category'`
  - Query all tags: `SELECT * FROM c WHERE c.type = 'tag'`
  - Record RU consumption and explain why this partition key choice works well

### Part 2: Indexing Policy Experiments

- Modify the indexing policy on one of your containers to exclude certain properties
- Run queries that both include and exclude those properties from the WHERE clause
- Measure the impact on RU consumption and performance
- Document your findings on when to include vs exclude properties from indexing

### Part 3: Query Pattern Analysis

- Create a table documenting RU charges and latency for different query types:
  - **Point Read:** Retrieve by ID with partition key
  - **Range Query:** Query multiple items within a partition
  - **Cross-Partition Query:** Query without partition key filter
  - **Aggregation Query:** Count or sum across partitions

- Run at least one example of each query type and record the results
- Identify which queries are most expensive and why

### Part 4: Analysis & Recommendations

- Document your findings and provide recommendations:
  - Which partition key strategy worked best for each container and why?
  - How did indexing changes affect performance and cost?
  - What anti-patterns did you observe (hot partitions, expensive cross-partition queries)?
  - What denormalization or data embedding strategies would you recommend?

## Success Criteria

To complete this challenge successfully, you should:

- Successfully create and test all three container designs with different partition keys, documenting RU consumption and latency differences
- Modify indexing policies and measure their impact on query performance and cost
- Execute and document at least one example of each query pattern type (point read, range query, cross-partition query, and aggregation)
- Provide a comprehensive analysis comparing partition key strategies, explaining which approach works best for different query patterns
- Identify performance anti-patterns and recommend denormalization or data embedding strategies based on your experimental results

## Learning Resources

- [Partitioning in Azure Cosmos DB](https://docs.microsoft.com/azure/cosmos-db/partitioning-overview)
- [Request Units in Azure Cosmos DB](https://docs.microsoft.com/azure/cosmos-db/request-units)
- [Indexing in Azure Cosmos DB](https://docs.microsoft.com/azure/cosmos-db/index-overview)
- [Data modeling in Azure Cosmos DB](https://docs.microsoft.com/azure/cosmos-db/modeling-data)
- [Query performance guidelines](https://docs.microsoft.com/azure/cosmos-db/sql-query-performance-guidelines)

## Tips

- Use the Azure portal's Data Explorer to run queries and see RU consumption
- Pay attention to the \"Request Charge\" value shown after each query
- Cross-partition queries are expensive - try to avoid them when possible
- Consider embedding related data when you frequently query them together
- Hot partitions occur when most traffic goes to a few partition key values
- Use the query execution statistics to understand performance bottlenecks

## Advanced Challenges (Optional)

- Implement hierarchical partition keys and compare with single-level partitioning
- Experiment with composite indexes for complex query patterns
- Use the Cosmos DB bulk executor to load larger datasets and observe behavior at scale
- Set up analytical store and compare query performance for analytical workloads

**[< Previous Challenge](./Challenge-00.md)** - **[Home](../README.md)** - **[Next Challenge >](./Challenge-02.md)**
