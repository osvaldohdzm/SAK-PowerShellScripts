# Función para validar y convertir IPs en formato adecuado
function ConvertTo-ValidIPAddress {
    param (
        [string]$ip
    )
    if ($ip -match '^(?<octet1>\d{1,3})\.(?<octet2>\d{1,3})\.(?<octet3>\d{1,3})\.(?<octet4>\d{1,3})$') {
        return [IPAddress]::Parse($ip)
    }
    return $null
}

# Función para obtener rangos de IPs
function Obtain-IPRangesFromIPList {
    param (
        [string]$filePath
    )

    # Leer las IPs del archivo
    $ips = Get-Content $filePath | ForEach-Object { ConvertTo-ValidIPAddress $_ } | Where-Object { $_ -ne $null }

    # Agrupar y encontrar rangos
    $ranges = @{}

    foreach ($ip in $ips) {
        $base = "$($ip.IPAddressToString.Substring(0, $ip.IPAddressToString.LastIndexOf('.')))"
        $lastOctet = [int]$ip.AddressFamily - 1
        
        if (-not $ranges.ContainsKey($base)) {
            $ranges[$base] = @()
        }
        
        $ranges[$base] += $lastOctet
    }

    # Crear la salida de rangos
    $output = @()

    foreach ($base in $ranges.Keys) {
        $octets = $ranges[$base] | Sort-Object -Unique

        $start = $octets[0]
        $end = $start

        foreach ($octet in $octets[1..($octets.Count - 1)]) {
            if ($octet -eq $end + 1) {
                $end = $octet
            } else {
                if ($start -eq $end) {
                    $output += "$base.$start"
                } else {
                    $output += "$base.$start-$base.$end"
                }
                $start = $octet
                $end = $start
            }
        }

        # Agregar el rango final
        if ($start -eq $end) {
            $output += "$base.$start"
        } else {
            $output += "$base.$start-$base.$end"
        }
    }

    return $output
}

# Uso de la función
$filePath = "IP_list.txt"
$ipRanges = Obtain-IPRangesFromIPList -filePath $filePath

# Mostrar la salida
$ipRanges
