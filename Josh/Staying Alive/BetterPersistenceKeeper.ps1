# ===[CONFIGURATION]===
$scriptFolder = "$env:ProgramData\Microsoft\Security\AuditLog"
$scriptPath = "$scriptFolder\logger.ps1"
$taskName = "Windows Audit Logger"

# ===[0. Abort if folder already exists]===
if (Test-Path $scriptFolder) {
    Write-Host "The folder '$scriptFolder' already exists. Aborting to avoid overwriting." -ForegroundColor Red
    exit
}

# ===[1. Create Folder]===
New-Item -Path $scriptFolder -ItemType Directory -Force | Out-Null

# ===[2. Create Persistent Monitor Script with Proper Escaping]===
$serviceScript = @"
`$scriptFolder = `"$scriptFolder`"
`$scriptPath = `"$scriptPath`"
`$taskName = `"$taskName`"

`$servicesToCheck = @(
    `"Spooler`",
    `"W32Time`",
    `"LanmanServer`"
)

while (`$true) {
    # ===[1. Check and Restart Services via CIM]===
    foreach (`$serviceName in `$servicesToCheck) {
        try {
            `$service = Get-CimInstance -ClassName Win32_Service -Filter `"Name='`$serviceName'`"
            if (`$service.State -ne 'Running') {
                `$result = Invoke-CimMethod -InputObject `$service -MethodName StartService
                if (`$result.ReturnValue -eq 0) {
                    # Successfully restarted
                }
            }
        } catch {
            # Silently ignore errors
        }
    }

    # ===[2. Self-Heal Scheduled Task if Deleted]===
    if (-not (Get-ScheduledTask -TaskName `$taskName -ErrorAction SilentlyContinue)) {
        `$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"`$scriptPath`""
        `$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([TimeSpan]::FromDays(49))
        `$principal = New-ScheduledTaskPrincipal -UserId `"SYSTEM`" -RunLevel Highest
        `$task = New-ScheduledTask -Action `$action -Trigger `$trigger -Principal `$principal
        Register-ScheduledTask -TaskName `$taskName -InputObject `$task -Force
    }

    Start-Sleep -Seconds 60
}
"@

# ===[3. Save Script to Disk]===
$serviceScript | Out-File -FilePath $scriptPath -Encoding UTF8 -Force

# ===[4. Create Scheduled Task If Missing]===
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([TimeSpan]::FromDays(49))
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal

if (-Not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
    Register-ScheduledTask -TaskName $taskName -InputObject $task -Force
    Write-Host "`nScheduled task '$taskName' created." -ForegroundColor Green
} else {
    Write-Host "`nScheduled task '$taskName' already exists. Skipping creation." -ForegroundColor Yellow
}

Write-Host "CIM-based persistence script saved to: $scriptPath"


