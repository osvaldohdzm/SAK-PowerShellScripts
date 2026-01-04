# --- BLOQUE DE AUTO-ELEVACIÓN DE PRIVILEGIOS ---
# Verifica si el script se está ejecutando como Administrador
$Principal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "El script necesita permisos para borrar tareas del sistema." -ForegroundColor Yellow
    Write-Host "Solicitando elevación de privilegios..." -ForegroundColor Yellow
    
    # Reinicia el script actual solicitando permisos de administrador (RunAs)
    Start-Process -FilePath "PowerShell.exe" `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" `
        -Verb RunAs
    
    Exit
}

# --- A PARTIR DE AQUÍ SE EJECUTA COMO ADMINISTRADOR ---

Write-Host "Iniciando proceso de Rollback (Eliminación de tareas SAK_Workflow*)..." -ForegroundColor Cyan
Write-Host "---"

# Prefijo de tareas a eliminar
$Prefijo = "SAK_Workflow"

# Obtener todas las tareas que comiencen con el prefijo
$Tareas = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object {
    $_.TaskName -like "$Prefijo*"
}

if (-not $Tareas) {
    Write-Host "No se encontraron tareas que comiencen con '$Prefijo'." -ForegroundColor DarkGray
}
else {
    foreach ($Tarea in $Tareas) {
        Write-Host "Eliminando tarea: $($Tarea.TaskName)..." -NoNewline
        try {
            Unregister-ScheduledTask -TaskName $Tarea.TaskName -TaskPath $Tarea.TaskPath -Confirm:$false
            Write-Host " [ELIMINADA]" -ForegroundColor Green
        }
        catch {
            Write-Host " [ERROR]" -ForegroundColor Red
            Write-Error "No se pudo borrar '$($Tarea.TaskName)'. Detalles: $_"
        }
    }
}

Write-Host "---"
Write-Host "Rollback finalizado." -ForegroundColor Cyan
Write-Host "La ventana se cerrará en  segundos..."
Start-Sleep -Seconds 3
