param (
    [string]$directoryPath
)

# Definir el sufijo
$suffix = "_v4"

# Verificar si la ruta proporcionada está vacía o no es válida
if (-not $directoryPath -or -not (Test-Path $directoryPath -PathType Container)) {
    Write-Host "Uso del script: .\NombreDelScript.ps1 -d <Ruta\Del\Directorio>"
    Write-Host "Ejemplo: .\NombreDelScript.ps1 -d C:\Ruta\Del\Directorio"
    exit
}

# Obtener la lista de archivos .docx, .doc y .xlsx en el directorio (sin incluir subcarpetas)
$fileList = Get-ChildItem -Path $directoryPath | Where-Object {!$_.PSIsContainer -and $_.Extension -in ".docx", ".doc", ".xlsx"}

# Verificar si no hay archivos en la lista
if ($fileList.Count -eq 0) {
    Write-Host "No se encontraron archivos .docx, .doc o .xlsx en la ruta especificada: $directoryPath"
    exit
}

# Recorrer la lista de archivos y agregar el sufijo solo a los archivos en la ruta principal
foreach ($file in $fileList) {
    $newName = $file.BaseName + $suffix + $file.Extension
    $newPath = Join-Path -Path $directoryPath -ChildPath $newName

    # Renombrar el archivo
    Rename-Item -Path $file.FullName -NewName $newPath
}

Write-Host "Proceso completado. Se agregó el sufijo '$suffix' a los nombres de los archivos .docx, .doc y .xlsx en la ruta: $directoryPath"
