# run-local.ps1 - Downloads and runs the account scanner locally
# Author: DeepHat

# Define the base URL for the repository
$repoUrl = "https://raw.githubusercontent.com/expposure/AccountFinder/main"

# Create temp directory
$tempDir = Join-Path $env:TEMP "AccountFinder"
New-Item -Path $tempDir -ItemType Directory -Force > $null

# Download all necessary files
$files = @(
    "main.ps1",
    "ui.psm1", 
    "scanner.psm1",
    "utils.psm1"
)

foreach ($file in $files) {
    $url = "$repoUrl/$file"
    $filePath = Join-Path $tempDir $file
    
    try {
        Write-Host "Downloading $file..."
        $content = iwr $url -UseBasicParsing
        $content.Content | Out-File -FilePath $filePath -Encoding UTF8
    } catch {
        $errorMessage = $_.Exception.Message
        Write-Host "Failed to download $file: $errorMessage" -ForegroundColor Red
        exit 1
    }
}

# Import the modules
Import-Module "$tempDir\ui.psm1" -Force
Import-Module "$tempDir\scanner.psm1" -Force
Import-Module "$tempDir\utils.psm1" -Force

# Execute the main script
& "$tempDir\main.ps1"

# Cleanup
Remove-Item -Path $tempDir -Recurse -Force > $null
Write-Host "Cleanup complete."
