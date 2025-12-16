# =============================================================================
# SCRIPT: Convertir Project a PDF (Pendientes + Semana) - ESTRATEGIA HIBRIDA
# =============================================================================

# 1. CONFIGURACION DE ENTORNO
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Definición de rutas de Log
$LogSalida = "$HOME\Desktop\Log_Proyecto_OK.txt"
$LogError  = "$HOME\Desktop\Log_Proyecto_ERROR.txt"

# 2. DEFINICION DEL BLOQUE DE LOGICA PRINCIPAL
$BloqueConversion = {
    # --- VARIABLES ---
    $FechaHoy = Get-Date -Format "yyyyMMdd"
    $RutaOrigen = "G:\.shortcut-targets-by-id\1wF4Ly_slHBompHLRQjm2C6csKBn5Vi5W\Nuevos Proyecto\01 Gestión de Actividades\Gestión de proyectos.mpp"

    Write-Host "Iniciando proceso para fecha: $FechaHoy" -ForegroundColor Cyan

    # --- CALCULO DE RUTAS ---
    try {
        $DirectorioBase = [System.IO.Path]::GetDirectoryName($RutaOrigen)
        $NombrePDF = "Seguimiento Semanal $FechaHoy (Solo Pendientes).pdf"
        $RutaDestino = [System.IO.Path]::Combine($DirectorioBase, $NombrePDF)
    } catch {
        throw "ERROR CRITICO: No se pudieron calcular las rutas. Detalle: $_"
    }

    # --- VERIFICACION DE EXISTENCIA ---
    if (-not (Test-Path -LiteralPath $RutaOrigen)) {
        throw "ERROR: El archivo .mpp no existe.`nRuta intentada: $RutaOrigen"
    }

    Write-Host "Archivo origen detectado." -ForegroundColor Green

    # --- AUTOMATIZACION MS PROJECT ---
    $MSProject = $null
    try {
        Write-Host "Abriendo MS Project en segundo plano..."
        $MSProject = New-Object -ComObject MSProject.Application
        
        if (-not $MSProject) { throw "No se pudo crear el objeto MS Project." }

        $MSProject.Visible = $false
        $MSProject.DisplayAlerts = $false

        Write-Host "Cargando archivo .mpp (Solo Lectura)..."
        $MSProject.FileOpen($RutaOrigen, $true) 

        # -----------------------------------------------------------
        # PASO 1: APLICAR FILTRO NATIVO "TAREAS INCOMPLETAS"
        # -----------------------------------------------------------
        # Esto elimina el problema de los tipos de datos en el AutoFiltro.
        # Project ya sabe qué tareas no están al 100%.
        
        Write-Host "Paso 1: Aplicando filtro base 'Tareas Incompletas'..." -ForegroundColor Yellow
        $FiltroBaseAplicado = $false

        try {
            $MSProject.FilterApply("Tareas incompletas")
            $FiltroBaseAplicado = $true
            Write-Host "-> Filtro 'Tareas incompletas' aplicado." -ForegroundColor Green
        } catch {
            try {
                # Intento en inglés si el Project está en otro idioma
                $MSProject.FilterApply("Incomplete Tasks")
                $FiltroBaseAplicado = $true
                Write-Host "-> Filtro 'Incomplete Tasks' aplicado." -ForegroundColor Green
            } catch {
                Write-Warning "No se encontró el filtro nativo de tareas incompletas. Se intentará solo con AutoFiltro."
            }
        }

        # -----------------------------------------------------------
        # PASO 2: APLICAR AUTO-FILTRO DE FECHA (SOBRE EL ANTERIOR)
        # -----------------------------------------------------------
        # Ahora que ya no vemos las tareas al 100%, filtramos por "Esta Semana"
        
        Write-Host "Paso 2: Filtrando por Fecha (Esta Semana)..." -ForegroundColor Yellow
        
        if (-not $MSProject.AutoFilter) { $MSProject.AutoFilter() }
        
        $pjAutoFilterThisWeek = 7
        
        try {
            $MSProject.SetAutoFilter("Fin", $pjAutoFilterThisWeek)
            Write-Host "-> Filtro de Fecha aplicado." -ForegroundColor Green
        } catch {
            try {
                $MSProject.SetAutoFilter("Finish", $pjAutoFilterThisWeek)
                Write-Host "-> Filtro de Fecha aplicado (Finish)." -ForegroundColor Green
            } catch {
                 Write-Warning "No se pudo aplicar el filtro de fecha."
            }
        }

        # -----------------------------------------------------------
        # PASO 3: EXPORTAR A PDF
        # -----------------------------------------------------------
        # Verificamos si quedaron tareas visibles
        $MSProject.SelectAll()
        $NumTareas = 0
        try { $NumTareas = $MSProject.ActiveSelection.Tasks.Count } catch { $NumTareas = 0 }

        if ($NumTareas -gt 0) {
            Write-Host "Generando PDF ($NumTareas tareas pendientes visibles)..."
            try {
                $MSProject.DocumentExport($RutaDestino, 0) # 0 = PDF
                Write-Host "EXITO: PDF generado en $RutaDestino" -ForegroundColor Green
            } catch {
                $MSProject.FileSaveAs($RutaDestino, 11)
                Write-Host "EXITO: PDF generado (Método Alternativo)." -ForegroundColor Green
            }
        } else {
            Write-Warning "No hay tareas pendientes para esta semana. No se generó PDF."
        }

        # --- LIMPIAR VISTA ---
        Write-Host "Restaurando vista..."
        try { $MSProject.FilterApply("Todas las tareas") } catch { $MSProject.FilterApply("All Tasks") }

    } catch {
        throw $_ 
    } finally {
        # --- CIERRE SEGURO ---
        if ($MSProject) {
            Write-Host "Cerrando MS Project sin guardar..."
            $MSProject.FileClose(0) # 0 = pjDoNotSave
            $MSProject.Quit()
            [System.Runtime.InteropServices.Marshal]::ReleaseComObject($MSProject) | Out-Null
        }
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
    }
}

# 3. EJECUCION CON UX AMIGABLE Y ASCII
# -----------------------------------------------------------------------------
try {
    # Ejecutamos el bloque principal y guardamos log
    & $BloqueConversion | Tee-Object -FilePath $LogSalida 
    
    # SI LLEGA AQUI, ES EXITO
    Write-Host "`n----------------------------------------" -ForegroundColor Gray
    Write-Host "   PROCESO FINALIZADO CORRECTAMENTE     " -BackgroundColor Green -ForegroundColor Black
    Write-Host "----------------------------------------"

    # --- GATITO ASCII ---
    Write-Host @'
   |\---/|
   | ,_, |
    \_`_/-..----.
 ___/ `   ' ,""+ \  sk
(__...'   __\    |`.___.';
  (_,...'(_,.`__)/'.....+
'@ -ForegroundColor Cyan
    # --------------------

    Write-Host "`nCerrando en 5 segundos..." -ForegroundColor Cyan
    Start-Sleep -Seconds 5
}
catch {
    # SI OCURRE ERROR
    $ErrorMessage = $_.Exception.Message
    Write-Error $ErrorMessage
    $ErrorMessage | Out-File -FilePath $LogError -Append

    Write-Host "`n----------------------------------------" -ForegroundColor Gray
    Write-Host "           OCURRIO UN ERROR             " -BackgroundColor Red -ForegroundColor White
    Write-Host "----------------------------------------"
    
    Read-Host "Presione ENTER para cerrar..."
}