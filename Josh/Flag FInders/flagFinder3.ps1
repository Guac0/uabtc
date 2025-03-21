#Finds files created in the last hour with a certin filename  

# Define the path to search
$path = "C:\"

# Define the regex pattern: word1-word2-word3 (alphanumeric words separated by hyphens)
$pattern = "^[A-Za-z0-9]+-[A-Za-z0-9]+-[A-Za-z0-9]+$"

# Get the current time and calculate the cutoff time (1 hour ago)
$cutoffTime = (Get-Date).AddHours(-1)

# Get all files created within the last hour and match the pattern
Get-ChildItem -Path $path -File -Recurse -ErrorAction SilentlyContinue |
    Where-Object {
        $_.CreationTime -ge $cutoffTime -and $_.Name -match $pattern
    } |
    ForEach-Object {
        Write-Host $_.Name
    }
Read-Host  -Prompt "Press Enter to exit"