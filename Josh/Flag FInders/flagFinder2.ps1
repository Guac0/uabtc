#Flag finder that reads files less than 100 bytes and looks for the pattern

$directory = "C:\"  # Change this to the directory you want to scan
$pattern = "ISTS\{[a-zA-Z0-9]+-[a-zA-Z0-9]+-[a-zA-Z0-9]+\}"  # Regex for flag format

Get-ChildItem -Path $directory -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Length -lt 100 } | ForEach-Object {
    $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -match $pattern) {
        Write-Output "Match: $($matches[0])"
        Write-Output "Flag found in: $($_.FullName)"
        
    }
}

# Pause the script and wait for user input to close the window
Read-Host -Prompt "Press Enter to exit"