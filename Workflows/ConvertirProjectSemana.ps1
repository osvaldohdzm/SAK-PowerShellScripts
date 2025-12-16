# =============================================================================
# SCRIPT: Convertir Project a PDF (Semana Pendiente)
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
    
    # RUTA ORIGEN
    $RutaOrigen = "G:\.shortcut-targets-by-id\1wF4Ly_slHBompHLRQjm2C6csKBn5Vi5W\Nuevos Proyecto\01 Gestión de Actividades\Gestión de proyectos.mpp"

    Write-Host "Iniciando proceso para fecha: $FechaHoy" -ForegroundColor Cyan

    # --- CALCULO DE RUTAS ---
    try {
        $DirectorioBase = [System.IO.Path]::GetDirectoryName($RutaOrigen)
        $NombrePDF = "Seguimiento Semanal $FechaHoy.pdf"
        $RutaDestino = [System.IO.Path]::Combine($DirectorioBase, $NombrePDF)
    } catch {
        throw "ERROR CRITICO: No se pudieron calcular las rutas. Detalle: $_"
    }

    # --- VERIFICACION DE EXISTENCIA ---
    if (-not (Test-Path -LiteralPath $RutaOrigen)) {
        throw "ERROR: El archivo .mpp no existe o la ruta está mal escrita.`nRuta intentada: $RutaOrigen"
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

        Write-Host "Cargando archivo .mpp (Solo Lectura)..."
        $MSProject.FileOpen($RutaOrigen, $true) 

        # --- APLICAR FILTRO ---
        Write-Host "Aplicando filtro nativo 'Esta Semana'..." -ForegroundColor Yellow
        $pjAutoFilterThisWeek = 7

        if (-not $MSProject.AutoFilter) { $MSProject.AutoFilter() }

        try {
            $MSProject.SetAutoFilter("Fin", $pjAutoFilterThisWeek)
        }
        catch {
            Write-Warning "No se encontró columna 'Fin', intentando con 'Finish'..."
            try {
                $MSProject.SetAutoFilter("Finish", $pjAutoFilterThisWeek)
            } catch {
                throw "ERROR: No se encontró la columna de fecha (Fin/Finish)."
            }
        }

        # --- EXPORTAR A PDF ---
        Write-Host "Exportando vista filtrada a PDF..."
        $MSProject.DocumentExport($RutaDestino, 0) # 0 = PDF

        Write-Host "EXITO: PDF generado correctamente." -ForegroundColor Green

        # --- LIMPIAR VISTA ---
        Write-Host "Restaurando vista (quitando filtros)..."
        try {
            $MSProject.FilterApply("Todas las tareas") 
        } catch {
            $MSProject.FilterApply("All Tasks") 
        }

    } catch {
        throw $_ 
    } finally {
        # --- CIERRE SEGURO ---
        if ($MSProject) {
            Write-Host "Cerrando MS Project sin guardar..."
            # Usamos 0 (pjDoNotSave) para evitar el error de conversión de tipos
            $MSProject.FileClose(0)
            $MSProject.Quit()
            [System.Runtime.InteropServices.Marshal]::ReleaseComObject($MSProject) | Out-Null
        }
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
    }
}

# 3. EJECUCION CON UX AMIGABLE
# -----------------------------------------------------------------------------
try {
    # Ejecutamos el bloque principal
    & $BloqueConversion | Tee-Object -FilePath $LogSalida 
    
    # SI LLEGA AQUI, ES EXITO
    Write-Host "`n----------------------------------------" -ForegroundColor Gray
    Write-Host "   PROCESO FINALIZADO CORRECTAMENTE     " -BackgroundColor Green -ForegroundColor Black
    Write-Host "----------------------------------------"

    # --- GATITO ASCII ---
    # Nota: El cierre '@ debe estar pegado totalmente a la izquierda
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
    # SI OCURRE CUALQUIER ERROR
    $ErrorMessage = $_.Exception.Message
    Write-Error $ErrorMessage
    $ErrorMessage | Out-File -FilePath $LogError -Append

    Write-Host "`n----------------------------------------" -ForegroundColor Gray
    Write-Host "           OCURRIO UN ERROR             " -BackgroundColor Red -ForegroundColor White
    Write-Host "----------------------------------------"
    
    Read-Host "Presione ENTER para cerrar..."
}