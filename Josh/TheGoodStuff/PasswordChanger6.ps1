##############################################################
# Blue Team Account Setup and Lockdown Script
# - Creates a new privileged local user ("Me")
# - Changes password for all local and AD accounts
# - Disables all accounts not in the exclusion list
# Run this only once to avoid duplicate user creation
##############################################################

# Prompt for the initial password of the new local user
$userpass = Read-Host "Enter user password" -AsSecureString

# Create and enable the local user account
New-LocalUser -Name "Me" -Password $userpass
Enable-LocalUser -Name "Me"
net localgroup Administrators Me /add

# If running on a domain controller, add the user to Domain Admins
if ((Get-CimInstance -Class Win32_OperatingSystem).ProductType -eq 2) {
    Add-ADGroupMember -Identity "Domain Admins" -Members "Me"
}

# Attempt to import the Active Directory module
$ADModuleAvailable = $false
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    $ADModuleAvailable = $true
    Write-Host "[INFO] ActiveDirectory module loaded successfully."
} catch {
    Write-Warning "[WARNING] ActiveDirectory module not found. AD user changes will be skipped."
}

# Prompt the operator to enter and confirm a new password for all accounts
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

# List of accounts to exclude from being disabled
$ExcludedAccounts = @("Me", "Administrator", "krbtgt", "DefaultAccount", "WDAGUtilityAccount")

# Process all enabled user accounts (both local and domain)
Get-CimInstance -ClassName Win32_UserAccount | Where-Object { $_.Disabled -eq $false } | ForEach-Object {
    if ($_.LocalAccount -eq $true) {
        # Handle local user accounts
        try {
            Set-LocalUser -Name $_.Name -Password $SecurePassword
            if ($ExcludedAccounts -notcontains $_.Name) {
                Disable-LocalUser -Name $_.Name
                Write-Output "[$(Get-Date)] Password for LOCAL user $($_.Name) changed and user disabled."
            } else {
                Write-Output "[$(Get-Date)] Password for LOCAL excluded user $($_.Name) changed but NOT disabled."
            }
        } catch {
            Write-Output "[$(Get-Date)] Failed to change password for LOCAL user $($_.Name): $($_.Exception.Message)"
        }
    } elseif ($ADModuleAvailable) {
        # Handle Active Directory user accounts
        try {
            Set-ADAccountPassword -Identity $_.Name -NewPassword $SecurePassword
            if ($ExcludedAccounts -notcontains $_.Name) {
                Disable-ADAccount -Identity $_.Name
                Write-Output "[$(Get-Date)] Password for AD user $($_.Name) changed and user disabled."
            } else {
                Write-Output "[$(Get-Date)] Password for AD excluded user $($_.Name) changed but NOT disabled."
            }
        } catch {
            Write-Output "[$(Get-Date)] Failed to change password for AD user $($_.Name): $($_.Exception.Message)"
        }
    } else {
        # Skip AD user if AD module is not available
        Write-Output "[$(Get-Date)] Skipping AD user $($_.Name) because AD module is unavailable."
    }
}
