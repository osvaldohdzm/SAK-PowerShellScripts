$NameList=Get-Content hostname-list.txt
$FinalResult = @()
foreach ($Name in $NameList) {
	Write-Host $Name
    $tempObj = "" | Select-Object Name, IPAddress, Status, ErrorMessage
    try {
        $dnsRecord = Resolve-DnsName $Name -Server $ServerList -ErrorAction Stop | Where-Object { $_.Type -eq 'A' }
        $tempObj.Name = $Name
        $tempObj.IPAddress = ($dnsRecord.IPAddress -join ',')
        $tempObj.Status = 'OK'
        $tempObj.ErrorMessage = ''
    }
    catch {
        $tempObj.Name = $Name
        $tempObj.IPAddress = ''
        $tempObj.Status = 'NOT_OK'
        $tempObj.ErrorMessage = $_.Exception.Message
    }
    $FinalResult += $tempObj
}
$FinalResult | Export-Csv -NoTypeInformation results.csv