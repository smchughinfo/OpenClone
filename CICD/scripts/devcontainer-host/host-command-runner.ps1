$windowTitle = "OpenClone Terraform Host Command Runner"
$nameOfThisFile = [System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath) + ".ps1"

#################################################################################################
######## KILL DUPLICATE INSTANCES OF THIS SCRIPT ################################################
#################################################################################################

# Get current process ID
$currentProcessId = $PID

# Close copies of this script that are currently running
Write-Host "Terminating duplicate instances of this script..."
$psProcesses = Get-WmiObject Win32_Process -Filter "Name = 'powershell.exe'"

foreach ($psProcess in $psProcesses) {
    # Check if the process is running this exact script
    if ($psProcess.CommandLine -like "*$nameOfThisFile*") {
        # Skip the current process
        if ($psProcess.ProcessId -ne $currentProcessId) {
            Write-Host "    Found Duplicate PowerShell Process ID: $($psProcess.ProcessId)"
            #Write-Host "    Duplicate PowerShell Command Line: $($psProcess.CommandLine)"

            # Find the associated conhost process
            $conhostProcesses = Get-WmiObject Win32_Process -Filter "Name = 'conhost.exe'" | Where-Object {
                $_.ParentProcessId -eq $psProcess.ProcessId
            }

            foreach ($conhostProcess in $conhostProcesses) {
                Write-Host "    Terminating Conhost Process ID: $($conhostProcess.ProcessId)"
                Stop-Process -Id $conhostProcess.ProcessId -Force
            }
            
            # Terminate the duplicate PowerShell process
            Write-Host "    Terminating PowerShell Process ID: $($psProcess.ProcessId)"
            Stop-Process -Id $psProcess.ProcessId -Force
        }
    }
}

$host.ui.RawUI.WindowTitle = $windowTitle

#################################################################################################
######## ADD WIN32 CODE TO DO WINDOW MININIMIZE/RESTORE #########################################
#################################################################################################

# Minimize the PowerShell window when the script starts
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
}
"@

$SW_MINIMIZE = 6
$SW_RESTORE = 9  # Command to restore/unminimize the window

#################################################################################################
######## MINIMIZE THIS SCRIPT WHEN IT STARTS ####################################################
#################################################################################################

# Get the handle for the current PowerShell window by searching for the title
$process = Get-Process | Where-Object {
    $_.MainWindowTitle -eq $windowTitle
}
$handle = $process.MainWindowHandle

if (-not $handle) {
    Write-Host "Could not retrieve the window handle. Make sure the script is running in a window with the correct title."
    exit
}

$windowStateChangeSuccess = [Win32]::ShowWindow($handle, $SW_MINIMIZE)

#################################################################################################
######## RUN COMMANDS (in loop, whatever is saved to script-to-run.bat) #########################
#################################################################################################

# Set the path to the script to monitor
$scriptPath = Join-Path $env:OpenClone_Root_Dir 'CICD\scripts\devcontainer-host\script-to-run.bat'
$directoryPath = Join-Path $env:OpenClone_Root_Dir 'CICD\scripts\devcontainer-host'

# delete files that were left over from last time this script ran (dev mistake, crash, etc.). 
# ...actually i don't like this. if you accidentally close the window and restart vscode to start this script you lose what you were doing
# if (Test-Path $scriptPath) { Remove-Item $scriptPath -Force }

$timesChecked = 0

# Store the initial cursor position for the "Checking" line
$initialPosition = [System.Console]::CursorTop

Write-Host "Check $timesChecked Checking for existence of: $scriptPath"

while ($true) {
    # Validate cursor position
    if ($initialPosition -ge [System.Console]::BufferHeight) {
        $initialPosition = [System.Console]::BufferHeight - 1
    }
    
    # Move cursor back to the initial position and overwrite the line
    [System.Console]::SetCursorPosition(0, $initialPosition)
    Write-Host ("Check $timesChecked Checking for existence of: $scriptPath") -NoNewline

    # Increment the counter
    $timesChecked++

    # Check for the existence of the script
    if (Test-Path $scriptPath) {
        # Move cursor down before running the script to avoid interference
        Write-Host "`nRunning script: $scriptPath"

        # Unminimize (restore) the PowerShell window
        $windowStateChangeSuccess = [Win32]::ShowWindow($handle, $SW_RESTORE)

        try {
            # Run the batch script
            & $scriptPath
        } catch {
            Write-Host "The batch script encountered an error: $_"
            Read-Host "Press Enter to continue..."
        }

        Write-Host ""
        Write-Host "##################### SCRIPT COMPLETE #####################"
        Write-Host ""
        
        # Minimize the window again after running the script
        $windowStateChangeSuccess = [Win32]::ShowWindow($handle, $SW_MINIMIZE)

        # Delete the script after it finishes running
        Remove-Item $scriptPath

        # Move cursor down again to avoid overlap with batch script output
        $initialPosition = [System.Console]::CursorTop
    }

    # Wait for a short interval before checking again
    Start-Sleep -Seconds 2
}