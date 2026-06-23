using System.Configuration;
using System.Diagnostics;
using System.Net;
using System.Text.Json;
using Azure.Core;
using Azure.Identity;
using Microsoft.Azure.Cosmos;

namespace CosmosPointReadDemo;

internal static class PointReadHelper
{
    public static async Task<int> RunAsync(string[] args)
    {
        PointReadSettings settings = PointReadSettings.Load();
        string itemId = args.FirstOrDefault(a => !string.IsNullOrWhiteSpace(a)) ?? settings.ItemId;
        string partitionKeyValue = string.IsNullOrWhiteSpace(settings.PartitionKeyValue)
            ? itemId
            : settings.PartitionKeyValue;

        Console.WriteLine("Azure Cosmos DB - Point Read demo (RBAC)");
        Console.WriteLine($"  Endpoint  : {settings.AccountEndpoint}");
        Console.WriteLine($"  Database  : {settings.Database}");
        Console.WriteLine($"  Container : {settings.Container}");
        Console.WriteLine($"  Item id   : {itemId}");
        Console.WriteLine($"  PK value  : {partitionKeyValue}");
        Console.WriteLine();

        TokenCredential credential = BuildCredential(settings.TenantId, settings.ManagedIdentityClientId);
        CosmosClientOptions clientOptions = new()
        {
            ApplicationName = "CosmosPointReadDemo",
            ConnectionMode = ConnectionMode.Direct
        };

        using CosmosClient client = new(settings.AccountEndpoint, credential, clientOptions);
        Container container = client.GetContainer(settings.Database, settings.Container);

        try
        {
            Stopwatch stopwatch = Stopwatch.StartNew();
            using ResponseMessage response = await container.ReadItemStreamAsync(
                itemId,
                new PartitionKey(partitionKeyValue));
            stopwatch.Stop();

            if (response.StatusCode == HttpStatusCode.NotFound)
            {
                Console.Error.WriteLine($"Item '{itemId}' was not found in partition '{partitionKeyValue}'.");
                return 2;
            }

            response.EnsureSuccessStatusCode();

            using JsonDocument document = await JsonDocument.ParseAsync(response.Content);
            string formattedJson = JsonSerializer.Serialize(document.RootElement, new JsonSerializerOptions
            {
                WriteIndented = true
            });

            Console.WriteLine($"Point read OK in {stopwatch.Elapsed.TotalMilliseconds:F1} ms");
            Console.WriteLine($"RU charge  : {response.Headers.RequestCharge:F2}");
            Console.WriteLine($"ETag       : {response.Headers.ETag}");
            Console.WriteLine($"Status     : {(int)response.StatusCode} {response.StatusCode}");
            Console.WriteLine();
            Console.WriteLine("Document:");
            Console.WriteLine(formattedJson);
            return 0;
        }
        catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
        {
            Console.Error.WriteLine($"Item '{itemId}' was not found in partition '{partitionKeyValue}'.");
            return 2;
        }
        catch (CosmosException ex)
        {
            Console.Error.WriteLine($"Cosmos DB error: {(int)ex.StatusCode} {ex.StatusCode}");
            Console.Error.WriteLine(ex.Message);
            return 3;
        }
    }

    private static TokenCredential BuildCredential(string? tenantId, string? managedIdentityClientId)
    {
        DefaultAzureCredentialOptions options = new()
        {
            ExcludeInteractiveBrowserCredential = false
        };

        if (!string.IsNullOrWhiteSpace(tenantId))
        {
            options.TenantId = tenantId;
        }

        if (!string.IsNullOrWhiteSpace(managedIdentityClientId))
        {
            options.ManagedIdentityClientId = managedIdentityClientId;
        }

        return new DefaultAzureCredential(options);
    }
}

internal sealed class PointReadSettings
{
    public required string AccountEndpoint { get; init; }
    public required string Database { get; init; }
    public required string Container { get; init; }
    public required string ItemId { get; init; }
    public string? PartitionKeyValue { get; init; }
    public string? TenantId { get; init; }
    public string? ManagedIdentityClientId { get; init; }

    public static PointReadSettings Load()
    {
        return new PointReadSettings
        {
            AccountEndpoint = RequireSetting("CosmosAccountEndpoint"),
            Database = RequireSetting("CosmosDatabase"),
            Container = RequireSetting("CosmosContainer"),
            ItemId = RequireSetting("CosmosItemId"),
            PartitionKeyValue = ReadOptionalSetting("CosmosPartitionKeyValue"),
            TenantId = ReadOptionalSetting("CosmosTenantId"),
            ManagedIdentityClientId = ReadOptionalSetting("CosmosManagedIdentityClientId")
        };
    }

    private static string RequireSetting(string key)
    {
        string? value = ConfigurationManager.AppSettings[key];
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new InvalidOperationException($"App setting '{key}' is required.");
        }

        return value;
    }

    private static string? ReadOptionalSetting(string key)
    {
        string? value = ConfigurationManager.AppSettings[key];
        return string.IsNullOrWhiteSpace(value) ? null : value;
    }
}
