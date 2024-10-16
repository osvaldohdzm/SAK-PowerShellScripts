# Define el archivo CSV de entrada y salida
$InputCsv = "input.csv"
$OutputCsv = "output.csv"

# Define el servidor DNS para consultas
$DnsServer = "8.8.8.8"  # Cambia esto a tu servidor DNS preferido

# Lee el archivo CSV sin encabezados
$csvContent = Import-Csv -Path $InputCsv -Header "IPv6 Pública", "IPv4 Pública", "FQDN Público" -Delimiter ','

# Lista de resultados finales
$FinalResult = @()

foreach ($row in $csvContent) {
    $ipv6 = $row.'IPv6 Pública'
    $ipv4 = $row.'IPv4 Pública'
    $fqdn = $row.'FQDN Público'

    # Crea un objeto temporal para almacenar los datos
    $tempObj = "" | Select-Object 'IPv6 Pública', 'IPv4 Pública', 'FQDN Público', 'Status', 'ErrorMessage'

    # Rellenar IPv4 si falta
    if ([string]::IsNullOrWhiteSpace($ipv4) -and -not [string]::IsNullOrWhiteSpace($fqdn)) {
        try {
            $dnsResult = Resolve-DnsName -Name $fqdn -Server $DnsServer -ErrorAction Stop
            $ipv4 = ($dnsResult | Where-Object { $_.QueryType -eq 'A' }).IPAddress -join ','
        }
        catch {
            $ipv4 = ''
        }
    }

    # Rellenar FQDN si falta
    if ([string]::IsNullOrWhiteSpace($fqdn) -and -not [string]::IsNullOrWhiteSpace($ipv4)) {
        try {
            $dnsResult = Resolve-DnsName -Name $ipv4 -Server $DnsServer -ErrorAction Stop
            $fqdn = $dnsResult.NameHost
        }
        catch {
            $fqdn = ''
        }
    }

    # Rellenar IPv6 si falta
    if ([string]::IsNullOrWhiteSpace($ipv6) -and -not [string]::IsNullOrWhiteSpace($fqdn)) {
        try {
            $dnsResult = Resolve-DnsName -Name $fqdn -Server $DnsServer -ErrorAction Stop
            $ipv6 = ($dnsResult | Where-Object { $_.QueryType -eq 'AAAA' }).IPAddress -join ','
        }
        catch {
            $ipv6 = ''
        }
    }

    # Asigna los valores al objeto temporal
    $tempObj.'IPv6 Pública' = $ipv6
    $tempObj.'IPv4 Pública' = $ipv4
    $tempObj.'FQDN Público' = $fqdn

    # Establece el estado y mensaje de error
    if ([string]::IsNullOrWhiteSpace($ipv4) -or [string]::IsNullOrWhiteSpace($fqdn)) {
        $tempObj.Status = 'NOT_OK'
        $tempObj.ErrorMessage = 'No se pudo completar todos los campos'
    }
    else {
        $tempObj.Status = 'OK'
        $tempObj.ErrorMessage = ''
    }

    # Agrega el objeto a la lista final
    $FinalResult += $tempObj
}

# Exporta el resultado final a un archivo CSV con cabeceras
$FinalResult | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8
