# =============================================================================
# SCRIPT: Mover Reportes (Corrección de Acentos y Rutas)
# =============================================================================

# 1. ELIMINAR FORZADO DE UTF8 (Para evitar errores de BOM en sistemas locales)
# PowerShell detectará la codificación del archivo automáticamente.

Write-Output "Iniciando búsqueda de rutas..."

# 2. DEFINIR LA RUTA USANDO COMODINES PARA EVITAR EL ACENTO EN "Gestión"
# En lugar de escribir "01 Gestión de Proyectos", usamos "01 Gesti*"
$ContenedorBase = "C:\Users\osvaldohm\Desktop\Base\04 Proyectos"

# 3. LOCALIZAR LA CARPETA DE ORIGEN DINÁMICAMENTE
if (Test-Path -Path $ContenedorBase) {
    
    # Buscamos la carpeta que empiece con "03 Gesti" dentro de la carpeta de Proyectos
    $CarpetaProyecto = Get-ChildItem -Path $ContenedorBase -Directory | Where-Object { $_.Name -like "03 Gesti*" } | Select-Object -First 1
    
    if ($CarpetaProyecto) {
        $RutaOrigen = $CarpetaProyecto.FullName
        $RutaDestino = Join-Path -Path $RutaOrigen -ChildPath "Archivos anteriores"
        
        Write-Output "Ruta detectada correctamente: $RutaOrigen"

        # --- 4. EJECUTAR EL MOVIMIENTO ---
        # Crear carpeta de destino si no existe
        if (-not (Test-Path -Path $RutaDestino)) {
            New-Item -ItemType Directory -Path $RutaDestino -Force | Out-Null
            Write-Output "Carpeta 'Archivos anteriores' creada."
        }

        # Listar PDFs para mover
        $archivos = Get-ChildItem -Path $RutaOrigen -Filter "*.pdf" -File
        
        if ($archivos.Count -gt 0) {
            foreach ($archivo in $archivos) {
                try {
                    # No movemos archivos que ya estén en la carpeta de destino o el script mismo
                    Move-Item -Path $archivo.FullName -Destination $RutaDestino -Force -ErrorAction Stop
                    Write-Output "Movido con éxito: $($archivo.Name)"
                } catch {
                    Write-Host "No se pudo mover $($archivo.Name). Tal vez está abierto." -ForegroundColor Yellow
                }
            }
        } else {
            Write-Output "No se encontraron archivos PDF para mover."
        }

    } else {
        Write-Error "ERROR: No se encontró la subcarpeta '01 Gestión...' dentro de $ContenedorBase"
    }
}
else {
    Write-Error "ERROR CRÍTICO: No se encuentra la ruta base: $ContenedorBase"
    Write-Host "Verifica que la carpeta '04 Proyectos' exista en tu Escritorio." -ForegroundColor Red
}

# Pausa breve para ver el resultado
Start-Sleep -Seconds 3