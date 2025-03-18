# Obtener el directorio actual
$baseDir = Get-Location

# Subdirectorios principales relativos al directorio actual
$subDirs = @(
    "SI\SGSI\Pol�ticas y Procedimientos",
    "SI\SGSI\Planes de Seguridad",
    "SI\SGSI\Auditor�as Internas",
    "SI\SGSI\Certificaciones",
    "SI\Gesti�n de Vulnerabilidades\An�lisis de Vulnerabilidades\Servicios Atendidos",
    "SI\Gesti�n de Vulnerabilidades\An�lisis de Vulnerabilidades\Servicios de Terceros\Reportes de Servicios\S1 An�lisis de Vulnerabilidades en Infra\Entregables",
    "SI\Gesti�n de Vulnerabilidades\An�lisis de Vulnerabilidades\Servicios de Terceros\Reportes de Servicios\S2 AV en Aplicaciones",
    "SI\Gesti�n de Vulnerabilidades\An�lisis de Vulnerabilidades\Servicios de Terceros\Reportes de Servicios\S3 Monitoreo",
    "SI\Gesti�n de Vulnerabilidades\An�lisis de Vulnerabilidades\Servicios de Terceros\Reportes de Servicios\S4 Adversario",
    "SI\Gesti�n de Vulnerabilidades\An�lisis de Vulnerabilidades\Servicios de Terceros\Reportes de Servicios\S5 Directorio Activo",
    "SI\Gesti�n de Vulnerabilidades\An�lisis de Vulnerabilidades\Indicadores\Internos",
    "SI\Gesti�n de Vulnerabilidades\An�lisis de Vulnerabilidades\Indicadores\Externos",
    "SI\Gesti�n de Incidencias\Registros de Incidentes",
    "SI\Gesti�n de Incidencias\Planes de Contingencia",
    "SI\Gesti�n de Incidencias\Lecciones Aprendidas",
    "SI\Gesti�n de Riesgos\Evaluaci�n de Riesgos",
    "SI\Gesti�n de Riesgos\Plan de Tratamiento",
    "SI\Gesti�n de Riesgos\Matriz de Riesgos",
    "SI\Operaciones\Informaci�n Recopilada\Archivos de Herramientas\Nessus",
    "SI\Operaciones\Informaci�n Recopilada\Archivos de Herramientas\BurpSuite",
    "SI\Operaciones\Informaci�n Recopilada\Archivos de Herramientas\Nmap",
    "SI\Operaciones\Informaci�n Recopilada\Archivos de Herramientas\Wireshark",
    "SI\Operaciones\Informaci�n Recopilada\Capturas de Pantalla",
    "SI\Operaciones\Objetivos de Evaluaci�n\IPS Internas (TXT)",
    "SI\Operaciones\Objetivos de Evaluaci�n\IPS Externas (TXT)",
    "SI\Operaciones\Objetivos de Evaluaci�n\Inventario (XLSX)",
    "SI\Operaciones\Objetivos de Evaluaci�n\Resultados Operativos (XLSX)",
    "SI\Bit�cora Individual",
    "SI\Espacio de Trabajo",
    "SI\Planes\Plan de Respuesta ante Incidentes",
    "SI\Planes\Plan de Recuperaci�n ante Desastres",
    "SI\Inventarios\Activos Tecnol�gicos",
    "SI\Inventarios\Software y Licencias",
    "SI\Gesti�n de Documentos",
    "SI\Pol�ticas y Procedimientos",
    "SI\Reportes de Auditor�a",
    "SI\Documentaci�n Legal\Contratos",
    "SI\Documentaci�n Legal\Acuerdos de Confidencialidad (NDA)"
)

# Crear los directorios
foreach ($dir in $subDirs) {
    $fullPath = Join-Path -Path $baseDir -ChildPath $dir
    New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
}

Write-Host "Estructura de 'SI (SI)' creada correctamente en $baseDir"
