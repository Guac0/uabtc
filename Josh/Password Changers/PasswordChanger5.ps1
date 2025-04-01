#This one is for AD and local accounts

$userpass = Read-Host "Enter user password" -AsSecureString
New-LocalUser -Name "Me" -Password $userpass
net localgroup Administrators Me /add
if (Get-CimInstance -Class Win32_OperatingSystem -Filter 'ProductType = "2"') {
    Add-ADGroupMember -Identity "Domain Admins" -Members "Me"
}

# Collect the new password
do {
        $password1 = Read-Host "Enter password" -AsSecureString
        $password2 = Read-Host "Re-enter password" -AsSecureString
        $password1_text = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password1))
        $password2_text = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password2))
        $SecurePassword = $password1
        if ($password1_text -ne $password2_text) {
            Write-Host "Passwords do not match. Please try again."
        }
} until ($password1_text -eq $password2_text)

# Define excluded accounts to prevent breaking system/service accounts
$ExcludedAccounts = @("Me","Administrator", "Guest", "krbtgt", "DefaultAccount", "WDAGUtilityAccount")

# Get all enabled users (Local + AD) and process them with the pipeline
Get-CimInstance -ClassName Win32_UserAccount | Where-Object { $_.Disabled -eq $false -and $ExcludedAccounts -notcontains $_.Name } | ForEach-Object {
    if ($_.LocalAccount -eq $true) {
        # Handle Local Users
        try {
            Set-LocalUser -Name $_.Name -Password $SecurePassword
            Write-Output "[$(Get-Date)] Password for LOCAL user $($_.Name) changed."
        } catch {
            Write-Output "[$(Get-Date)] Failed to change password for LOCAL user $($_.Name): $($_.Exception.Message)"
        }
    } else {
        # Handle AD Users
        try {
            Set-ADAccountPassword -Identity $_.Name -NewPassword $SecurePassword
            Write-Output "[$(Get-Date)] Password for AD user $($_.Name) changed."
        } catch {
            Write-Output "[$(Get-Date)] Failed to change password for AD user $($_.Name): $($_.Exception.Message)"
        }
    }
}