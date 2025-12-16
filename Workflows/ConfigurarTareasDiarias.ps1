# --- BLOQUE DE AUTO-ELEVACIÓN DE PRIVILEGIOS ---
$Principal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "El script no tiene permisos de Administrador. Solicitando elevación..." -ForegroundColor Yellow
    
    # Reinicia el script actual con el verbo 'RunAs' para pedir permisos de admin
    $NewProcess = Start-Process -FilePath "PowerShell.exe" `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" `
        -Verb RunAs `
        -PassThru
    
    # Cierra la ventana actual (sin permisos) para dejar solo la nueva (con permisos)
    Exit
}

# --- A PARTIR DE AQUÍ SE EJECUTA COMO ADMINISTRADOR ---
Write-Host "Permisos de Administrador concedidos. Iniciando configuración..." -ForegroundColor Cyan

# --- Configuración de Rutas y Horarios ---

# Rutas exactas solicitadas
$Script1 = "C:\Users\osvaldohm\Desktop\SAK-PowerShellScripts\Workflows\ConvertirProjectSemana.ps1"
$Script2 = "C:\Users\osvaldohm\Desktop\SAK-PowerShellScripts\Workflows\ConvertirProjectSemanaPendientes.ps1"

# Horarios: 9:00 AM y 8:00 PM
$Trigger1 = New-ScheduledTaskTrigger -Daily -At "9:00AM"
$Trigger2 = New-ScheduledTaskTrigger -Daily -At "8:00PM"
$MisTriggers = @($Trigger1, $Trigger2)

# --- Función para crear tareas ---
Function Registrar-TareaPersonalizada {
    param (
        [string]$Nombre,
        [string]$RutaScript,
        [string]$Descripcion
    )

    Write-Host "Configurando: $Nombre..." -NoNewline

    # Acción: Ejecutar PowerShell oculto/minimizado o normal
    $Accion = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$RutaScript`""

    try {
        # Se registra la tarea para el usuario específico 'osvaldohm'
        # Force = Sobrescribe si ya existe
        Register-ScheduledTask -TaskName $Nombre `
                               -Action $Accion `
                               -Trigger $MisTriggers `
                               -Description $Descripcion `
                               -User "osvaldohm" `
                               -Force | Out-Null
        
        Write-Host " [OK]" -ForegroundColor Green
    }
    catch {
        Write-Host " [ERROR]" -ForegroundColor Red
        Write-Error "No se pudo crear la tarea. Razón: $_"
    }
}

# --- Ejecución ---

Registrar-TareaPersonalizada -Nombre "SAK_Workflow_ConvertirSemana" `
                             -RutaScript $Script1 `
                             -Descripcion "Ejecuta ConvertirProjectSemana.ps1 a las 09:00 y 20:00"

Registrar-TareaPersonalizada -Nombre "SAK_Workflow_Pendientes" `
                             -RutaScript $Script2 `
                             -Descripcion "Ejecuta ConvertirProjectSemanaPendientes.ps1 a las 09:00 y 20:00"

Write-Host "---"
Write-Host "Configuración completada exitosamente." -ForegroundColor Cyan
Write-Host "Esta ventana se cerrará en 10 segundos..."
Start-Sleep -Seconds 10