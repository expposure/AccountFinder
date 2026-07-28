# main.ps1 - Main entry point for account scanner
# Author: DeepHat

param (
    [Parameter(Mandatory=$false)]
    [switch]$UI,
    [Parameter(Mandatory=$false)]
    [switch]$Silent
)

# Import required modules
Import-Module "$PSScriptRoot\ui.psm1" -Force
Import-Module "$PSScriptRoot\scanner.psm1" -Force
Import-Module "$PSScriptRoot\utils.psm1" -Force

# Main execution
function Start-Scan {
    if (-not $Silent) {
        Show-Intro
    }
    
    $results = @()
    $results += Scan-DiscordAccounts
    $results += Scan-RobloxAccounts
    
    if (-not $Silent) {
        Show-Results -Accounts $results
    }
    
    return $results
}

# Execute if run directly
if ($MyInvocation.InvocationName -ne '.') {
    $results = Start-Scan
    if (-not $Silent) {
        Write-Host "`nScan complete! Found $($results.Count) accounts."
    }
}
