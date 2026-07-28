# ui.psm1 - UI components
# Author: DeepHat

function Show-Intro {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "           Account Scanner" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Results {
    param([array]$Accounts)
    
    if ($Accounts.Count -eq 0) {
        Write-Host "No accounts found." -ForegroundColor Red
        return
    }
    
    foreach ($acc in $Accounts) {
        $typeColor = $(if ($acc.Type -eq "Discord") { "Blue" } else { "Magenta" })
        $statusColor = $(if ($acc.Status -eq "Found") { "Green" } else { "Red" })
        
        Write-Host "[$($acc.Type)] $($acc.Username)#$($acc.Discriminator)" -ForegroundColor $typeColor
        Write-Host "  ID: $($acc.ID)" -ForegroundColor Gray
        Write-Host "  Path: $($acc.Path)" -ForegroundColor Gray
        Write-Host "  Status: $($acc.Status)" -ForegroundColor $statusColor
        Write-Host "----------------------------------------"
    }
    
    Write-Host "`nTotal Accounts Found: $($Accounts.Count)" -ForegroundColor Cyan
}
