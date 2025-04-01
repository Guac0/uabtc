#password chnager test

$password = "password69"
$password = ConvertTo-SecureString $password -AsPlainText -Force

Get-LocalUser | ForEach-Object {
    $name = $_.Name 
    Get-LocalUser -Name $name}
