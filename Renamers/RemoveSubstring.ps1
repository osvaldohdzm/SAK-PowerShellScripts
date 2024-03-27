param (
    [string]$directoryPath
)

# Definir la subcadena a eliminar
$substringToRemove = "_v4"

# Verificar si la ruta proporcionada está vacía o no es válida
if (-not $directoryPath -or -not (Test-Path $directoryPath -PathType Container)) {
    Write-Host "Uso del script: .\NombreDelScript.ps1 -d <Ruta\Del\Directorio>"
    Write-Host "Ejemplo: .\NombreDelScript.ps1 -d C:\Ruta\Del\Directorio"
    exit
}

$wildcards = @(".docx", ".doc", ".xls")

# Obtener la lista de archivos .docx, .doc y .xlsx en el directorio (sin incluir subcarpetas)
$fileList = Get-ChildItem -Path $directoryPath | Where-Object {$_.Extension -in $wildcards} | Where-Object {!$_.PSIsContainer}

# Verificar si no hay archivos en la lista
if ($fileList.Count -eq 0) {
    Write-Host "No se encontraron archivos .docx, .doc o .xlsx en la ruta especificada: $directoryPath"
    exit
}

# Recorrer la lista de archivos y eliminar la subcadena del nombre
foreach ($file in $fileList) {
    $newName = $file.BaseName -replace $substringToRemove
    $newPath = Join-Path -Path $directoryPath -ChildPath "$($newName)$($file.Extension)"

    # Renombrar el archivo
    try {
        Rename-Item -Path $file.FullName -NewName $newPath -ErrorAction Stop
    }
    catch {
        Write-Host "Error al intentar renombrar el archivo $($file.FullName): $_"
    }
}

Write-Host "Proceso completado. Se eliminó la subcadena '$substringToRemove' de los nombres de los archivos .docx, .doc y .xlsx en la ruta: $directoryPath"
