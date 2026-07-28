# run.ps1 - Launcher for the account scanner
# Author: DeepHat

# Set execution policy to bypass warnings
Set-ExecutionPolicy Bypass -Scope Process -Force

# Download and execute the scanner
$script = iwr "https://raw.githubusercontent.com/expposure/AccountFinder/main/main.ps1" -UseBasicParsing
Invoke-Expression $script.Content
