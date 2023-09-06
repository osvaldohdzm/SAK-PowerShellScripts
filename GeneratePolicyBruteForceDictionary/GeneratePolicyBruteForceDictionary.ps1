function EstimateCrackTime {
    param (
        [string]$password
    )

    $lowercase = 'abcdefghijklmnopqrstuvwxyz'
    $uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $numbers = '0123456789'
    $symbols = '!@#$%^&*()-_=+[]{}|;:,.<>?'

    $charsets = @($lowercase, $uppercase, $numbers, $symbols)

    $unique_chars = ($password.ToCharArray() | Select-Object -Unique).Count
    $entropy_bits = [math]::Log([math]::Pow($unique_chars, $password.Length), 2)

    $attempts_per_second = 1
    $adjuster_value = 180
    $seconds_per_attempt = [math]::Pow(2, $entropy_bits) / ($attempts_per_second * $adjuster_value)

    return $seconds_per_attempt
}

$filePath = Read-Host "Introduce la ruta del archivo de texto (.txt)"

# Elimina comillas dobles si están presentes
$filePath = $filePath -replace '^"|"$', ''

$daysToTest = Read-Host "¿Cuántos días tienes para probar las cadenas de texto?"

# Convierte los días a segundos
$secondsToTest = [int]$daysToTest * 86400

try {
    $lines = Get-Content -Path $filePath
    $timeData = @()

    foreach ($line in $lines) {
        $timeValue = EstimateCrackTime -password $line
        $timeData += [PSCustomObject]@{
            Line = $line
            TimeValue = $timeValue
        }
    }

    $filteredData = $timeData | Where-Object { $_.TimeValue -lt $secondsToTest }

    if ($filteredData.Count -eq 0) {
        Write-Host "No se encontraron palabras con tiempo estimado menor a $daysToTest días."
    } else {
        $sortedData = $filteredData | Sort-Object -Property TimeValue

        $outputFilePath = "result.txt"
        $sortedData | ForEach-Object { $_.Line } | Set-Content -Path $outputFilePath

        Write-Host "Las palabras con tiempo estimado menor a $daysToTest días han sido escritas en $outputFilePath."
    }
} catch {
    Write-Host "Error: $_"
}
