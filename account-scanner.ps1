# Single-File AccountFinder - Discord & Roblox Account Scanner
# Author: DeepHat
# Compatible with PowerShell 5.1

# Set execution policy to bypass warnings
Set-ExecutionPolicy Bypass -Scope Process -Force

# Define helper functions
function Format-Size {
    param([long]$Bytes)
    
    if ($Bytes -lt 1KB) { return "$Bytes B" }
    if ($Bytes -lt 1MB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    if ($Bytes -lt 1GB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    return "{0:N2} GB" -f ($Bytes / 1GB)
}

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

function Scan-DiscordAccounts {
    $accounts = @()
    
    # Discord paths
    $discordPaths = @(
        "$env:APPDATA\Discord",
        "$env:LOCALAPPDATA\Discord",
        "$env:USERPROFILE\AppData\Roaming\Discord",
        "$env:USERPROFILE\AppData\Local\Discord"
    )
    
    foreach ($path in $discordPaths) {
        if (Test-Path $path) {
            # Look for token files
            $tokenFiles = Get-ChildItem -Path $path -Filter "*.json" -Recurse -ErrorAction SilentlyContinue
            
            foreach ($file in $tokenFiles) {
                try {
                    $content = Get-Content $file.FullName -Raw
                    
                    if ($content -match '"token":"([^"]+)"') {
                        $token = $matches[1]
                        
                        # Extract user info from token
                        try {
                            $response = Invoke-WebRequest -Uri "https://discordapp.com/api/v6/users/@me" -Headers @{
                                "Authorization" = "Bot $token"
                            } -ErrorAction SilentlyContinue
                            
                            if ($response.StatusCode -eq 200) {
                                $userData = $response.Content | ConvertFrom-Json
                                $account = @{
                                    Type = "Discord"
                                    ID = $userData.id
                                    Username = $userData.username
                                    Discriminator = $userData.discriminator
                                    Token = $token
                                    Path = $file.FullName
                                    Status = "Found"
                                }
                                $accounts += $account
                            }
                        } catch {
                            # Still add unverified accounts
                            $account = @{
                                Type = "Discord"
                                ID = "Unknown"
                                Username = "Unknown"
                                Discriminator = "Unknown"
                                Token = $token
                                Path = $file.FullName
                                Status = "Unverified"
                            }
                            $accounts += $account
                        }
                    }
                } catch {
                    # Skip errors
                }
            }
        }
    }
    
    return $accounts
}

function Scan-RobloxAccounts {
    $accounts = @()
    
    # Roblox paths
    $robloxPaths = @(
        "$env:APPDATA\Roblox",
        "$env:LOCALAPPDATA\Roblox",
        "$env:USERPROFILE\AppData\Roaming\Roblox",
        "$env:USERPROFILE\AppData\Local\Roblox"
    )
    
    foreach ($path in $robloxPaths) {
        if (Test-Path $path) {
            # Check for auth cookies
            $authFile = Join-Path $path "Cookies" "auth.rbx"
            if (Test-Path $authFile) {
                $content = Get-Content $authFile -Raw
                
                if ($content -match '(\w{8}-\w{4}-\w{4}-\w{4}-\w{12})') {
                    $userId = $matches[1]
                    
                    $account = @{
                        Type = "Roblox"
                        ID = $userId
                        Username = "Unknown"
                        Discriminator = "Unknown"
                        Token = "Auth Cookie"
                        Path = $authFile
                        Status = "Found"
                    }
                    $accounts += $account
                }
            }
        }
    }
    
    return $accounts
}

# Main execution
Show-Intro
$results = @()
$results += Scan-DiscordAccounts
$results += Scan-RobloxAccounts
Show-Results -Accounts $results
Write-Host "`nScan complete! Found $($results.Count) accounts."
