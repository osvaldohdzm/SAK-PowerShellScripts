# Obtener el directorio actual
$baseDir = Get-Location

# Subdirectorios principales relativos al directorio actual
$subDirs = @(
    "SI\SGSI\Políticas y Procedimientos",
    "SI\SGSI\Planes de Seguridad",
    "SI\SGSI\Auditorías Internas",
    "SI\SGSI\Certificaciones",
    "SI\Gestión de Vulnerabilidades\Análisis de Vulnerabilidades\Servicios Atendidos",
    "SI\Gestión de Vulnerabilidades\Análisis de Vulnerabilidades\Servicios de Terceros\Reportes de Servicios\S1 Análisis de Vulnerabilidades en Infra\Entregables",
    "SI\Gestión de Vulnerabilidades\Análisis de Vulnerabilidades\Servicios de Terceros\Reportes de Servicios\S2 AV en Aplicaciones",
    "SI\Gestión de Vulnerabilidades\Análisis de Vulnerabilidades\Servicios de Terceros\Reportes de Servicios\S3 Monitoreo",
    "SI\Gestión de Vulnerabilidades\Análisis de Vulnerabilidades\Servicios de Terceros\Reportes de Servicios\S4 Adversario",
    "SI\Gestión de Vulnerabilidades\Análisis de Vulnerabilidades\Servicios de Terceros\Reportes de Servicios\S5 Directorio Activo",
    "SI\Gestión de Vulnerabilidades\Análisis de Vulnerabilidades\Indicadores\Internos",
    "SI\Gestión de Vulnerabilidades\Análisis de Vulnerabilidades\Indicadores\Externos",
    "SI\Gestión de Incidencias\Registros de Incidentes",
    "SI\Gestión de Incidencias\Planes de Contingencia",
    "SI\Gestión de Incidencias\Lecciones Aprendidas",
    "SI\Gestión de Riesgos\Evaluación de Riesgos",
    "SI\Gestión de Riesgos\Plan de Tratamiento",
    "SI\Gestión de Riesgos\Matriz de Riesgos",
    "SI\Operaciones\Información Recopilada\Archivos de Herramientas\Nessus",
    "SI\Operaciones\Información Recopilada\Archivos de Herramientas\BurpSuite",
    "SI\Operaciones\Información Recopilada\Archivos de Herramientas\Nmap",
    "SI\Operaciones\Información Recopilada\Archivos de Herramientas\Wireshark",
    "SI\Operaciones\Información Recopilada\Capturas de Pantalla",
    "SI\Operaciones\Objetivos de Evaluación\IPS Internas (TXT)",
    "SI\Operaciones\Objetivos de Evaluación\IPS Externas (TXT)",
    "SI\Operaciones\Objetivos de Evaluación\Inventario (XLSX)",
    "SI\Operaciones\Objetivos de Evaluación\Resultados Operativos (XLSX)",
    "SI\Bitácora Individual",
    "SI\Espacio de Trabajo",
    "SI\Planes\Plan de Respuesta ante Incidentes",
    "SI\Planes\Plan de Recuperación ante Desastres",
    "SI\Inventarios\Activos Tecnológicos",
    "SI\Inventarios\Software y Licencias",
    "SI\Gestión de Documentos",
    "SI\Políticas y Procedimientos",
    "SI\Reportes de Auditoría",
    "SI\Documentación Legal\Contratos",
    "SI\Documentación Legal\Acuerdos de Confidencialidad (NDA)"
)

# Crear los directorios
foreach ($dir in $subDirs) {
    $fullPath = Join-Path -Path $baseDir -ChildPath $dir
    New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
}

Write-Host "Estructura de 'SI (SI)' creada correctamente en $baseDir"
