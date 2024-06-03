# Función para obtener la información de geolocalización de una IP
function Get-IPGeolocation {
    param (
        [string]$IPAddress
    )

    $firstSourceUri = "https://ipapi.co/$IPAddress/json/"
    $secondSourceUri = "https://www.ip2location.com/demo/$IPAddress"
    $thirdSourceUri = "https://www.whatismyip.com/ip/$IPAddress/"

    # Primer intento
    try {
        Write-Host "Intentando obtener la geolocalización de $IPAddress desde $firstSourceUri"
        $response = Invoke-RestMethod -Uri $firstSourceUri -Method Get
        $region = $response.country_name
        if (-not $region) {
            throw "No se pudo obtener la región desde $firstSourceUri"
        }
        $response = [PSCustomObject]@{
            ip = $IPAddress
            region = $region
        }
    } catch {
        Write-Host "Error al obtener la geolocalización desde $firstSourceUri"
        # Si hay un error, intentamos con la segunda fuente
        try {
            Write-Host "Intentando obtener la geolocalización de $IPAddress desde $secondSourceUri"
            $html = Invoke-WebRequest -Uri $secondSourceUri -Method Get
            $region = $html.ParsedHtml.getElementsByTagName("td") | Where-Object { $_.innerText -eq "England" } | Select-Object -First 1 -ExpandProperty innerText
            $response = [PSCustomObject]@{
                ip = $IPAddress
                region = $region
            }
        } catch {
            Write-Host "Error al obtener la geolocalización desde $secondSourceUri"
            # Si también falla, intentamos con la tercera fuente
            try {
                Write-Host "Intentando obtener la geolocalización de $IPAddress desde $thirdSourceUri"
                $html = Invoke-WebRequest -Uri $thirdSourceUri -Method Get
                $country = $html.ParsedHtml.getElementsByClassName("list-group-item") | Where-Object { $_.innerText -like "Country:*" } | ForEach-Object { $_.innerText -replace "Country:", "" }
                $response = [PSCustomObject]@{
                    ip = $IPAddress
                    region = $country
                }
            } catch {
                Write-Host "Error al obtener la geolocalización desde $thirdSourceUri"
            }
        }
    }

    return $response
}

# Ruta del archivo de entrada y salida
$inputFile = Join-Path -Path $PSScriptRoot -ChildPath "IPs-list.txt"
$outputFile = Join-Path -Path $PSScriptRoot -ChildPath "output.csv"

# Array para almacenar resultados
$results = @()

# Leer el archivo de entrada y obtener información de geolocalización para cada IP
Get-Content $inputFile | ForEach-Object {
    $ip = $_
    $geolocation = Get-IPGeolocation -IPAddress $ip

    if ($geolocation -ne $null) {
        $result = [PSCustomObject]@{
            IP = $geolocation.ip
            Region = $geolocation.region
        }

        $results += $result
    }
}

# Convertir el array de resultados en un objeto CSV y guardarlo en un archivo
$results | Export-Csv -Path $outputFile -NoTypeInformation

# Mostrar el contenido del archivo CSV como HTML
ConvertTo-Html -Path $outputFile
