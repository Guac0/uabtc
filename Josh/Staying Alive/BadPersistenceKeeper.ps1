$servicesToMonitor = @("WinDefend")  # Add service names

# Loop through each service and check if it is running
foreach ($service in $servicesToMonitor) {
    # Get service details using Get-CimInstance
    $serviceStatus = Get-CimInstance -ClassName Win32_Service -Filter "Name = '$service'"

    # If the service is not running, start it
    if ($serviceStatus.State -ne "Running") {
        # Restart the service
        Start-Service -Name $service
        Write-Output "$(Get-Date): Restarted $service" | Out-File -Append "$env:USERPROFILE\Desktop\ServiceMonitor.log"
    }
}