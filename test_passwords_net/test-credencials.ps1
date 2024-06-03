
$ComputersFile = "ip-list.txt"
$User = "ehs"
$PWord = ConvertTo-SecureString -String "ehs" -AsPlainText -Force

Function Test-UserCredential { 
    Param($username, $password) 
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement 
    $ct = [System.DirectoryServices.AccountManagement.ContextType]::Machine, $env:computername 
    $opt = [System.DirectoryServices.AccountManagement.ContextOptions]::SimpleBind 
    $pc = New-Object System.DirectoryServices.AccountManagement.PrincipalContext -ArgumentList $ct 
    $Result = $pc.ValidateCredentials($username, $password).ToString() 
    $Result 
} 



Foreach($_ in $ComputersFile)
{
   net use \\192.168.10.159 /user:Administrador
}