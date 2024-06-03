# Ruta de origen
$origen = "D:\Program Files"

# Ruta de destino para los enlaces simbólicos
$destino = "C:\Program Files"

# Verifica si la carpeta de destino existe, si no, la crea
if (-not (Test-Path -Path $destino -PathType Container)) {
    New-Item -ItemType Directory -Path $destino | Out-Null
}

# Obtiene la lista de carpetas en el directorio de origen
$carpetas = Get-ChildItem -Path $origen -Directory

# Crea enlaces simbólicos en la carpeta de destino
foreach ($carpeta in $carpetas) {
    $origenCarpeta = Join-Path -Path $origen -ChildPath $carpeta.Name
    $destinoCarpeta = Join-Path -Path $destino -ChildPath $carpeta.Name

    # Crea el enlace simbólico
    New-Item -ItemType SymbolicLink -Path $destinoCarpeta -Target $origenCarpeta -Force
}

Write-Host "Enlaces simbólicos creados exitosamente."
