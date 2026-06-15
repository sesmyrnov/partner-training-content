# Challenge 03 - Security & Cost Optimization

**[< Previous Challenge](./Challenge-02.md)** - **[Home](../README.md)**

## Introduction

Running Azure Cosmos DB in production requires careful attention to both security and cost optimization. In this final challenge, you'll implement security best practices, configure monitoring and alerting, and apply cost optimization techniques to ensure your Cosmos DB deployment is both secure and cost-effective.

Security in the cloud is a shared responsibility, and Cosmos DB provides multiple layers of protection. Cost optimization requires understanding how different configuration choices impact your monthly bill and implementing strategies to minimize unnecessary spending.

## Description

Using your existing banking application infrastructure, you'll enhance it with production-ready security controls and implement cost optimization strategies. You'll configure monitoring, set up alerts, test different throughput models, and apply security best practices.

This challenge simulates real-world scenarios where you need to balance performance, security, and cost while maintaining a great user experience.

## Success Criteria

To complete this challenge successfully, you should:

### Part 1: Monitoring and Performance Analysis

- **Enable Comprehensive Monitoring:**
  - Navigate to your Cosmos DB account's \"Insights\" section
  - Enable diagnostic logging and send logs to Log Analytics
  - Monitor RU consumption, latency, and throttling events

- **Create Test Workload and Measure Performance:**
  - Create a new container named `TransactionTest` with `/customerId` as partition key
  - Set initial throughput to 400 RU/s (manual mode)
  - Insert 1000+ sample transaction documents using the provided schema
  - Run different query patterns and record RU consumption:
    - Point read by transaction ID
    - Range query by customer ID
    - Cross-partition query by transaction category
    - Aggregation query (count transactions by category)

### Part 2: Autoscale Configuration and Testing

- **Switch to Autoscale:**
  - Change your container's throughput from manual to autoscale
  - Set maximum RU/s to 4000
  - Document the configuration change process

- **Simulate Variable Workload:**
  - Create a script or use Data Explorer to simulate high-load scenarios
  - Run batch inserts and concurrent queries to trigger autoscaling
  - Monitor how RU/s adjusts automatically in the Insights dashboard
  - Record the scaling behavior and timing

- **Cost Analysis:**
  - Use the Azure Cosmos DB Capacity Calculator to estimate costs
  - Compare estimated monthly costs for manual vs autoscale configurations
  - Document scenarios where each approach would be more cost-effective

### Part 3: Security Implementation

- **Configure Role-Based Access Control (RBAC):**
  - Navigate to \"Access control (IAM)\" in your Cosmos DB account
  - Create or assign the following roles:
    - \"Cosmos DB Operator\" for administrative access
    - \"Cosmos DB Built-in Data Reader\" for read-only access
    - \"Cosmos DB Built-in Data Contributor\" for read-write access
  - Test access with different role assignments

- **Network Security:**
  - Configure firewall rules to restrict access by IP address
  - Review private endpoint configuration options (document the process even if not implementing)
  - Understand the difference between public and private access

- **Encryption and Data Protection:**
  - Verify that encryption at rest is enabled (default setting)
  - Review customer-managed key options in the Encryption settings
  - Document the encryption capabilities and configuration options

### Part 4: Alerting and Cost Management

- **Configure Monitoring Alerts:**
  - Create an alert rule for high RU consumption (threshold: > 3000 RU/s for 5 minutes)
  - Set up notifications via email or SMS
  - Create an alert for throttling events
  - Test that alerts trigger properly during high-load scenarios

- **Implement Cost Optimization Best Practices:**
  - Review and optimize indexing policies (exclude rarely-queried properties)
  - Configure Time-to-Live (TTL) on appropriate containers to auto-delete old data
  - Implement efficient query patterns that avoid cross-partition operations
  - Document recommended query optimization techniques

### Part 5: Advanced Security and Optimization Analysis

- **Security Assessment:**
  - Document all security features currently enabled
  - Identify additional security measures for a production environment
  - Explain the security benefits of managed identity integration
  - Review audit logging capabilities

- **Cost Optimization Report:**
  - Create a report comparing different throughput strategies
  - Analyze the cost impact of different partition key choices
  - Document best practices for minimizing RU consumption
  - Provide recommendations for ongoing cost management

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