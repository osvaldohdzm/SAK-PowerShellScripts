# Solicitar al usuario la dirección IP de destino
$targetIP = Read-Host "Enter the target IP address"

# Solicitar los valores inferior y superior de min-rate a probar
$minRateStart = Read-Host "Enter the lower min-rate to test"
$minRateEnd = Read-Host "Enter the upper min-rate to test"

# Convertir los valores de min-rate a números enteros
$minRateStart = [int]$minRateStart
$minRateEnd = [int]$minRateEnd

Write-Host "Running initial tests for gradual search..."

$optimalMinRate = $minRateStart
$optimalTime = [double]::MaxValue

$step = 100  # Tamaño del paso para la búsqueda gradual inicial

for ($minRate = $minRateStart; $minRate -le $minRateEnd; $minRate += $step) {
    $nmapCommand = "nmap --min-rate $minRate -T5 --max-retries=1 --max-rtt-timeout 1s --defeat-rst-ratelimit -Pn -n -p 80,22,53 $targetIP"
    Write-Host "Testing --min-rate $minRate..."

    $timeTaken = (Measure-Command { Invoke-Expression $nmapCommand }).TotalSeconds

    if ($timeTaken -lt $optimalTime) {
        $optimalTime = $timeTaken
        $optimalMinRate = $minRate
    }

    Write-Host "Completed in $timeTaken seconds."

    if ($timeTaken -eq 0) {
        break
    }
}

# Refinamiento usando búsqueda binaria en el rango cercano al óptimo encontrado
Write-Host "Refining search using binary search..."

$minRateStart = [Math]::Max($optimalMinRate - $step, 1)
$minRateEnd = [Math]::Min($optimalMinRate + $step, $minRateEnd)

while ($minRateStart -le $minRateEnd) {
    $midRate = [Math]::Round(($minRateStart + $minRateEnd) / 2)
    
    $nmapCommand = "nmap --min-rate $midRate -T5 --max-retries=1 --max-rtt-timeout 1s --defeat-rst-ratelimit -Pn -n -p 80,22,53 $targetIP"
    Write-Host "Testing --min-rate $midRate..."
    
    $timeTaken = (Measure-Command { Invoke-Expression $nmapCommand }).TotalSeconds

    if ($timeTaken -lt $optimalTime) {
        $optimalTime = $timeTaken
        $optimalMinRate = $midRate
    }
    
    Write-Host "Completed in $timeTaken seconds."
    
    if ($timeTaken -eq 0) {
        break
    }
    
    if ($timeTaken -lt $optimalTime) {
        $minRateEnd = $midRate - 1
    } else {
        $minRateStart = $midRate + 1
    }
}

Write-Host "Tests completed."

# Mostrar el valor óptimo encontrado
Write-Host "The suggested --min-rate is $optimalMinRate with a time of $optimalTime seconds."
