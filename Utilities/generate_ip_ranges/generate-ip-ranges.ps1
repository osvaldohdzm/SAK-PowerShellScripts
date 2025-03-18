Function Get-ScanIPRange {


Param (
       [Parameter (Mandatory=$true)]
       [string]
       $StartScanIP,
       
       [string]
       $EndScanIP
)



  $ScanIPRange = @()

  if (-not([string]::IsNullOrEmpty($EndScanIP))) {
             
    $StartIP = $StartScanIP -split '\.'
    [Array]::Reverse($StartIP)
    $StartIP = ([System.Net.IPAddress]($StartIP -join '.')).Address

    $EndIP = $EndScanIP -split '\.'
    [Array]::Reverse($EndIP)
    $EndIP = ([System.Net.IPAddress]($EndIP -join '.')).Address

    For ($x=$StartIP; $x -le $EndIP; $x++) {
      $IP = [System.Net.IPAddress]$x -split '\.'
      [Array]::Reverse($IP)
      $ScanIPRange += $IP -join '.'
    }
  }
  else {
    $ScanIPRange += $StartScanIP
  }

  Return $ScanIPRange
}


$StartIP="172.27.0.0"
$EndIP="172.27.255.255" 
Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

$StartIP="10.10.0.0" 
$EndIP="10.10.255.255" 
Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

$StartIP="10.101.0.0"
$EndIP="10.101.255.255" 
Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

$StartIP="10.15.0.0" 
$EndIP="10.15.255.255" 
Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

$StartIP="10.2.0.0"
$EndIP="10.2.255.255" 
Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

$StartIP="10.249.0.0"
$EndIP="10.249.255.255" 
Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

$StartIP="10.250.0.0"
$EndIP="10.250.255.255" 
Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

$StartIP="10.3.0.0"
$EndIP="10.3.255.255" 
Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

$StartIP="10.4.0.0" 
$EndIP="10.4.255.255" 
Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

$StartIP="10.5.0.0" 
$EndIP="10.5.255.255" 
Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

$StartIP="10.60.0.0" 
$EndIP="10.60.255.255" 
Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

$StartIP="169.254.0.0" 
$EndIP="169.254.255.255" 
Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

$StartIP="172.17.0.0"
 $EndIP="172.17.255.255" 
 Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

 $StartIP="172.18.0.0"
 $EndIP="172.18.255.255" 
 Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

 $StartIP="172.28.0.0"
 $EndIP="172.28.255.255" 
 Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

 $StartIP="189.204.0.0" 
$EndIP="189.204.255.255" 
Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

$StartIP="200.77.0.0"
$EndIP="200.77.255.255" 
Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

$StartIP="201.148.0.0" 
$EndIP="201.148.255.255" 
Get-ScanIPRange $StartIP $EndIP >> "ranges-output.txt"

Read-Host