namespace CosmosPointReadDemo;

internal static class Program
{
    private static Task<int> Main(string[] args) => PointReadHelper.RunAsync(args);
}
