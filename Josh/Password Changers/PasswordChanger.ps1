#This changes every users password on the device use with caution 

# Define the password to be used for all accounts
$Password = "password69"  # Change this to your desired password

$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
$Users = Get-LocalUser

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