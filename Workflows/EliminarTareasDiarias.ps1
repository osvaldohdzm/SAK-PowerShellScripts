# --- BLOQUE DE AUTO-ELEVACIÓN DE PRIVILEGIOS ---
# Verifica si el script se está ejecutando como Administrador
$Principal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "El script necesita permisos para borrar tareas del sistema." -ForegroundColor Yellow
    Write-Host "Solicitando elevación de privilegios..." -ForegroundColor Yellow
    
    # Reinicia el script actual solicitando permisos de administrador (RunAs)
    $NewProcess = Start-Process -FilePath "PowerShell.exe" `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" `
        -Verb RunAs `
        -PassThru
    
    # Cierra la instancia actual sin permisos
    Exit
}

# --- A PARTIR DE AQUÍ SE EJECUTA COMO ADMINISTRADOR ---

Write-Host "Iniciando proceso de Rollback (Eliminación de tareas)..." -ForegroundColor Cyan
Write-Host "---"

# Lista exacta de tareas a eliminar
$TareasAEliminar = @("SAK_Workflow_ConvertirSemana", "SAK_Workflow_Pendientes")

foreach ($Tarea in $TareasAEliminar) {
    Write-Host "Buscando tarea: $Tarea..." -NoNewline

    # Verificar si la tarea existe
    if (Get-ScheduledTask -TaskName $Tarea -ErrorAction SilentlyContinue) {
        try {
            # Eliminar la tarea sin pedir confirmación manual (-Confirm:$false)
            Unregister-ScheduledTask -TaskName $Tarea -Confirm:$false
            Write-Host " [ELIMINADA]" -ForegroundColor Green
        }
        catch {
            Write-Host " [ERROR]" -ForegroundColor Red
            Write-Error "No se pudo borrar '$Tarea'. Detalles: $_"
        }
    }
    else {
        Write-Host " [NO ENCONTRADA]" -ForegroundColor DarkGray
        Write-Host "   (La tarea no existe o ya fue eliminada previamente)" -ForegroundColor DarkGray
    }
}

Write-Host "---"
Write-Host "Rollback finalizado." -ForegroundColor Cyan
Write-Host "La ventana se cerrará en 5 segundos..."
Start-Sleep -Seconds 5