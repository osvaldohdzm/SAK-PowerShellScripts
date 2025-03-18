# Verificar si se está ejecutando como administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Output "Este script requiere privilegios de administrador. Ejecútalo como administrador."
    exit
}

[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Verificar si nmap está instalado
if (-not (Test-Path -Path "C:\Program Files (x86)\Nmap\nmap.exe") -and -not (Test-Path -Path "D:\Program Files (x86)\Nmap\nmap.exe")) {
    Write-Output "Nmap no está instalado. Instalando Nmap..."
    Start-Process -Wait -FilePath "https://nmap.org/dist/nmap-7.92-setup.exe"
    Start-Process -Wait -FilePath "nmap-7.92-setup.exe"
    Remove-Item "nmap-7.92-setup.exe"
}

# Solicitar al usuario la dirección IP de destino
$targetIP = Read-Host "Ingresa la dirección IP de destino"

# Solicitar el valor mínimo de min-rate y convertirlo a entero
$minMinRate = Read-Host "Ingresa el valor mínimo de min-rate a probar"
$minMinRate = [int]$minMinRate

# Solicitar el valor máximo de min-rate y convertirlo a entero
$maxMinRate = Read-Host "Ingresa el valor máximo de min-rate a probar"
$maxMinRate = [int]$maxMinRate

# Inicializar variables para el mejor min-rate y tiempo mínimo registrado
$bestMinRate = 0
$minTime = [double]::MaxValue

# Bucle de búsqueda binaria
while ($minMinRate -lt $maxMinRate) {
    # Calcular el valor medio de min-rate
    $currentMinRate = [math]::Round(($minMinRate + $maxMinRate) / 2)

    # Ejecutar Nmap con el valor actual de min-rate y medir el tiempo
    Write-Output "Probando con min-rate = $currentMinRate..."
    $nmapCommand = "nmap --min-rate $currentMinRate -T5 $targetIP"
    $result = Invoke-Expression $nmapCommand
    $timeTaken = [regex]::Matches($result, 'scanned in ([\d.]+) seconds') | ForEach-Object { [double]$_.Groups[1].Value }

    Write-Output "Escaneo completado en $timeTaken segundos."

    # Comparar el tiempo actual con el tiempo mínimo registrado
    if ($timeTaken -lt $minTime) {
        $minTime = $timeTaken
        $bestMinRate = $currentMinRate
    }

    # Actualizar los valores mínimo y máximo de min-rate
    if ($timeTaken -lt $minTime) {
        $maxMinRate = $currentMinRate
    } else {
        $minMinRate = $currentMinRate + 1
    }
}

# Obtener la fecha y hora actual en el formato deseado (año-mes-día-hora-minuto-segundo)
$fechaHora = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"

# Concatenar la fecha y hora en el nombre del archivo
$nombreArchivo = "nmap-scan-$fechaHora"

# Luego puedes usar $nombreArchivo en tu comando
Write-Output "Comando a usar sugerido: nmap -Pn -n -sS -p- -sV -T4 --min-rate $bestMinRate --open --min-hostgroup 100 --min-parallelism 10 --stats-every 3s --host-timeout 30m -oA $nombreArchivo [targets]"
