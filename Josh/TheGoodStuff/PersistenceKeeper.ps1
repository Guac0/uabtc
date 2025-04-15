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

# ===[2. Create Persistent Service Checker Script]===
$serviceScript = @"
`$scriptFolder = `"$scriptFolder`"
`$scriptPath = `"$scriptPath`"
`$taskName = `"$taskName`"

"`$(Get-Date): Task '`$taskName' started" | Out-File "`$scriptFolder\log.txt" -Append

`$servicesToCheck = @(
    `"Spooler`",
    `"W32Time`",
    `"LanmanServer`"
)

while (`$true) {
    foreach (`$serviceName in `$servicesToCheck) {
        try {
            `$service = Get-CimInstance -ClassName Win32_Service -Filter `"Name='`$serviceName'`"
            if (`$service.State -ne 'Running') {
                `$result = Invoke-CimMethod -InputObject `$service -MethodName StartService
                if (`$result.ReturnValue -eq 0) {
                    "`$(Get-Date): Restarted `$serviceName" | Out-File "`$scriptFolder\log.txt" -Append
                }
            }
        } catch {
            "`$(Get-Date): Error checking `$serviceName" | Out-File "`$scriptFolder\log.txt" -Append
        }
    }

    # Self-heal scheduled task if deleted
    if (-not (Get-ScheduledTask -TaskName `$taskName -ErrorAction SilentlyContinue)) {
        "`$(Get-Date): Task '`$taskName' was missing, recreating..." | Out-File "`$scriptFolder\log.txt" -Append
        `$escapedScriptPath = '"' + `$scriptPath + '"'
        `$startTime = (Get-Date).AddMinutes(1)
        `$trigger = New-ScheduledTaskTrigger -Once -At `$startTime `
            -RepetitionInterval (New-TimeSpan -Minutes 1) `
            -RepetitionDuration ([TimeSpan]::FromDays(49))
        `$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `$escapedScriptPath"
        `$settings = New-ScheduledTaskSettingsSet `
            -MultipleInstances IgnoreNew `
            -RestartCount 3 `
            -RestartInterval (New-TimeSpan -Minutes 1)
        `$principal = New-ScheduledTaskPrincipal -UserId `"SYSTEM`" -RunLevel Highest
        `$task = New-ScheduledTask -Action `$action -Trigger `$trigger -Principal `$principal -Settings `$settings
        Register-ScheduledTask -TaskName `$taskName -InputObject `$task -Force
    }

    Start-Sleep -Seconds 60
}
"@

# ===[3. Save Script to Disk]===
$serviceScript | Out-File -FilePath $scriptPath -Encoding UTF8 -Force

# ===[4. Register Scheduled Task If Missing]===
if (-not (Test-Path $scriptPath)) {
    Write-Host "Script not found at $scriptPath. Cannot create scheduled task." -ForegroundColor Red
    exit
}

$escapedScriptPath = '"' + $scriptPath + '"'
$startTime = (Get-Date).AddMinutes(1)

$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File $escapedScriptPath"
$trigger = New-ScheduledTaskTrigger -Once -At $startTime `
    -RepetitionInterval (New-TimeSpan -Minutes 1) `
    -RepetitionDuration ([TimeSpan]::FromDays(49))
$settings = New-ScheduledTaskSettingsSet `
    -MultipleInstances IgnoreNew `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings

if (-Not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
    Register-ScheduledTask -TaskName $taskName -InputObject $task -Force
    Write-Host "`nScheduled task '$taskName' created." -ForegroundColor Green
} else {
    Write-Host "`nScheduled task '$taskName' already exists. Skipping creation." -ForegroundColor Yellow
}

Write-Host "Persistent service checker with logging, overlap protection, and restart-on-failure saved to: $scriptPath"