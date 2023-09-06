# Solicitar la ruta del archivo de objetivos
$filePath = Read-Host "Introduce la ruta del archivo de objetivos"

$info = Get-Content $filePath | foreach {
    If(Test-Connection -ComputerName $_ -Count 4 -Quiet){
        $status = Write-Output "Active"
    }else{
        $status = Write-Output "Inactive"
    }
    
    [PSCustomObject]@{
        HostnameIP  = $_
        Status  = $status
    }

    Write-Host "$_ is $status"
}

$info | Export-Csv ping-results.csv -NoTypeInformation

Write-Output "Finished at $(Get-Date)"
[Console]::ReadKey()
