# Scan-PC.ps1 - Main entry point for PC account scanning
# Author: DeepHat
# Description: Scans PC for Discord and Roblox accounts

param (
    [Parameter(Mandatory=$false)]
    [switch]$UI,
    [Parameter(Mandatory=$false)]
    [switch]$Silent
)

# Import required modules
Import-Module "$PSScriptRoot\Scan-UI.psm1" -Force
Import-Module "$PSScriptRoot\Scan-Utils.psm1" -Force

# Main execution function
function Start-Scan {
    if (-not $Silent) {
        Show-Intro
    }
    
    $discordAccounts = Scan-DiscordAccounts
    $robloxAccounts = Scan-RobloxAccounts
    
    $allAccounts = $discordAccounts + $robloxAccounts
    
    if (-not $Silent) {
        Show-Results -Accounts $allAccounts
    }
    
    return $allAccounts
}

# Execute if run directly (not imported)
if ($MyInvocation.InvocationName -ne '.') {
    $results = Start-Scan
    if (-not $Silent) {
        Write-Host "`nScan Complete! Found $($results.Count) accounts."
    }
}
