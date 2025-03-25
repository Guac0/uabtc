#This one only works on accounts that are enabled so you don't accidently mess up an account you don't need chnaged 

# Define the password to be used for all accounts
$Password = "password69"  # Change this to your desired password

$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
$Users = Get-LocalUser | Where-Object { $_.Enabled -eq $true }

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