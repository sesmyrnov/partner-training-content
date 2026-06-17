# Challenge 03 - Monitoring, Autoscale, and Security in Azure Cosmos DB

**[< Previous Challenge](./Challenge-02.md)** - **[Home](../README.md)**

## Introduction

In this challenge, you'll monitor Request Unit (RU) usage, switch to autoscale throughput, simulate workloads, and apply security best practices in Azure Cosmos DB.

Security in the cloud is a shared responsibility, and Cosmos DB provides multiple layers of protection. Cost optimization requires understanding how different configuration choices impact your monthly bill and implementing strategies to minimize unnecessary spending.

## Description

You'll work with a `RetailBankingDB` database containing transaction data to understand real-world performance and cost optimization scenarios. Using your existing banking application infrastructure, you'll enhance it with production-ready security controls and implement cost optimization strategies.

This challenge simulates real-world scenarios where you need to balance performance, security, and cost while maintaining a great user experience.

### Part 1: Environment Setup and Data Loading

- **Create the RetailBankingDB Database and Transactions Container:**
  - Create a new Cosmos DB Account. Choose a unique name and region. 
  - Select “Provisioned throughput” and enable “Azure Cosmos DB for NoSQL API”
  - Create a new database called `RetailBankingDB` 
  - Create a container named `Transactions` with the partition key `/customerId`
  - Set initial throughput to manual mode with 400 RU/s 

- **Load Sample Transaction Data:**
  - Insert at least 1000 sample transaction documents using this schema:
    ```json
    {
      "transactionId": "TX123456789",
      "customerId": "CUST001", 
      "accountId": "ACC987654321",
      "amount": 250.75,
      "timestamp": "2024-06-01T10:15:00Z",
      "merchant": "Amazon",
      "category": "Shopping"
    }
    ```
  - Ensure variety in `customerId`, `accountId`, and `category` values for realistic testing
  - You can find sample pre-jenerated `transactions.json` in the `/Student/Resrouces/Challenge03/` folder.
  - Use `Data Explorer -> Container -> Item -> Upload Item -> load from JSON`

### Part 2: Query Analysis and RU Monitoring

- **Execute Queries:**
While file is loading, open a new Browser tab and navigate to `Cosmos DB Account ->  Data Exlorer -> New SQL Query`:
  - Run queries to retrieve transactions by customer ID (single partition)
  ```sql
  SELECT * FROM c WHERE c.customerId = "CUST001"
  ```
  - Run queries to retrieve transactions by account ID (potentially cross-partition)
  ```sql
  SELECT * FROM c WHERE c.accountId = "ACC987654321"
  ```
  - Run queries to retrieve transactions by category (cross-partition)
  ```sql
  SELECT * FROM c WHERE c.category = "Shopping"
  ```

- **Record Performance Metrics:**
  - For each query, note:
    - RU charge (from Query Metrics in Data Explorer)
    - Query latency in milliseconds
    - Observe Any throttling events 

- **Enable Comprehensive Monitoring:**
  - Navigate to your Cosmos DB account's "Monitoring" section
  - Click on `Insights` and browse through tabs to observe the metrics while both JSON bulk load and queries are processing
  - Monitor RU consumption, latency, and throttling graphs
  
### Part 3: Autoscale Configuration and Workload Simulation

- **Switch to Autoscale Throughput:**
  - Navigate to "Scale & Settings" in your Transactions container
  - Change from manual to autoscale mode
  - Set maximum RU/s to 4000 (starting minimum will be 400 RU/s)

- **Simulate Variable Banking Workloads:**
  - Monitor autoscaling behavior in the Insights dashboard to watch the RU/s usage graph
  - If the load already completed - restart the load or drop/re-create container.
  - Record how RU/s adjusts automatically and timing of scaling events as well as increased requests concurrency and throughput

### Part 4: Enterprise Security Implementation (optional)

- **Configure Role-Based Access Control (RBAC):**
  - Navigate to "Access control (IAM)" in your Cosmos DB account
  - Assign the following built-in role to your user or service principal
    - "Cosmos DB Operator" 
    - "Managed Identity Contributor"

- **Network Security Configuration:**
  - Configure firewall rules to restrict access by IP address ranges
  - Review private endpoint configuration options:
    - Document the process for creating a private endpoint
    - Explain benefits for applications with sensitive data
    - Understand VNet integration requirements
  - Configure service endpoint policies if applicable

- **Data Protection and Encryption:**
  - Verify that encryption at rest is enabled (should be the default setting)
  - Review customer-managed key (CMK) options:
    - Navigate to Encryption settings
    - Document the process for configuring CMK with Azure Key Vault
    - Explain compliance benefits for financial institutions
  - Understand encryption in transit capabilities

### Part 5: Alerting and Cost Management

- **Configure Monitoring Alerts for RU consumption spikes:** ( optional )
  - Navigate to "Alerts" under the Monitoring section
  - Create alert rules for:
    - High RU consumption (threshold: > 3000 RU/s for 5 minutes)
  - Configure action groups for email/SMS notifications
  - Test that alerts trigger properly during simulated high-load scenarios by re-loading sample generate JSON document with low manual 400 RU/s container to simulate throttling 429 errors.

