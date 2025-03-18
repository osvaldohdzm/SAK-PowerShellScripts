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
$User = $_.User
$PWord = ConvertTo-SecureString -String $_.Password -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
New-SSHSession -ComputerName $_.Host -Credential $Credential -AcceptKey | Out-Null

    If($?){
        $status = Write-output "Succesfull"
    }else{
        $status = Write-output "Failed"
    }
    
    [pscustomobject][ordered]@{
        Host  = $_.Host 
        CredentialCheck  = $status
    }
    
	$current_host = $_.Host
    Write-Host "$current_host logging attemp is $status"

}

$info | export-csv outputs.csv -NoTypeInformation

$e=Get-Date;
$ft = ($e - $s).TotalSeconds 
Write-Host "`nStarted at $s, finished at $e"
Write-Host "`Execution time $ft seconds"

Write-Host "`nPress any key to continue"
[Console]::ReadKey()



