# Define la hora específica en la que deseas detener el proceso (formato 24 horas)
$horaEspecifica = "05:55"

while ($true) {
    # Obtiene la hora actual
    $horaActual = Get-Date -Format "HH:mm"

    # Calcula el tiempo que falta hasta la hora específica
    $tiempoRestante = [datetime]::ParseExact($horaEspecifica, "HH:mm", $null) - [datetime]::Now

    # Si el tiempo restante es negativo, ajusta para la próxima vez
    if ($tiempoRestante.TotalSeconds -lt 0) {
        $tiempoRestante = [datetime]::ParseExact($horaEspecifica, "HH:mm", $null).AddDays(1) - [datetime]::Now
    }

    Write-Host "Esperando hasta las $horaEspecifica para detener dsTermServ.exe..."
    
    # Pausa el script durante el tiempo restante
    Start-Sleep -Seconds $tiempoRestante.TotalSeconds

    # Termina el proceso dsTermServ.exe si está en ejecución
    if (Get-Process -Name dsTermServ -ErrorAction SilentlyContinue) {
        Stop-Process -Name dsTermServ -Force
        Write-Host "Proceso dsTermServ.exe detenido a las $horaEspecifica."
        break  # Sale del bucle while una vez que se detiene el proceso
    } else {
        Write-Host "Proceso dsTermServ.exe no encontrado."
    }
}