- **Implement Cost Optimization Best Practices:**
  - **Indexing Policy Optimization:**
    - Review current indexing policy in your container
    - Identify properties that don't need indexing (exclude from index)
    - Check index metrics when executing different queries and configure composite indexes for common multi-property queries (optional)
    - Test query performance before and after indexing changes
  
  - **Time-to-Live (TTL) Configuration:**
    - Configure TTL on transaction documents (e.g., auto-delete after 7 years for compliance)
    - Test TTL functionality with sample documents
    - Calculate storage cost savings from automatic cleanup
  
  - **Query Optimization:**
    - Implement efficient query patterns that include partition key
    - Avoid SELECT * by specifying only needed fields
    - Use pagination for large result sets
    - Document recommended patterns for banking applications
  
- **Cost Analysis and Comparison:**
  - Use the [Azure Cosmos DB Capacity Calculator](https://cosmos.azure.com/capacitycalculator/)
  - Calculate estimated monthly costs for:
    - Manual throughput at 400 RU/s
    - Manual throughput at 4000 RU/s  
    - Autoscale with max 4000 RU/s
  - Document scenarios where each approach would be most cost-effective
  - Consider peak vs off-peak usage patterns typical in banking
  - Try New *Azure Cosmos DB Cost Estimator* to compare the experience: https://aka.ms/cosmoscost  


### Part 6: Advanced Security and Cost Analysis (optional)

- **Security Assessment and Compliance:**
  - Document all security features currently enabled
  - Create a security checklist for production banking environments:
    - Data encryption (at rest and in transit)
    - Network isolation and access controls
    - Audit logging and monitoring
    - Identity and access management
  - Research compliance features relevant to financial services (GDPR, PCI DSS)
  - Explain how managed identity integration enhances security

- **Comprehensive Cost Optimization Report:**
  - Compare total cost of ownership for different configurations:
    - Manual vs autoscale throughput strategies
    - Impact of partition key choices on cross-partition queries
    - Storage optimization through indexing and TTL
  - Create recommendations for ongoing cost management:
    - Regular monitoring and alerting procedures
    - Capacity planning for growth
    - Performance testing methodologies
  - Document best practices for minimizing RU consumption in banking applications

## Success Criteria

To complete this challenge successfully, you should demonstrate your understanding of Cosmos DB monitoring, autoscale, and security:

- Successfully create the `RetailBankingDB` database and `Transactions` container, load at least 1000 sample transaction documents with varied data
- Execute single-partition, potentially cross-partition, and cross-partition queries, recording RU charges, latency, and throttling metrics for each
- Enable diagnostic logging and monitoring, configure autoscale throughput (max 4000 RU/s), and successfully simulate workload scenarios that demonstrate autoscaling behavior
- (Optional) Configure RBAC roles, network security (firewall rules, private endpoint documentation), and document data protection mechanisms including encryption at rest and in transit
- Set up monitoring alerts for RU consumption spikes with proper action groups and implement cost optimization through indexing policy changes, TTL configuration, and query optimization
- Perform cost analysis comparing manual vs autoscale throughput strategies and document security features with a compliance-focused checklist for production banking environments

## Learning Resources

- [Security in Azure Cosmos DB](https://docs.microsoft.com/azure/cosmos-db/database-security)
- [Cost optimization in Azure Cosmos DB](https://docs.microsoft.com/azure/cosmos-db/plan-manage-costs)
- [Monitoring Azure Cosmos DB](https://docs.microsoft.com/azure/cosmos-db/monitor-cosmos-db)
- [Autoscale in Azure Cosmos DB](https://docs.microsoft.com/azure/cosmos-db/provision-throughput-autoscale)
- [Azure Cosmos DB pricing](https://azure.microsoft.com/pricing/details/cosmos-db/)

## Tips

- Use the Azure Pricing Calculator to model different scenarios before implementing changes
- Monitor costs closely during testing to avoid unexpected charges
- Autoscale is most beneficial for workloads with unpredictable traffic patterns
- Cross-partition queries can be expensive - always include partition key in filters when possible
- TTL can significantly reduce storage costs by automatically cleaning up old data
- Network restrictions should be tested carefully to avoid blocking legitimate access

## Advanced Challenges (Optional)

- **Multi-Region Setup:** Configure global distribution and analyze the cost implications
- **Backup and Restore:** Test backup configurations and restore procedures
- **Advanced Monitoring:** Create custom dashboards and KQL queries for operational insights
- **Performance Benchmarking:** Use tools like Azure Cosmos DB Emulator to benchmark different configurations
- **Compliance Configuration:** Research and document compliance features (GDPR, HIPAA, etc.)

## Troubleshooting

- If autoscale doesn't trigger, ensure you're generating sufficient load consistently
- Monitor the Azure Service Health dashboard for any service issues
- Check that RBAC roles are properly assigned if access issues occur
- Verify firewall rules if connection problems arise
- Use the Activity Log to troubleshoot configuration changes

## Clean Up

After completing this challenge:
- Delete any test containers created during the exercises
- Review and clean up any unnecessary alert rules
- Consider preserving the main banking application for future reference
- Document lessons learned and best practices discovered

**[< Previous Challenge](./Challenge-03.md)** - **[Home](../README.md)**