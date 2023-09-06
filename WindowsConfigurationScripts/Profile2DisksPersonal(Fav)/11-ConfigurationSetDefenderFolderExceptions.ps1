# Eliminar archivos temporales
Remove-Item -Path "$env:TEMP\*" -Force -Recurse

# Optimizar unidades C y D
Optimize-Volume -DriveLetter C -Defrag -Verbose

# Ejecutar Liberador de espacio en disco en la unidad C
Invoke-Expression "cleanmgr.exe /sagerun:1"

# Obtener la ubicación de la carpeta de descargas desde Shell Folders
$shell = New-Object -ComObject Shell.Application
$downloads = $shell.NameSpace('shell:Downloads')
$downloadsPath = $downloads.Self.Path

# Eliminar archivos en la carpeta de descargas excepto .pdf, .xlsx, .docx y .pptx
$extensionsToKeep = @(".pdf", ".xlsx", ".docx", ".pptx")
$filesToDelete = Get-ChildItem -Path $downloadsPath | Where-Object { $_.Extension -notin $extensionsToKeep }
$filesToDelete | Remove-Item -Force

Write-Host "Tareas de limpieza completadas."
