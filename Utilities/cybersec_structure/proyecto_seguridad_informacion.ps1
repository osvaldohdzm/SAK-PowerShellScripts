# Obtener el directorio actual
$baseDir = Get-Location

# Lista de subdirectorios a crear
$subDirs = @(
    "Proyecto\Documentaci�n del Proyecto",
    "Proyecto\Operativos del Proyecto\Herramientas",
    "Proyecto\Operativos del Proyecto\Scripts",
    "Proyecto\Espacio de Trabajo",
    "Proyecto\Servicios\Operativos del Servicio\Ejemplo - 2024\01_Junio",
    "Proyecto\Servicios\Operativos del Servicio\P1_Mes_10_Ago_23_Sep_23",
    "Proyecto\Servicios\Operativos del Servicio\Servicio de Seguridad\PTI-CG",
    "Proyecto\Servicios\Operativos del Servicio\Servicio de Seguridad\PTECN",
    "Proyecto\Servicios\Operativos del Servicio\Objetivos de Evaluaci�n\IPs Internas (TXT)",
    "Proyecto\Servicios\Operativos del Servicio\Objetivos de Evaluaci�n\IPs Externas (TXT)",
    "Proyecto\Servicios\Operativos del Servicio\Objetivos de Evaluaci�n\Inventario (XLSX)",
    "Proyecto\Servicios\Operativos del Servicio\Material de Evaluaci�n\C�digo Fuente",
    "Proyecto\Servicios\Operativos del Servicio\Material de Evaluaci�n\Aplicaciones",
    "Proyecto\Servicios\Operativos del Servicio\Informaci�n Recopilada\Archivos de Herramientas\Nessus",
    "Proyecto\Servicios\Operativos del Servicio\Informaci�n Recopilada\Archivos de Herramientas\BurpSuite",
    "Proyecto\Servicios\Operativos del Servicio\Informaci�n Recopilada\Archivos de Herramientas\Nmap",
    "Proyecto\Servicios\Operativos del Servicio\Informaci�n Recopilada\Archivos de Herramientas\Wireshark",
    "Proyecto\Servicios\Operativos del Servicio\Informaci�n Recopilada\Capturas de Pantalla",
    "Proyecto\Servicios\Operativos del Servicio\Resultados Operativos (XLSX)",
    "Proyecto\Servicios\Operativos del Servicio\Informaci�n Adicional",
    "Proyecto\Servicios\Presentaciones\Avance de Ejecuci�n (PPTX)",
    "Proyecto\Servicios\Entregables Editables\S1",
    "Proyecto\Servicios\Entregables Editables\Entregables en Revisi�n",
    "Proyecto\Servicios\Entregables Finales",
    "Proyecto\Servicios\Entregas para Cliente",
    "Proyecto\Servicios\Documentaci�n de Servicio\Anexo T�cnico",
    "Proyecto\Servicios\Documentaci�n de Servicio\Orden de Servicio (SOW)",
    "Proyecto\Servicios\Documentaci�n de Servicio\NDA (Non-Disclosure Agreement)"
)

# Crear los directorios
foreach ($dir in $subDirs) {
    $fullPath = Join-Path -Path $baseDir -ChildPath $dir
    New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
}

Write-Host "Estructura creada correctamente en $baseDir"
