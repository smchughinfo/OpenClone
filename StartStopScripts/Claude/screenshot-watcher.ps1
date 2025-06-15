Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Check if another instance is already running
$mutexName = "ClaudeScreenshotWatcher"
$mutex = New-Object System.Threading.Mutex($false, $mutexName)

if (-not $mutex.WaitOne(0)) {
    Write-Host "Screenshot watcher is already running. Exiting..."
    exit 1
}

# Ensure mutex is released when script exits
Register-EngineEvent PowerShell.Exiting -Action {
    $mutex.ReleaseMutex()
    $mutex.Dispose()
}

$screenshotDir = "C:\Users\seanm\Desktop\OpenClone\StartStopScripts\Claude\Screenshots"

# Create directory if it doesn't exist
if (-not (Test-Path $screenshotDir)) {
    New-Item -ItemType Directory -Path $screenshotDir -Force
    Write-Host "Created directory: $screenshotDir"
}

# Clean up any existing screenshots
$existingFiles = Get-ChildItem $screenshotDir -Filter "*.png" -ErrorAction SilentlyContinue
if ($existingFiles.Count -gt 0) {
    Remove-Item "$screenshotDir\*.png" -Force
    Write-Host "Cleaned up $($existingFiles.Count) existing screenshot(s)"
}

Write-Host "Clipboard screenshot watcher started..."
Write-Host "Screenshots will be saved to: $screenshotDir"
Write-Host "Press Ctrl+C to stop"

$lastImageHash = $null

while ($true) {
    try {
        if ([System.Windows.Forms.Clipboard]::ContainsImage()) {
            $currentImage = [System.Windows.Forms.Clipboard]::GetImage()
            
            # Create a hash of the image to compare
            $ms = New-Object System.IO.MemoryStream
            $currentImage.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
            $imageBytes = $ms.ToArray()
            $ms.Close()
            
            $hash = [System.Security.Cryptography.MD5]::Create().ComputeHash($imageBytes)
            $hashString = [System.BitConverter]::ToString($hash)
            
            # Only save if this is a different image
            if ($hashString -ne $lastImageHash) {
                # Delete any existing screenshots before saving the new one
                $existingFiles = Get-ChildItem $screenshotDir -Filter "*.png" -ErrorAction SilentlyContinue
                if ($existingFiles.Count -gt 0) {
                    Remove-Item "$screenshotDir\*.png" -Force
                }
                
                $filename = "screenshot_$(Get-Date -Format 'yyyyMMdd_HHmmss').png"
                $filepath = Join-Path $screenshotDir $filename
                
                [System.IO.File]::WriteAllBytes($filepath, $imageBytes)
                Write-Host "Screenshot saved: $filename"
                
                $lastImageHash = $hashString
            }
            
            $currentImage.Dispose()
        }
    }
    catch {
        Write-Host "Clipboard access error (this is normal): $($_.Exception.Message)"
    }
    
    Start-Sleep -Seconds 1
}

# Script ended - cleanup
try {
    $mutex.ReleaseMutex()
    $mutex.Dispose()
} catch {
    # Ignore cleanup errors
}