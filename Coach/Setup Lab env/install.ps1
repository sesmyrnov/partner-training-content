# Force TLS 1.2 for all downloads (fixes GitHub connection errors)

param(
    [Parameter(Mandatory=$true)][string]$CosmosDBConnectionString,
    [Parameter(Mandatory=$true)][string]$OpenAIConnectionInfo
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "STEP 1: Downloading VS Code"
Invoke-WebRequest -Uri "https://aka.ms/win32-x64-user-stable" -OutFile "$env:TEMP\vscode.exe" -UseBasicParsing
Write-Host "STEP 1 DONE"

Write-Host "STEP 2: Installing VS Code"
Start-Process "$env:TEMP\vscode.exe" -ArgumentList "/VERYSILENT","/NORESTART","/MERGETASKS=!runcode,desktopicon,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath" -Wait
Write-Host "STEP 2 DONE"

Write-Host "STEP 2a: Verifying VS Code"
if (Test-Path "C:\Program Files\Microsoft VS Code\Code.exe") {
    Write-Host "STEP 2a DONE: VS Code installed at C:\Program Files\Microsoft VS Code\"
} else {
    Write-Host "STEP 2a FAILED: VS Code not found"
}


Write-Host "STEP 3: Fetching latest Git release info"
$gitApi = Invoke-RestMethod -Uri "https://api.github.com/repos/git-for-windows/git/releases/latest" -UseBasicParsing
$gitUrl = ($gitApi.assets | Where-Object { $_.name -match "Git-.*-64-bit\.exe$" }).browser_download_url
Write-Host "Found Git URL: $gitUrl"
Invoke-WebRequest -Uri $gitUrl -OutFile "$env:TEMP\git.exe" -UseBasicParsing
Write-Host "STEP 3 DONE"

Write-Host "STEP 4: Installing Git"
Start-Process "$env:TEMP\git.exe" -ArgumentList "/VERYSILENT","/NORESTART","/SUPPRESSMSGBOXES" -Wait
Write-Host "STEP 4 DONE"

Write-Host "STEP 5: Updating PATH"
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
Write-Host "STEP 5 DONE"

Write-Host "STEP 6: Creating Workspace"
New-Item -ItemType Directory -Force -Path "C:\Labs" | Out-Null
Write-Host "STEP 6 DONE"

Write-Host "STEP 7: Cloning Repo"
$gitExe = "C:\Program Files\Git\bin\git.exe"
if (Test-Path $gitExe) {
    & $gitExe clone https://github.com/AzureCosmosDB/partner-training-content.git C:\Labs\partner-training-content
    Write-Host "STEP 7 DONE"
} else {
    Write-Host "STEP 7 FAILED: git.exe not found at $gitExe"
}

Write-Host "STEP 8: Validating"
if (Test-Path "C:\Labs\partner-training-content\.git") {
    Write-Host "STEP 8 DONE: Repo verified at C:\Labs\partner-training-content"
} else {
    Write-Host "STEP 8 FAILED: Repo not found"
}


Write-Host "STEP 4: Creating Cosmos DB connection string file on Public Desktop"
$desktopPath = "C:\Labs"
$cdbFile = Join-Path $desktopPath "cdbConnectionString.txt"
Set-Content -Path $cdbFile -Value $CosmosDBConnectionString -Encoding UTF8 -Force
if (Test-Path $cdbFile) {
    Write-Host "STEP 4 DONE: $cdbFile created"
} else {
    Write-Host "STEP 4 FAILED"
}

Write-Host "STEP 5: Creating OpenAI connection info file on Public Desktop"
$oaiFile = Join-Path $desktopPath "oAIConnectionString.txt"
Set-Content -Path $oaiFile -Value $OpenAIConnectionInfo -Encoding UTF8 -Force
if (Test-Path $oaiFile) {
    Write-Host "STEP 5 DONE: $oaiFile created"
} else {
    Write-Host "STEP 5 FAILED"
}


Write-Host "ALL STEPS COMPLETED"
