# Ensure the script knows its own path for restarting with elevated privileges
$scriptPath = $MyInvocation.MyCommand.Definition

# Title text
$Title001 = "                          SS:KTJL EAC Manager (by engels74)"
$Title002 = "                    https://github.com/engels74/ssktjl-eac-script"

# Description text
$Description001 = @"
    EasyAntiCheat Management for 'Suicide Squad: Kill the Justice League'.
    This script helps remove EasyAntiCheat before running SS:KTJL.
    It makes it easier to use trainers for the game (e.g., the CheatHappens trainer).

    If SS:KTJL tells you it needs to use Steam in Online Mode, you need
    to open the game first normally, close it, and then re-open this script.
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

# Check if running as Administrator
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")

if (-not $IsAdmin) {
    # Display Titles
    Write-Host $Title001 -ForegroundColor Cyan
    Write-Host $Title002 -ForegroundColor Cyan
    Write-Host "" # Empty line for better readability

    # User Prompt
    $UserChoice = Read-Host "       This script requires administrative privileges to function properly. `n    Press Y to attempt to restart it with elevated privileges, or press any other key to exit"
    if ($UserChoice -ne 'Y') {
        Write-Host "Exiting script..." -ForegroundColor Yellow
        exit
    }

    # Try to elevate privileges and immediately exit the current, non-elevated script instance
    try {
        Start-Process PowerShell -ArgumentList "-File `"$scriptPath`"" -Verb RunAs
        exit # Ensure to exit after launching the elevated instance
    } catch {
        $commandToRun = "PowerShell -File '$scriptPath'"
        Write-Host "`nFailed to elevate privileges automatically." -ForegroundColor Red
        Write-Host "`nTo run the script with administrative privileges manually, follow these steps:" -ForegroundColor Yellow
        Write-Host "1. Open Start, search for PowerShell, right-click it, and select 'Run as Administrator'." -ForegroundColor Green
        Write-Host "2. The command has been copied to your clipboard. Right-click and select 'Paste' in the PowerShell window to run it." -ForegroundColor Green
        Write-Host "If copying did not work, type the following command and press Enter:" -ForegroundColor Green
        Write-Host "`n    $commandToRun" -ForegroundColor White
        $commandToRun | Set-Clipboard # Copy command to clipboard
        Write-Host "`nThe command to run this script with administrative privileges has been copied to your clipboard." -ForegroundColor Yellow
        Write-Host "Please open a new PowerShell window as an Administrator, right-click to paste the command, and press Enter to run it." -ForegroundColor Green
        
        # Wait for user to acknowledge the message
        Write-Host "`nPress any key to exit..." -ForegroundColor White
        $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        exit
    }
} else {
    Write-Host "Running with administrative privileges."
}

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
    Write-Host "`nThe game is currently running. Please close the game before proceeding." -ForegroundColor Red
    Pause
    Exit
}

# Remove contents of the EasyAntiCheat folder in %appdata%
$eacFolderPath = "$env:appdata\EasyAntiCheat"
Write-Host "`n    Removing contents of the EasyAntiCheat folder..." -ForegroundColor White
If (Test-Path $eacFolderPath) {
    Get-ChildItem -Path $eacFolderPath -Recurse | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

# Move EasyAntiCheat_EOS.sys file to temporary location
$eacSysPath = "C:\Program Files (x86)\EasyAntiCheat_EOS\EasyAntiCheat_EOS.sys"
$eacSysBackupPath = "$TempFolder\EasyAntiCheat_EOS.sys"
Write-Host "`n    Checking and moving EasyAntiCheat_EOS.sys to temporary location..." -ForegroundColor White
If (Test-Path $eacSysPath) {
    Move-Item $eacSysPath $eacSysBackupPath -Force
    Write-Host "    Moved EasyAntiCheat_EOS.sys to temporary location." -ForegroundColor Green
} else {
    Write-Host "    EasyAntiCheat_EOS.sys file not found, skipping..." -ForegroundColor Red
}

# Request to press SPACE before disabling internet
Write-Host "`n    Press SPACE to temporarily disable all internet connections and continue..." -ForegroundColor Yellow
do {
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} until ($key.VirtualKeyCode -eq 32)

# Disabling network adapters
try {
    Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Disable-NetAdapter -Confirm:$false -ErrorAction Stop
    Write-Host "`n    Network adapters disabled successfully." -ForegroundColor Green
} catch {
    Write-Host "`n    Error disabling network adapters: $_" -ForegroundColor Red
}

# Wait for 3 seconds before launching the game
Write-Host "`n    Pausing the script for a moment..." -ForegroundColor White
Start-Sleep -Seconds 3

# Start the game using steam protocol
Write-Host "`n    Starting the game..." -ForegroundColor White
Start-Process "steam://rungameid/315210"

# Initialize a loop to check for 'SuicideSquad_KTJL.exe'
Write-Host "`n    Checking for Suicide Squad to start..." -ForegroundColor White
$processFound = $false
while (-not $processFound) {
    # Check if 'SuicideSquad_KTJL.exe' is running
    $processFound = Get-Process SuicideSquad_KTJL -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1  # Check every second
}

# Once the process is found, wait for 1 more second
Write-Host "`n    Pausing the script for a moment..." -ForegroundColor White
Start-Sleep -Seconds 1

# Enabling network adapters
try {
    Get-NetAdapter | Where-Object { $_.Status -eq "Disabled" } | Enable-NetAdapter -Confirm:$false -ErrorAction Stop
    Write-Host "`n    Network adapters enabled successfully." -ForegroundColor Green
} catch {
    Write-Host "`n    Error enabling network adapters: $_" -ForegroundColor Red
}

# Move EasyAntiCheat_EOS.sys file back to original location
try {
    If (Test-Path $eacSysBackupPath) {
        Move-Item $eacSysBackupPath $eacSysPath -Force -ErrorAction Stop
        Write-Host "`n    EasyAntiCheat_EOS.sys file moved back to original location successfully." -ForegroundColor Green
    } else {
        Write-Host "`n    EasyAntiCheat_EOS.sys backup file not found, skipping move operation." -ForegroundColor Yellow
    }
} catch {
    Write-Host "`n    Error moving EasyAntiCheat_EOS.sys file: $_" -ForegroundColor Red
}

Write-Host "`n    Done! EasyAntiCheat has been reinstated." -ForegroundColor Green

# Countdown before closing
$seconds = 30
while ($seconds -gt 0) {
    Write-Host "    The script will close in $seconds seconds..." -ForegroundColor White
    Start-Sleep -Seconds 1
    $seconds--
}

# Exit the PowerShell session
exit
