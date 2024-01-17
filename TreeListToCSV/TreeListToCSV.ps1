# Obtiene la ruta de la carpeta actual
$carpetaActual = Get-Location

# Obtiene la lista de elementos en la carpeta actual y sus subcarpetas
$elementos = Get-ChildItem -Recurse

# Selecciona las propiedades deseadas para el CSV
$datos = $elementos | Select-Object Name, @{Name='Folder'; Expression={Split-Path -Parent $_.FullName}}, FullName, Extension, Length, LastWriteTime, CreationTime

# Exporta los datos a un archivo CSV en la carpeta actual
$datos | Export-Csv -Path "$carpetaActual\FolderTree.csv" -NoTypeInformation

Write-Host "Archivo CSV creado en: $carpetaActual\FolderTree.csv"
