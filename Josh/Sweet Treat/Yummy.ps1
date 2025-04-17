# Logs user input pretending to be a real terminal

$logPath = "$env:PUBLIC\shell-log.txt"
"=== Honeypot Shell Started at $(Get-Date) ===`n" | Out-File $logPath -Encoding UTF8 -Append

while ($true) {
    $input = Read-Host "PS C:\>"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $input" | Out-File $logPath -Encoding UTF8 -Append
    Write-Host "Stupid" -ForegroundColor Red 
}