$IPList = Get-Content ip-list.txt
$FinalResult = @()
foreach ($IP in $IPList) {
    Write-Host $IP
    $tempObj = "" | Select-Object IPAddress, Name, Status, ErrorMessage
    try {
        $dnsResult = Resolve-DnsName -Name $IP -ErrorAction Stop
        $tempObj.IPAddress = $IP
        $tempObj.Name = $dnsResult.NameHost
        $tempObj.Status = 'OK'
        $tempObj.ErrorMessage = ''
    }
    catch {
        $tempObj.IPAddress = $IP
        $tempObj.Name = ''
        $tempObj.Status = 'NOT_OK'
        $tempObj.ErrorMessage = $_.Exception.Message
    }
    if ($tempObj.Name -eq '') {
        $tempObj.Status = 'NOT_OK'
        $tempObj.ErrorMessage = 'No se pudo encontrar el nombre de host'
    }
    $FinalResult += $tempObj
}
$FinalResult | Export-Csv -NoTypeInformation results.csv
