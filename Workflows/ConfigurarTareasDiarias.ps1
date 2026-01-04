# --- BLOQUE DE AUTO-ELEVACIÓN DE PRIVILEGIOS ---
$Principal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Solicitando permisos de Administrador..." -ForegroundColor Yellow
    $NewProcess = Start-Process -FilePath "PowerShell.exe" `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" `
        -Verb RunAs `
        -PassThru
    Exit
}

# --- INICIO DEL SCRIPT ---
Write-Host "Iniciando configuración de Workflow Multitarea..." -ForegroundColor Cyan
$GlobalHuboErrores = $false

# ==============================================================================
# 1. CONFIGURACIÓN: GRUPOS DE TAREAS
# ==============================================================================
# Aquí defines cada "Bloque" como un objeto dentro del array @().
# Puedes agregar tantos bloques como necesites copiando la estructura @{ ... }.

$GruposDeTareas = @(
    # --- GRUPO 1: MAÑANA (9:00 AM) ---
    @{
        Nombre  = "SAK_Workflow_Matutino"
        Hora    = "9:00AM"
        Scripts = @(
            "C:\Users\osvaldohm\Desktop\Repositorios\SAK-PowerShellScripts\Workflows\MoverReporteDeProyectosAnteriores.ps1",
            "C:\Users\osvaldohm\Desktop\Repositorios\SAK-PowerShellScripts\Workflows\ConvertirProjectSemana.ps1",
            "C:\Users\osvaldohm\Desktop\Repositorios\SAK-PowerShellScripts\Workflows\ConvertirProjectSemanaPendientes.ps1",
            "C:\Users\osvaldohm\Desktop\Repositorios\SAK-PowerShellScripts\Workflows\ConvertirProjectHistorico.ps1"
        )
    },

    # --- GRUPO 2: TARDE (4:00 PM) ---
    @{
        Nombre  = "SAK_Workflow_Vespertino"
        Hora    = "18:30" # Formato 24h o 4:00PM
        Scripts = @(
            "C:\Users\osvaldohm\Desktop\Repositorios\SAK-PowerShellScripts\Workflows\Convertir-Docs.ps1"
            # Puedes agregar más scripts aquí para la tarde
        )
    }
    
    # --- GRUPO 3: EJEMPLO EXTRA (Descomentar para usar) ---
    # @{
    #     Nombre  = "SAK_Mantenimiento_Nocturno"
    #     Hora    = "23:00"
    #     Scripts = @(
    #         "C:\Ruta\ScriptX.ps1"
    #     )
    # }
)

# Usuario actual para registrar la tarea (detectado automáticamente)
$UsuarioActual = $env:USERNAME

# ==============================================================================
# 2. PROCESAMIENTO DE CADA GRUPO
# ==============================================================================

foreach ($Grupo in $GruposDeTareas) {
    Write-Host "`n------------------------------------------------------"
    Write-Host "Procesando Grupo: $($Grupo.Nombre)" -ForegroundColor Cyan
    Write-Host "Horario: $($Grupo.Hora)" -ForegroundColor Gray
    
    $HuboErroresEnGrupo = $false
    $ComandosArray = @()

    # --- Validación de rutas para este grupo ---
    foreach ($ScriptPath in $Grupo.Scripts) {
        if (Test-Path $ScriptPath) {
            Write-Host " [OK] Encontrado: $ScriptPath" -ForegroundColor Green
            # Construimos el comando: & 'Ruta'
            $ComandosArray += "& '$ScriptPath'"
        }
        else {
            Write-Host " [ERROR] No existe: $ScriptPath" -ForegroundColor Red
            $HuboErroresEnGrupo = $true
            $GlobalHuboErrores = $true
        }
    }

    # --- Registro de la tarea si no hay errores en este grupo ---
    if ($HuboErroresEnGrupo) {
        Write-Host "Se omitirá la creación de la tarea '$($Grupo.Nombre)' por errores en rutas." -ForegroundColor Red
    }
    else {
        # Unimos comandos con punto y coma para ejecución secuencial
        $CadenaDeComandos = $ComandosArray -join "; "
        $Descripcion = "Ejecuta secuencia de $($Grupo.Scripts.Count) scripts para el grupo $($Grupo.Nombre)."

        Write-Host "Registrando tarea en Windows..." -NoNewline

        $Trigger = New-ScheduledTaskTrigger -Daily -At $Grupo.Hora
        
        # Acción: PowerShell ejecuta la cadena completa
        $Accion = New-ScheduledTaskAction -Execute "powershell.exe" `
            -Argument "-NoProfile -ExecutionPolicy Bypass -Command `"$CadenaDeComandos`""

        try {
            # Se usa $UsuarioActual para que corra bajo tu usuario
            Register-ScheduledTask -TaskName $Grupo.Nombre `
                -Action $Accion `
                -Trigger $Trigger `
                -Description $Descripcion `
                -User $UsuarioActual `
                -Force -ErrorAction Stop | Out-Null
            
            Write-Host " [OK]" -ForegroundColor Green
            Write-Host "Tarea '$($Grupo.Nombre)' programada exitosamente a las $($Grupo.Hora)." -ForegroundColor Cyan
        }
        catch {
            Write-Host " [ERROR]" -ForegroundColor Red
            Write-Error "Fallo al registrar '$($Grupo.Nombre)'. Razón: $_"
            $GlobalHuboErrores = $true
        }
    }
}

# ==============================================================================
# 3. CIERRE
# ==============================================================================
Write-Host "`n======================================================"

if ($GlobalHuboErrores) {
    Write-Host "El proceso finalizó con ALGUNOS ERRORES." -ForegroundColor Red
    Write-Host "Revisa los mensajes rojos arriba."
    Write-Host "Presione ENTER para cerrar la ventana..." -ForegroundColor Yellow
    Read-Host
}
else {
    Write-Host "Todas las configuraciones se completaron exitosamente." -ForegroundColor Cyan
    Write-Host "Esta ventana se cerrará en 3 segundos..."
    Start-Sleep -Seconds 3
}