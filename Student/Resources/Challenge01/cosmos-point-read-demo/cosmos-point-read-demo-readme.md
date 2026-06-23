# Cosmos DB Point Read Demo (.NET 8, RBAC)

A minimal .NET console app that performs a **point read** against Azure Cosmos DB
using **RBAC** (Microsoft Entra ID via `DefaultAzureCredential`) — no account keys.

A point read is `ReadItemAsync(id, partitionKey)`. It is the cheapest and fastest
read operation in Cosmos DB (~1 RU for a 1 KB document) because it bypasses the
query engine and goes directly to the single physical partition that owns the item.

## Target container

| Setting   | Value                                                |
|-----------|------------------------------------------------------|
| Endpoint  | `https://<your-account>.documents.azure.com:443/`    |
| Database  | `MultiAgentBanking`                                  |
| Container | `customers`                                          |
| PK path   | `/id` (id is the partition key)                      |

Sample document id used by default: `CUST001`.

> Update the values in `App.config` to point at your own Cosmos DB account,
> database, and container before running.

## Prerequisites

1. .NET 8 SDK.
2. Azure CLI signed in **as a user that has a Cosmos DB data-plane RBAC role** on this account:
   - `Cosmos DB Built-in Data Reader` (read-only) — sufficient for this demo, or
   - `Cosmos DB Built-in Data Contributor` (read/write).

   These are **data-plane** roles, distinct from control-plane `Reader`/`Contributor`.

   Example grant (run once, by an owner of the account):

   ```powershell
   $acct = "<your-account>"
   $rg   = "<resource-group>"
   $principalId = (az ad signed-in-user show --query id -o tsv)

   az cosmosdb sql role assignment create `
     --account-name $acct `
     --resource-group $rg `
     --scope "/" `
     --principal-id $principalId `
     --role-definition-id 00000000-0000-0000-0000-000000000001   # Data Reader
   ```

3. Sign in locally so `DefaultAzureCredential` can pick up your identity:

   ```powershell
   az login
   ```

## Run

```powershell
cd cosmos-point-read-demo
dotnet run                    # reads CUST001 (from App.config)
dotnet run -- CUST002         # override id from the command line
```

Expected output:

```
Azure Cosmos DB - Point Read demo (RBAC)
  Endpoint  : https://<your-account>.documents.azure.com:443/
  Database  : MultiAgentBanking
  Container : customers
  Item id   : CUST001
  PK value  : CUST001

Point read OK in 12.4 ms
RU charge  : 1.00
ETag       : "020039b0-0000-0200-0000-6a268b650000"
Status     : 200 OK

Document:
{
  "Id": "CUST001",
  "CustomerId": "CUST001",
  "Type": "customer",
  "FirstName": "Alice",
  ...
}
```

## Why this is a *point* read (not a query)

This calls `container.ReadItemAsync<T>(id, new PartitionKey(pk))`, which issues a
single `GET /dbs/.../colls/.../docs/{id}` with the `x-ms-documentdb-partitionkey`
header. Doing the same lookup as `SELECT * FROM c WHERE c.id = 'CUST001'`
would invoke the query engine, cost more RUs, and add latency.

Exit codes: `0` success, `2` not found, `3` other Cosmos error.
