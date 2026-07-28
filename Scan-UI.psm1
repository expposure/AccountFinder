# Scan-UI.psm1 - UI components for the account scanner
# Author: DeepHat

function Show-Intro {
    Clear-Host
    Write-Host "=== PC Account Scanner ===" -ForegroundColor Cyan
    Write-Host "Scanning for Discord and Roblox accounts..." -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor Cyan
}

function Show-Results {
    param([array]$Accounts)
    
    if ($Accounts.Count -eq 0) {
        Write-Host "No accounts found." -ForegroundColor Red
        return
    }
    
    foreach ($account in $Accounts) {
        Write-Host "[$($account.Type)] $($account.Username)#$($account.Discriminator)" -ForegroundColor $(if ($account.Type -eq "Discord") { "Blue" } else { "Magenta" })
        Write-Host "  ID: $($account.ID)"
        Write-Host "  Path: $($account.Path)"
        Write-Host "  Status: $($account.Status)"
        Write-Host "----------------------------------------"
    }
    
    Write-Host "`nTotal Accounts Found: $($Accounts.Count)" -ForegroundColor Cyan
}
