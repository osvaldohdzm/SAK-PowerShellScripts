Write-Host "Starting"
$s=Get-Date;

Write-Host "Checking module.."
if (Get-Module -ListAvailable -Name Posh-SSH) {

    Write-Host "Module exists"
} 
else {
    Write-Host "Module does not exist"

Set-PSrepository -Name PSGallery -InstallationPolicy Trusted
Set-ExecutionPolicy Unrestricted CurrentUser
Install-Module -Scope CurrentUser Posh-SSH -RequiredVersion 2.0.2
Import-Module Posh-SSH
}

Write-Host "Importing csv.."


$info = Import-Csv credentials.csv -delimiter "," | ForEach-Object {

Write-Host "Testing credential.."

$ip = $_.Host 
$user = $_.Host 
$pass = $_.Password 

net use \\$ip /user:$user $pass | Out-Null


    If($?){
        $status = Write-output "Succesfull"
    }else{
        $status = Write-output "Failed"
    }
    
    [pscustomobject][ordered]@{
        Host  = $_.Host 
        CredentialCheck  = $status
    }
    

    Write-Host "$ip logging attemp is $status"

}

$info | export-csv outputs.csv -NoTypeInformation

$e=Get-Date;
$ft = ($e - $s).TotalSeconds 
Write-Host "`nStarted at $s, finished at $e"
Write-Host "`Execution time $ft seconds"

Write-Host "`nPress any key to continue"
[Console]::ReadKey()



