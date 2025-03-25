# Function to generate a random name
function Get-RandomName {
    $firstNames = @("John", "Jane", "Alice", "Bob", "Charlie", "David", "Eve", "Frank", "Grace", "Helen")
    $lastNames = @("Smith", "Johnson", "Brown", "Williams", "Jones", "Miller", "Davis", "García", "Rodriguez", "Martinez")

    # Pick a random first and last name
    $firstName = Get-Random -InputObject $firstNames
    $lastName = Get-Random -InputObject $lastNames

    # Combine them to form a full name
    return "$firstName$lastName"
}

# Create 20 users
for ($i = 1; $i -le 20; $i++) {
    $userName = Get-RandomName
    $password = "DefaultPass1#"  # Set a default password

    # Create the user
    New-LocalUser -Name $userName -Password (ConvertTo-SecureString -AsPlainText $password -Force) -FullName $userName -Description "Random User"

    # Optionally, add the user to the "Users" group
    Add-LocalGroupMember -Group "Users" -Member $userName

    Write-Host "Created user: $userName"
}
