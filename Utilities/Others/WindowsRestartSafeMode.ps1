# Reiniciar en modo seguro
$command = {
    Restart-Computer -Force
}
$null = Invoke-Command -ScriptBlock $command -ComputerName localhost -AsJob
Start-Sleep -Seconds 5
shutdown.exe /r /f /o /t 0
