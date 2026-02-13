# --- CONFIGURACIÓN DE RUTAS ---
$rutaCarpeta = "C:\Users\osvaldohm\Desktop\Base\04 Proyectos\03 Gestión de Proyectos"
$nombreMaster = "MS Project Master.mpp"
$rutaSalida = Join-Path $env:USERPROFILE "Desktop\$nombreMaster"

# 1. Limpieza total de procesos
Get-Process | Where-Object {$_.Name -eq "MSProject"} | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

try {
    $projectApp = New-Object -ComObject MSProject.Application
    $projectApp.Visible = $true
    $projectApp.DisplayAlerts = $false 

    # Crear el nuevo proyecto maestro y capturar su ventana
    $projectApp.FileNew()
    Start-Sleep -Seconds 2
    $masterProject = $projectApp.ActiveProject
    $ventanaMaster = $projectApp.ActiveWindow.Caption

    # 2. Obtener y ordenar archivos
    $archivos = Get-ChildItem -Path $rutaCarpeta -Filter "*.mpp" -File | 
                Where-Object { $_.Name -notlike "~$*" -and $_.Name -ne $nombreMaster } |
                Sort-Object Name

    Write-Host "Iniciando fusión física de $($archivos.Count) proyectos..." -ForegroundColor Green

    foreach ($archivo in $archivos) {
        Write-Host "Extrayendo datos de: $($archivo.Name)..." -ForegroundColor Cyan
        
        try {
            # Abrir el archivo original
            $projectApp.FileOpen($archivo.FullName, $true) # Abrir como Solo Lectura
            Start-Sleep -Seconds 1
            
            # Seleccionar todas las tareas y copiar datos físicos
            $projectApp.SelectAll()
            $projectApp.EditCopy()
            
            # Cambiar al Maestro
            $projectApp.WindowActivate($ventanaMaster)
            
            # Ir al final de la lista para pegar
            $projectApp.SelectEnd()
            $projectApp.EditPaste()
            
            # Cerrar el archivo original para liberar memoria
            $projectApp.FileClose(2) # 2 = pjDoNotSave
            
            Write-Host "   OK: Datos copiados correctamente." -ForegroundColor Green
            Start-Sleep -Milliseconds 500
        } catch {
            Write-Host "   Error al procesar $($archivo.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # 3. Refrescar cálculos (importante para los costos de millones que manejas)
    $projectApp.CalculateAll()
    $projectApp.OutlineShowAllTasks()

    # 4. Guardado Final
    if (Test-Path $rutaSalida) { Remove-Item $rutaSalida -Force }
    $projectApp.FileSaveAs($rutaSalida)
    
    Write-Host "`n¡PROCESO COMPLETADO! Revisa el archivo en tu escritorio." -ForegroundColor Green

} catch {
    Write-Host "Error crítico: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    if ($projectApp) { $projectApp.DisplayAlerts = $true }
}