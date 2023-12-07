# vaciadorcarpeta.ps1

# Obtener la ruta de la carpeta actual
$rutaCarpeta = Get-Location

# Función para vaciar los archivos en una carpeta y sus subcarpetas
function VaciarArchivos($carpeta) {
    # Obtener la lista de archivos en la carpeta actual
    $archivos = Get-ChildItem -Path $carpeta | Where-Object { -not $_.PSIsContainer -and $_.Name -ne "vaciadorcarpeta.ps1" }

    # Eliminar cada archivo en la carpeta
    foreach ($archivo in $archivos) {
        Remove-Item $archivo.FullName -Force
    }

    # Obtener la lista de subcarpetas en la carpeta actual
    $subcarpetas = Get-ChildItem -Path $carpeta | Where-Object { $_.PSIsContainer }

    # Llamar recursivamente a la función para cada subcarpeta
    foreach ($subcarpeta in $subcarpetas) {
        VaciarArchivos $subcarpeta.FullName
    }
}

# Llamar a la función para vaciar los archivos en la carpeta actual y sus subcarpetas
VaciarArchivos $rutaCarpeta

Write-Host "Los archivos en la carpeta y sus subcarpetas han sido eliminados."
