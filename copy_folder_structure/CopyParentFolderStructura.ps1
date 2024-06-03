# Ruta de origen
$origen = "C:\Program Files"

# Ruta de destino
$destino = "D:\Program Files"

# Verifica si la carpeta de destino existe, si no, la crea
if (-not (Test-Path -Path $destino -PathType Container)) {
    New-Item -ItemType Directory -Path $destino | Out-Null
}

# Obtiene la lista de carpetas en el primer nivel de la carpeta de origen
$carpetas = Get-ChildItem -Path $origen -Directory

# Copia la estructura de carpetas al destino
foreach ($carpeta in $carpetas) {
    $destinoCarpeta = Join-Path -Path $destino -ChildPath $carpeta.Name
    New-Item -ItemType Directory -Path $destinoCarpeta | Out-Null
}

Write-Host "Estructura de carpetas del primer nivel copiada exitosamente."
