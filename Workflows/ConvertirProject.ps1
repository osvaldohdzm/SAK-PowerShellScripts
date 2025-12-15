$BloqueConversion = {
    # --- CONFIGURACION ---
    $FechaHoy = Get-Date -Format "yyyyMMdd"
    $RutaOrigen = "G:\.shortcut-targets-by-id\1wF4Ly_slHBompHLRQjm2C6csKBn5Vi5W\Nuevos Proyecto\01 Gestión de Actividades\Gestión de proyectos.mpp"

    Write-Host "Iniciando proceso para fecha: $FechaHoy" -ForegroundColor Cyan

    # --- CALCULO DE RUTAS CON .NET (SOLUCION ERROR G:) ---
    try {
        # Usamos GetDirectoryName para no validar disco aun
        $DirectorioBase = [System.IO.Path]::GetDirectoryName($RutaOrigen)
        
        # Combinamos ruta segura
        $NombrePDF = "Archivo de proyectos $FechaHoy.pdf"
        $RutaDestino = [System.IO.Path]::Combine($DirectorioBase, $NombrePDF)
    } catch {
        throw "ERROR CRITICO: No se pudieron calcular las rutas. Detalle: $_"
    }

    # --- VERIFICACION DE EXISTENCIA ---
    if (-not [System.IO.File]::Exists($RutaOrigen)) {
        Write-Error "ERROR: El archivo .mpp no existe o G: no esta accesible."
        Write-Host "Ruta buscada: $RutaOrigen"
        return # Salimos del bloque
    }

    Write-Host "Archivo origen detectado." -ForegroundColor Green
    Write-Host "Destino PDF: $RutaDestino" -ForegroundColor Gray

    # --- AUTOMATIZACION MS PROJECT ---
    $MSProject = $null
    try {
        Write-Host "Abriendo MS Project en segundo plano..."
        $MSProject = New-Object -ComObject MSProject.Application
        
        if (-not $MSProject) { throw "No se pudo crear el objeto MS Project." }

        $MSProject.Visible = $false
        $MSProject.DisplayAlerts = $false

        Write-Host "Cargando archivo .mpp..."
        $MSProject.FileOpen($RutaOrigen, $true) # $true = Solo Lectura

        Write-Host "Exportando a PDF..."
        $MSProject.DocumentExport($RutaDestino, 0) # 0 = PDF

        Write-Host "EXITO: Conversion completada." -ForegroundColor Green
        Write-Host "Archivo generado en: $RutaDestino"

    } catch {
        Write-Error "FALLO DURANTE LA CONVERSION."
        Write-Host "Detalle tecnico: $($_.Exception.Message)" -ForegroundColor Red
        throw $_ # Re-lanzamos el error para que quede en el log de error
    } finally {
        # --- LIMPIEZA ---
        if ($MSProject) {
            $MSProject.FileClose($false)
            $MSProject.Quit()
            [System.Runtime.InteropServices.Marshal]::ReleaseComObject($MSProject) | Out-Null
        }
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
    }
}

# 3. EJECUCION Y GENERACION DE LOGS
# -----------------------------------------------------------------------------
# Aqui ejecutamos el bloque definido arriba y separamos lo bueno (1>) de lo malo (2>)
# Force asegura que se sobrescriban los logs viejos.

Invoke-Command -ScriptBlock $BloqueConversion 1> $LogSalida 2> $LogError