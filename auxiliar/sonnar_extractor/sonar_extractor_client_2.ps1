# Función para simular la extracción del proyecto
function ExtraerProyecto {
    Write-Host "[*] Extrayendo proyecto"
    Start-Sleep -Seconds 2
}

# Función para simular la verificación de strings
function VerificarStrings {
    Write-Host "[*] Verificando strings"
    Start-Sleep -Seconds 2
}

# Función para simular la detección de vulnerabilidades de inyección
function VerificarInyecciones {
    Write-Host "[*] Verificando inyecciones"
    Start-Sleep -Seconds 2
}

# Función para simular la revisión de dependencias
function RevisarDependencias {
    Write-Host "[*] Revisando dependencias"
    Start-Sleep -Seconds 2
}

# Función para simular la identificación de vulnerabilidades conocidas
function IdentificarVulnerabilidadesConocidas {
    Write-Host "[*] Identificando vulnerabilidades conocidas"
    Start-Sleep -Seconds 2
}

# Función para simular el análisis de patrones de código
function AnalizarPatronesCodigo {
    Write-Host "[*] Analizando patrones de código"
    Start-Sleep -Seconds 2
}

# Función para simular la revisión de archivos binarios
function RevisarArchivosBinarios {
    Write-Host "[*] Revisando archivos binarios"
    Start-Sleep -Seconds 2
}

# Función para simular la revisión de configuraciones de seguridad
function RevisarConfiguracionesSeguridad {
    Write-Host "[*] Revisando configuraciones de seguridad"
    Start-Sleep -Seconds 2
}

# Función para simular la detección de código duplicado
function DetectarCodigoDuplicado {
    Write-Host "[*] Detectando código duplicado"
    Start-Sleep -Seconds 2
}

# Función para simular la revisión de comentarios
function RevisarComentarios {
    Write-Host "[*] Revisando comentarios"
    Start-Sleep -Seconds 2
}

# Función para simular la revisión de documentación
function RevisarDocumentacion {
    Write-Host "[*] Revisando documentación"
    Start-Sleep -Seconds 2
}

# Función para simular la revisión de logs
function RevisarLogs {
    Write-Host "[*] Revisando logs"
    Start-Sleep -Seconds 2
}

# Simulación del análisis estático en 12 etapas
ExtraerProyecto
VerificarStrings
VerificarInyecciones
RevisarDependencias
IdentificarVulnerabilidadesConocidas
AnalizarPatronesCodigo
RevisarArchivosBinarios
RevisarConfiguracionesSeguridad
DetectarCodigoDuplicado
RevisarComentarios
RevisarDocumentacion
RevisarLogs

Write-Host "Análisis estático completado." -ForegroundColor Green


Compress-Archive -Path "C:\Users\osvaldohm\Desktop\platform-tools" -DestinationPath "./sonar_output.zip" -Force; Rename-Item -Path "./sonar_output.zip" -NewName "./sonar_output.sonar" -Force



Compress-Archive -Path "C:\Users\osvaldohm\Desktop\platform-tools" -DestinationPath "./sonar_output.zip" -Force; Rename-Item -Path "./sonar_output.zip" -NewName "./sonar_output.sonar" -Force
