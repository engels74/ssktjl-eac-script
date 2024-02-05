# Center text function
function Center-Text($text) {
    $consoleWidth = $host.UI.RawUI.WindowSize.Width
    $lines = $text -split "`n"
    foreach ($line in $lines) {
        $padding = ($consoleWidth - $line.Length) / 2
        $centeredLine = " " * [Math]::Floor($padding) + $line
        Write-Host $centeredLine -ForegroundColor White
    }
}

# Title text
$Title001 = "                          SS:KTJL EAC Manager (by engels74)"
$Title002 = "                    https://github.com/engels74/ssktjl-eac-script"

# Description text
$Description001 = @"
    EasyAntiCheat Management for 'Suicide Squad: Kill the Justice League'.
    This script helps remove EasyAntiCheat before running SS:KTJL.
    It makes it easier to use trainers for the game (e.g., the CheatHappens trainer).
"@

$Description002 = @"
    When selecting Option 1, the script will:
    - Launch a PowerShell in Administrator mode (it's needed to move EAC files)
    - Remove/move EAC files temporarily
    - Disable internet (when prompted with SPACE)
    - Launch SS:KTJL
    - Re-enable internet, as soon as SS:KTJL is detected
    - Reinstate EAC for the next launch
"@

# Main Menu
do {
    Clear-Host
    Write-Host $Title001 -ForegroundColor Green
    Write-Host $Title002 -ForegroundColor White
    Write-Host ""
    Write-Host $Description001 -ForegroundColor White
    Write-Host ""
    Write-Host ""
    Write-Host $Description002 -ForegroundColor White
    Write-Host ""
    Write-Host ""
    
    # Display menu options
    Write-Host "    Select an option:" -ForegroundColor White
    Write-Host "    [1] Run Script" -ForegroundColor White
    Write-Host ""

    # Read user choice
    $choice = Read-Host "Enter the number of your choice and press ENTER"

    # Check if the choice is valid
    if ($choice -eq '1') {
        Write-Host "    Option 1 selected. Script will proceed..." -ForegroundColor White
        break # Exit the loop after successful choice
    } else {
        Write-Host "    Invalid option, please try again." -ForegroundColor White
    }
} while ($true)

# Check for admin privileges and prompt for them if not present
$scriptPath = $MyInvocation.MyCommand.Path
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "    Requesting administrative privileges..." -ForegroundColor Yellow
    Start-Process PowerShell -ArgumentList "-File `"$scriptPath`"" -Verb RunAs
    Exit
}

# Set the base directory to the script's location
Push-Location
Set-Location -Path (Split-Path -Path $scriptPath -Parent)

# Choose the base location of 'Suicide Squad Kill the Justice League'
do {
    Write-Host "    Select the base location of 'Suicide Squad Kill the Justice League':" -ForegroundColor White
    Write-Host "    1. C:\Program Files (x86)\Steam\steamapps\common\Suicide Squad Kill the Justice League" -ForegroundColor Yellow
    Write-Host "    2. D:\SteamLibrary\steamapps\common\Suicide Squad Kill the Justice League" -ForegroundColor Yellow
    Write-Host "    3. Enter your own path" -ForegroundColor Green
    $choice = Read-Host "Type the number of your choice and press ENTER"
    
    switch ($choice) {
        "1" {
            $baseGamePath = "C:\Program Files (x86)\Steam\steamapps\common\Suicide Squad Kill the Justice League"
            break
        }
        "2" {
            $baseGamePath = "D:\SteamLibrary\steamapps\common\Suicide Squad Kill the Justice League"
            break
        }
        "3" {
            $baseGamePath = Read-Host "Enter the path to your game installation"
            break
        }
        default {
            Write-Host "Invalid option, please try again." -ForegroundColor White
        }
    }
} while (!$baseGamePath)

# Search for SuicideSquad_KTJL.exe in the baseGamePath and its subdirectories
$GameExePath = Get-ChildItem -Path $baseGamePath -Recurse -Filter "SuicideSquad_KTJL.exe" | Select-Object -First 1 -ExpandProperty FullName

# Validate GameExePath
If (!$GameExePath) {
    Write-Host "The file 'SuicideSquad_KTJL.exe' could not be found. Please run the script again and enter a valid path." -ForegroundColor Red
    Exit
}

# Choose the temporary folder for storing EasyAntiCheat files
do {
    Write-Host "    Select the temporary folder for storing EasyAntiCheat files:" -ForegroundColor White
    Write-Host "    1. C:\Users\$env:USERNAME\Documents\Aurora\tmpEAC" -ForegroundColor Yellow
    Write-Host "    2. Enter your own path" -ForegroundColor Green
    $choice = Read-Host "   Type the number of your choice and press ENTER"
    
    switch ($choice) {
        "1" {
            $TempFolder = "C:\Users\$env:USERNAME\Documents\Aurora\tmpEAC"
            break
        }
        "2" {
            $TempFolder = Read-Host "Enter your own path for the temporary folder"
            break
        }
        default {
            Write-Host "Invalid option, please try again." -ForegroundColor Red
        }
    }
} while (!$TempFolder)

# Ensure the temporary directory exists
If (-not (Test-Path $TempFolder)) {
    New-Item -ItemType Directory -Path $TempFolder
}

# Check if the game is running
If (Get-Process "SuicideSquad_KTJL" -ErrorAction SilentlyContinue) {
    Write-Host "The game is currently running. Please close the game before proceeding." -ForegroundColor Red
    Pause
    Exit
}

# Remove contents of the EasyAntiCheat folder in %appdata%
$eacFolderPath = "$env:appdata\EasyAntiCheat"
Write-Host "    Removing contents of the EasyAntiCheat folder..." -ForegroundColor White
If (Test-Path $eacFolderPath) {
    Get-ChildItem -Path $eacFolderPath -Recurse | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

# Move EasyAntiCheat_EOS.sys file to temporary location
$eacSysPath = "C:\Program Files (x86)\EasyAntiCheat_EOS\EasyAntiCheat_EOS.sys"
$eacSysBackupPath = "$TempFolder\EasyAntiCheat_EOS.sys"
Write-Host "    Checking and moving EasyAntiCheat_EOS.sys to temporary location..." -ForegroundColor White
If (Test-Path $eacSysPath) {
    Move-Item $eacSysPath $eacSysBackupPath -Force
    Write-Host "    Moved EasyAntiCheat_EOS.sys to temporary location." -ForegroundColor White
} else {
    Write-Host "    EasyAntiCheat_EOS.sys file not found, skipping..." -ForegroundColor Red
}

# Request to press SPACE before disabling internet
Write-Host "    Press SPACE to temporarily disable all internet connections and continue..." -ForegroundColor Yellow
do {
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} until ($key.VirtualKeyCode -eq 32)

# Temporarily disable all internet connections (Ethernet and WiFi)
Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Disable-NetAdapter -Confirm:$false

# Wait for 3 seconds before launching the game
Write-Host "    Pausing the script for a moment..." -ForegroundColor White
Start-Sleep -Seconds 3

# Start the game using steam protocol
Write-Host "    Starting the game..." -ForegroundColor White
Start-Process "steam://rungameid/315210"

# Initialize a loop to check for 'SuicideSquad_KTJL.exe'
Write-Host "    Checking for Suicide Squad to start..." -ForegroundColor White
$processFound = $false
while (-not $processFound) {
    # Check if 'SuicideSquad_KTJL.exe' is running
    $processFound = Get-Process SuicideSquad_KTJL -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1  # Check every second
}

# Once the process is found, wait for 1 more second
Write-Host "    Pausing the script for a moment..." -ForegroundColor White
Start-Sleep -Seconds 1

# Enable all previously disabled internet connections
Write-Host "    Enabling the internet again..." -ForegroundColor Green
Get-NetAdapter | Where-Object { $_.Status -eq "Disabled" } | Enable-NetAdapter -Confirm:$false

# Move EasyAntiCheat_EOS.sys file back to original location
Write-Host "    Moving EasyAntiCheat_EOS.sys file back to original location..." -ForegroundColor White
If (Test-Path $eacSysBackupPath) {
    Move-Item $eacSysBackupPath $eacSysPath -Force
    Write-Host "    Moved EasyAntiCheat_EOS.sys file back to original location." -ForegroundColor White
} else {
    Write-Host "    EasyAntiCheat_EOS.sys backup file not found, skipping..." -ForegroundColor White
}

Write-Host "    Done! EasyAntiCheat has been reinstated." -ForegroundColor Green

# Countdown before closing
$seconds = 30
while ($seconds -gt 0) {
    Write-Host "    The script will close in $seconds seconds..." -ForegroundColor White
    Start-Sleep -Seconds 1
    $seconds--
}

# Exit the PowerShell session
exit
