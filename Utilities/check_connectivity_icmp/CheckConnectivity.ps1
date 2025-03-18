param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$FilePath
)

# Leer el archivo CSV
$targets = Import-Csv $FilePath

# Definir la ruta para el archivo de salida
$outputFilePath = "Output.csv"

# Crear el archivo CSV de salida con los encabezados
"Hostname,PingStatusHostname,IPv4,PingStatusIPv4,PingStatus" | Out-File -FilePath $outputFilePath -Encoding UTF8

# Función para realizar el ping y devolver el estado
function Test-Ping ($target) {
    $ping = New-Object System.Net.NetworkInformation.Ping

    # Realizar ping a HostName si está disponible
    if (-not [string]::IsNullOrEmpty($target)) {
        Write-Host -NoNewline "Pinging $target..."
        try {
            $pingResult = $ping.Send($target, 1000)  # 1000 ms timeout
            if ($pingResult.Status -eq 'Success') {
                Write-Host " OK"
                return "OK"
            } else {
                Write-Host " NOT OK"
                return "NOT OK"
            }
        } catch {
            Write-Host " NOT OK"
            return "NOT OK"
        }
    }

    # Si no se proporciona HostName o IP, retornar vacío
    return ""
}

# Iterar a través de los objetivos y escribir en el archivo de salida
foreach ($target in $targets) {
    $hostnamePingStatus = ""
    $ipv4PingStatus = ""
    $overallStatus = "NOT OK"  

    if (-not [string]::IsNullOrEmpty($target.Hostname)) {
        $hostnamePingStatus = Test-Ping $target.Hostname
    }

    if (-not [string]::IsNullOrEmpty($target.IPv4)) {
        $ipv4PingStatus = Test-Ping $target.IPv4
    }

    # Determinar el estado general
    if ($hostnamePingStatus -eq "OK" -or $ipv4PingStatus -eq "OK") {
        $overallStatus = "OK"  # Al menos uno de los pings fue exitoso
    }

    # Construir la línea para el archivo de salida
    $outputLine = "$($target.Hostname),$hostnamePingStatus,$($target.IPv4),$ipv4PingStatus,$overallStatus"

    # Añadir la línea al archivo de salida solo si no se ha omitido
    $outputLine | Out-File -FilePath $outputFilePath -Append -Encoding UTF8
}

Write-Host "Proceso completado. Resultados almacenados en $outputFilePath"
