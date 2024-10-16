# Obtener el directorio donde se encuentra el script
$scriptDir = (Get-Location)

# Buscar y eliminar todas las carpetas llamadas "Versiones_anteriores" en el directorio y subdirectorios
Get-ChildItem -Path $scriptDir -Recurse -Directory -Filter "Versiones_anteriores" | ForEach-Object {
    Remove-Item -Path $_.FullName -Recurse -Force
    Write-Host "Eliminada carpeta: $($_.FullName)"
}

Write-Host "Proceso completado."
