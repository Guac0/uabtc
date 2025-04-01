
# Windows
#dir | ?{$_.name -match "^[0-9]{3}x[0-9]{3}.jpg$"}

#Get-ChildItem -Path "C:" -Recurse | Where-Object {$_.Name -match ".*[A-Za-z]+-[A-Za-z]+-[A-Za-z]+.*"}
# messy output and looks for exact format match
#Get-ChildItem -Path "C:" -Recurse | Where-Object {$_.Name -match "^[A-Za-z]+-[A-Za-z]+-[A-Za-z]+$"}

$matchedFiles = @()  # Store matching file paths

Get-ChildItem -Path C:\ -Recurse -File -ErrorAction SilentlyContinue | 
Where-Object { $_.Length -lt 50 } | 
ForEach-Object {
    Write-Host "Checking: $($_.FullName)"  # Display current file
    $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -match ".*[A-Za-z]+-[A-Za-z]+-[A-Za-z]+$") {
        $matchedFiles += $_.FullName  # Store matching file path
    }
}

# Output all matches at the end
if ($matchedFiles.Count -gt 0) {
    Write-Host "`nMatching Files:`n"
    $matchedFiles | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "`nNo matching files found."
}

Read-Host "Press Enter to exit"
