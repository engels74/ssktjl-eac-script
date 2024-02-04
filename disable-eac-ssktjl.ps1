# Main Menu
Clear-Host
Write-Host "SS:KTJL" -ForegroundColor Cyan
Write-Host "EasyAntiCheat Management for 'Suicide Squad: Kill the Justice League'"
Write-Host "This script helps manage EasyAntiCheat files and ensures a smooth gaming experience."
Write-Host ""

# Display menu options
Write-Host "Select an option:"
Write-Host "[1] Begin Script"
Write-Host "[2] Placeholder Option"
Write-Host ""

# Read user choice
$choice = Read-Host "Enter the number of your choice and press ENTER"

Switch ($choice) {
    "1" {
        # Check for admin privileges and prompt for them if not present
        $scriptPath = $MyInvocation.MyCommand.Path
        If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Host "Requesting administrative privileges..."
            Start-Process PowerShell -ArgumentList "-File `"$scriptPath`"" -Verb RunAs
            Exit
        }

        # Set the base directory to the script's location
        Push-Location
        Set-Location -Path (Split-Path -Path $scriptPath -Parent)

        # Choose GameExePath and search for SuicideSquad_KTJL.exe
        Write-Host "Select the base location of 'Suicide Squad Kill the Justice League':"
        Write-Host "1. C:\Program Files (x86)\Steam\steamapps\common\Suicide Squad Kill the Justice League"
        Write-Host "2. D:\SteamLibrary\steamapps\common\Suicide Squad Kill the Justice League"
        Write-Host "3. Enter your own path"
        $choice = Read-Host "Type the number of your choice and press ENTER"
        $baseGamePath = $null
        switch ($choice) {
            "1" { $baseGamePath = "C:\Program Files (x86)\Steam\steamapps\common\Suicide Squad Kill the Justice League" }
            "2" { $baseGamePath = "D:\SteamLibrary\steamapps\common\Suicide Squad Kill the Justice League" }
            "3" { $baseGamePath = Read-Host "Please enter the base path to the 'Suicide Squad Kill the Justice League' folder" }
        }

        # Search for SuicideSquad_KTJL.exe in the baseGamePath and its subdirectories
        $GameExePath = Get-ChildItem -Path $baseGamePath -Recurse -Filter "SuicideSquad_KTJL.exe" | Select-Object -First 1 -ExpandProperty FullName

        # Validate GameExePath
        If (!$GameExePath) {
            Write-Host "The file 'SuicideSquad_KTJL.exe' could not be found. Please run the script again and enter a valid path."
            Exit
        }

        # Choose TempFolder
        Write-Host "Select the temporary folder for storing EasyAntiCheat files:"
        Write-Host "1. C:\Users\$env:USERNAME\Documents\Aurora\tmpEAC"
        Write-Host "2. Enter your own path"
        $choice = Read-Host "Type the number of your choice and press ENTER"
        switch ($choice) {
            "1" {
                $TempFolder = "C:\Users\$env:USERNAME\Documents\Aurora\tmpEAC"
                If (!(Test-Path $TempFolder)) {
                    New-Item -ItemType Directory -Path $TempFolder
                }
            }
            "2" {
                $TempFolder = Read-Host "Please enter the full path for the temporary folder"
            }
        }

        # Check if the game is running
        If (Get-Process "SuicideSquad_KTJL" -ErrorAction SilentlyContinue) {
            Write-Host "The game is currently running. Please close the game before proceeding."
            Pause
            Exit
        }

        # Move EasyAntiCheat files
        $eacFolderPath = "$env:appdata\EasyAntiCheat"
        $eacSysPath = "C:\Program Files (x86)\EasyAntiCheat_EOS\EasyAntiCheat_EOS.sys"
        $eacBackupPath = "$TempFolder\EasyAntiCheat_Backup"
        $eacSysBackupPath = "$TempFolder\EasyAntiCheat_EOS.sys"

        Write-Host "Checking and moving EasyAntiCheat files to temporary location..."

        If (Test-Path $eacFolderPath) {
            Move-Item $eacFolderPath $eacBackupPath
            Write-Host "Moved EasyAntiCheat folder to temporary location."
        } else {
            Write-Host "EasyAntiCheat folder not found, skipping..."
        }

        If (Test-Path $eacSysPath) {
            Move-Item $eacSysPath $eacSysBackupPath
            Write-Host "Moved EasyAntiCheat_EOS.sys to temporary location."
        } else {
            Write-Host "EasyAntiCheat_EOS.sys file not found, skipping..."
        }

        # Request to press SPACE before disabling internet
        Write-Host "Press SPACE to temporarily disable all internet connections and continue..."
        do {
            $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        } until ($key.VirtualKeyCode -eq 32)

        # Temporarily disable all internet connections (Ethernet and WiFi)
        Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Disable-NetAdapter -Confirm:$false

        # Start the game using steam protocol
        Write-Host "Starting the game..."
        Start-Process "steam://rungameid/315210"

        # Wait for 60 seconds
        Write-Host "Waiting for 60 seconds..."
        Start-Sleep -Seconds 60

        # Check every 10 seconds if 'start_protected_game.exe' is still running
        Do {
            $process = Get-Process "start_protected_game" -ErrorAction SilentlyContinue
            If ($process) {
                Write-Host "'start_protected_game.exe' is still running, waiting for another 10 seconds..."
                Start-Sleep -Seconds 10
            }
        } While ($process)

        # Enable all previously disabled internet connections
        Get-NetAdapter | Where-Object { $_.Status -eq "Disabled" } | Enable-NetAdapter -Confirm:$false

        # Move EasyAntiCheat files back
        Write-Host "Moving EasyAntiCheat files back to original location..."

        # Clear the EasyAntiCheat folder if it has contents, then move the backup files back
        If (Test-Path $eacFolderPath) {
            Remove-Item -Path "$eacFolderPath\*" -Recurse -Force
        }
        If (Test-Path $eacBackupPath) {
            Move-Item $eacBackupPath $eacFolderPath
            Write-Host "Moved EasyAntiCheat files back to original location."
        } else {
            Write-Host "EasyAntiCheat backup folder not found, skipping..."
        }

        # Overwrite the EasyAntiCheat_EOS.sys file if it exists, then move the backup file back
        If (Test-Path $eacSysPath) {
            Remove-Item -Path $eacSysPath -Force
        }
        If (Test-Path $eacSysBackupPath) {
            Move-Item $eacSysBackupPath $eacSysPath
            Write-Host "Moved EasyAntiCheat_EOS.sys file back to original location."
        } else {
            Write-Host "EasyAntiCheat_EOS.sys backup file not found, skipping..."
        }

        Write-Host "Done! EasyAntiCheat has been restored."
        Pause
        Pop-Location
    }
    "2" {
        Write-Host "Placeholder option selected. Feature coming soon..."
    }
    Default {
        Write-Host "Invalid option selected. Exiting..."
        Exit
    }
}
