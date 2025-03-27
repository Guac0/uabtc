#This one is so you don't accidently brick an account that is nessary for the computers function

# Define the password to be used for all accounts
$Password = "password69"  # Change this to your desired password

$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

# Get all users, excluding SYSTEM accounts
$ExcludedAccounts = @("Administrator", "DefaultAccount", "Guest", "LocalSystem", "LocalService", "NetworkService")
$Users = Get-LocalUser | Where-Object { $ExcludedAccounts -notcontains $_.Name }

while ($true) {
    foreach ($User in $Users) {
        try {
            Set-LocalUser -Name $User.Name -Password $SecurePassword 
            Write-Output "Password for $($User.Name) changed at $(Get-Date)"
        } catch {
            Write-Output "Failed to change password for $($User.Name): $_"
        }
    }
    Start-Sleep -Seconds 60
}