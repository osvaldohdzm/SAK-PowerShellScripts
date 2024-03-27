# Obtiene la ruta del directorio del script actual
$scriptPath = $PSScriptRoot

# Función para eliminar archivos en un directorio y sus subdirectorios
function Delete-FilesRecursively {
    param (
        [string]$directory
    )

    # Recorre todos los elementos del directorio actual
    Get-ChildItem -Path $directory | ForEach-Object {
        # Si es un archivo (no una carpeta) y no es el propio script, lo elimina
        if (-not $_.PSIsContainer -and $_.FullName -ne $scriptPath) {
            Remove-Item -Path $_.FullName -Force
            Write-Host "Archivo eliminado: $($_.FullName)"
        }
        # Si es una carpeta, llama a la función recursivamente
        elseif ($_.PSIsContainer) {
            Delete-FilesRecursively -directory $_.FullName
        }
    }
}

# Llama a la función para eliminar archivos en la carpeta actual y sus subdirectorios
Delete-FilesRecursively -directory $scriptPath
