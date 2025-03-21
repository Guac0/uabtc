#Finds file names in the specidied patern format

#This is the path that the finder will search
$path = "C:\"

# This Defines the regex pattern for filenames in the format word-word-word
# If you also want to search for numebr chnage pattern variable to "^[A-Za-z0-9]+-[A-Za-z0-9]+-[A-Za-z0-9]+$"
$pattern = "^[A-Za-z]+-[A-Za-z]+-[A-Za-z]+$"

# Get files matching the pattern, and suppress errors due to lack of acess
$matchingFiles = Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -match  $pattern}

# Output the results
# If you want to get the full file path chnage $_.Name to $_.FullName
if ($matchingFiles.Count -gt 0) {
    Write-Host "Matching files found:"
    $matchingFiles | ForEach-Object { Write-Host $_.Name}
} else {
    Write-Host "No matching files found."
}
Read-Host  -Prompt "Press Enter to exit"