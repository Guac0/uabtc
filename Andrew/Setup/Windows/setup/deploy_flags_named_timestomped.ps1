# Define log file location
$LOG_FILE = "C:\flags\flags_named_timestomped.txt"
$WORDS = (invoke-webrequest -Uri https://raw.githubusercontent.com/RazorSh4rk/random-word-api/master/words.json -UseBasicParsing).content | convertfrom-json

# Function to generate a random word from a word list
function Get-RandomWord {
    #$wordList = Get-Content "$env:SystemRoot\System32\drivers\etc\hosts" | Where-Object {$_ -match "\w+"} | Get-Random
    #if (-not $wordList) { return "random" }
    #return ($wordList -split '\s+')[0]
    
    return $words["$(get-random -Maximum ($words.count))"]
}

# Function to generate a random timestamp between 2015 and 2025
function Get-RandomTimestamp {
    $startDate = Get-Date "01/01/2015 00:00:00"
    $endDate = Get-Date "12/31/2025 23:59:59"
    $randomTime = Get-Random -Minimum $startDate.Ticks -Maximum $endDate.Ticks
    return (New-Object DateTime $randomTime)
}

# Function to find a truly random directory excluding system-critical paths
function Get-RandomDirectory {
    $excludedPaths = @("C:\Windows", "C:\Program Files", "C:\Program Files (x86)")

    # Get all directories on C:\, excluding the paths in $excludedPaths
    $directories = Get-ChildItem -Path C:\ -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object {
        # Ensure we exclude any directory that matches the excluded paths or is a subdirectory of them
        $excludedPaths -notcontains $_.FullName -and $_.FullName -notlike "C:\Windows\*"
    }

    # If no directories are found, return C:\Temp as a fallback
    if ($directories.Count -eq 0) { return "C:\Temp" }

    # Return a random directory from the list
    return ($directories | Get-Random).FullName
}

# Clear log file if it exists
if (Test-Path $LOG_FILE) { Remove-Item -Force $LOG_FILE }
New-Item -Path $LOG_FILE -ItemType File -Force | Out-Null

# Create 10 files with random names, locations, and timestamps
for ($i = 1; $i -le 10; $i++) {
    $fileName = "$(Get-RandomWord)-$(Get-RandomWord)-$(Get-RandomWord).txt"
    $targetDir = Get-RandomDirectory
    $filePath = Join-Path -Path $targetDir -ChildPath $fileName

    # Create the file
    New-Item -Path $filePath -ItemType File -Force | Out-Null

    # Apply a random timestamp
    $timestamp = Get-RandomTimestamp
    $(Get-Item $filePath).CreationTime = $timestamp
    $(Get-Item $filePath).LastWriteTime = $timestamp
    $(Get-Item $filePath).LastAccessTime = $timestamp

    # Log the details
    "Created: $filePath | Timestamp: $timestamp" | Out-File -Append -FilePath $LOG_FILE
}