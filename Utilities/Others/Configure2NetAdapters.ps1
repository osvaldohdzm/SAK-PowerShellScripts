ipconfig /flushdns

Remove-NetRoute

$interfaceIndex = (Get-NetAdapter | Where-Object {$_.Name -eq "Ethernet"}).InterfaceIndex
$destinationPrefix = "10.0.0.0/8"
$route = New-NetRoute -DestinationPrefix $destinationPrefix -InterfaceIndex $interfaceIndex -NextHop 10.10.115.5 -RouteMetric 1

$interfaceIndex = (Get-NetAdapter | Where-Object {$_.Name -eq "Ethernet"}).InterfaceIndex
$destinationPrefix = "172.16.0.0/12"
$route = New-NetRoute -DestinationPrefix $destinationPrefix -InterfaceIndex $interfaceIndex -NextHop 10.10.115.5 -RouteMetric 1

$interfaceIndex = (Get-NetAdapter | Where-Object {$_.Name -eq "Ethernet"}).InterfaceIndex
$destinationPrefix = "192.168.0.0/16"
$route = New-NetRoute -DestinationPrefix $destinationPrefix -InterfaceIndex $interfaceIndex -NextHop 10.10.115.5 -RouteMetric 1

ipconfig /release

ipconfig /renew

