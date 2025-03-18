# Obtener el directorio actual
$baseDir = Get-Location

# Lista de subdirectorios a crear
$subDirs = @(
    "Proyecto\Documentación del Proyecto",
    "Proyecto\Operativos del Proyecto\Herramientas",
    "Proyecto\Operativos del Proyecto\Scripts",
    "Proyecto\Espacio de Trabajo",
    "Proyecto\Servicios\Operativos del Servicio\Ejemplo - 2024\01_Junio",
    "Proyecto\Servicios\Operativos del Servicio\P1_Mes_10_Ago_23_Sep_23",
    "Proyecto\Servicios\Operativos del Servicio\Servicio de Seguridad\PTI-CG",
    "Proyecto\Servicios\Operativos del Servicio\Servicio de Seguridad\PTECN",
    "Proyecto\Servicios\Operativos del Servicio\Objetivos de Evaluación\IPs Internas (TXT)",
    "Proyecto\Servicios\Operativos del Servicio\Objetivos de Evaluación\IPs Externas (TXT)",
    "Proyecto\Servicios\Operativos del Servicio\Objetivos de Evaluación\Inventario (XLSX)",
    "Proyecto\Servicios\Operativos del Servicio\Material de Evaluación\Código Fuente",
    "Proyecto\Servicios\Operativos del Servicio\Material de Evaluación\Aplicaciones",
    "Proyecto\Servicios\Operativos del Servicio\Información Recopilada\Archivos de Herramientas\Nessus",
    "Proyecto\Servicios\Operativos del Servicio\Información Recopilada\Archivos de Herramientas\BurpSuite",
    "Proyecto\Servicios\Operativos del Servicio\Información Recopilada\Archivos de Herramientas\Nmap",
    "Proyecto\Servicios\Operativos del Servicio\Información Recopilada\Archivos de Herramientas\Wireshark",
    "Proyecto\Servicios\Operativos del Servicio\Información Recopilada\Capturas de Pantalla",
    "Proyecto\Servicios\Operativos del Servicio\Resultados Operativos (XLSX)",
    "Proyecto\Servicios\Operativos del Servicio\Información Adicional",
    "Proyecto\Servicios\Presentaciones\Avance de Ejecución (PPTX)",
    "Proyecto\Servicios\Entregables Editables\S1",
    "Proyecto\Servicios\Entregables Editables\Entregables en Revisión",
    "Proyecto\Servicios\Entregables Finales",
    "Proyecto\Servicios\Entregas para Cliente",
    "Proyecto\Servicios\Documentación de Servicio\Anexo Técnico",
    "Proyecto\Servicios\Documentación de Servicio\Orden de Servicio (SOW)",
    "Proyecto\Servicios\Documentación de Servicio\NDA (Non-Disclosure Agreement)"
)

# Crear los directorios
foreach ($dir in $subDirs) {
    $fullPath = Join-Path -Path $baseDir -ChildPath $dir
    New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
}

Write-Host "Estructura creada correctamente en $baseDir"
