param (
    [string]$RestUrl
)

# Initialize variables
$UserPath = "C:\Users\eMARBackup"
$Path = Join-Path -Path $UserPath -ChildPath "Documents\eMAR_Backups"
$Errors = @()

# Check if user folder exists
If (-not (Test-Path $UserPath)) {
    $Errors += "User folder not found."
}

# Check if eMAR Backup folder exists
If (-not (Test-Path $Path)) {
    $Errors += "eMAR backup folder not found."
}

# Check if config file exists
$configFilePath = Join-Path -Path $Path -ChildPath "config.csv"
If (-not (Test-Path $configFilePath)) {
    $Errors += "Config file not found."
}

# Notify if new file is not created
$TimeToNotify = (Get-Date).AddMinutes(-18)
$Files = Get-ChildItem $Path -Recurse | Where-Object { $_.LastWriteTime -gt $TimeToNotify }
if ($Files.Count -eq 0) {
    $Errors += "New file not created."
}

# Check for errors and perform actions
if ($Errors.Count -gt 0) {
    # Report issues found
    $Errors | ForEach-Object { Write-Output $_ }
} else {
    # All tests passed, perform the Invoke-RestMethod call
    try {
        $Response = Invoke-RestMethod -Uri $RestUrl -Method Get
        Write-Output "Success: $($Response.StatusCode)"
    } catch {
        Write-Output "Failed to invoke REST method: $_"
    }
}
