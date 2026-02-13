Eliminar Desktop ini
$rutaBase = "C:\Users\osvaldohm\Desktop\Base"

# Buscamos y eliminamos los archivos
# -Recurse: Busca en todas las subcarpetas
# -Force (en Get-ChildItem): Necesario porque desktop.ini suele ser un archivo oculto/sistema
# -Force (en Remove-Item): Para forzar la eliminación sin pedir confirmación
Get-ChildItem -Path $rutaBase -Filter "desktop.ini" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

Write-Host "Proceso de limpieza de desktop.ini finalizado."