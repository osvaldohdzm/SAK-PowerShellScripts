# Función para mostrar una barra de carga
function Show-ProgressBar {
    param(
        [int]$PercentComplete
    )

    $TotalWidth = 50
    $CompletedWidth = [math]::Floor(($PercentComplete / 100) * $TotalWidth)
    $RemainingWidth = $TotalWidth - $CompletedWidth

    Write-Host -NoNewline -ForegroundColor Green ("[" + ("#" * $CompletedWidth) + (" " * $RemainingWidth) + "] $PercentComplete%`r")
}

# Solicitar letras de unidades al usuario (aceptar minúsculas o mayúsculas, con o sin dos puntos)
$unidadOrigen = Read-Host "Por favor, ingrese la letra de la unidad de disco de origen (unidad a respaldar)"
$unidadDestino = Read-Host "Por favor, ingrese la letra de la unidad de disco de destino (ubicación del respaldo)"

# Quitar dos puntos si el usuario los ingresó
$unidadOrigen = $unidadOrigen -replace ":", ""
$unidadDestino = $unidadDestino -replace ":", ""

$unidadOrigen = $unidadOrigen.ToUpper()
$unidadDestino = $unidadDestino.ToUpper()

# Verificar si las unidades son válidas
$unidades = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
$unidadOrigenInfo = $unidades | Where-Object { $_.DeviceID -eq "$($unidadOrigen):" }
$unidadDestinoInfo = $unidades | Where-Object { $_.DeviceID -eq "$($unidadDestino):" }

if ($unidadOrigenInfo -and $unidadDestinoInfo) {
    Write-Host "Unidades válidas, presione S para continuar o N para salir:"
    $response = Read-Host

    if ($response -eq "S") {
        # Carpetas a copiar
        $foldersToCopy = @("AppsInstallers", "osvaldohm", "WindowsConfigurationScripts")

        # Crear la carpeta de respaldo con el formato "DataDriveBackup-DD-MM-AAAA-HH-MM-SS"
        $backupFolderName = "DataDriveBackup-{0:dd-MM-yyyy-HH-mm-ss}" -f (Get-Date)
        $backupFolderPath = Join-Path -Path "$($unidadDestino):" -ChildPath $backupFolderName
        New-Item -Path $backupFolderPath -ItemType Directory | Out-Null

        $totalFolders = $foldersToCopy.Count
        $completedFolders = 0

        Show-ProgressBar -PercentComplete 0

        foreach ($folderName in $foldersToCopy) {
            $sourcePath = Join-Path -Path "$($unidadOrigen):" -ChildPath $folderName
            $destinationPath = Join-Path -Path $backupFolderPath -ChildPath $folderName

            if (Test-Path -Path $sourcePath -PathType Container) {
                Copy-Item -Path $sourcePath -Destination $destinationPath -Recurse -Force

                $completedFolders++
                $progressPercent = [math]::Floor(($completedFolders / $totalFolders) * 100)
                Show-ProgressBar -PercentComplete $progressPercent
            }
        }

        # Crear carpetas vacías en el destino
        $emptyFolders = @("Program Files", "Program Files (x86)", "Temporal")
        foreach ($folderName in $emptyFolders) {
            $destinationPath = Join-Path -Path $backupFolderPath -ChildPath $folderName
            New-Item -Path $destinationPath -ItemType Directory | Out-Null
        }

        Write-Host "`nCopia de seguridad completada en $backupFolderPath"
    } else {
        Write-Host "Operación cancelada."
    }
} else {
    Write-Host "Una o ambas unidades no son válidas. El script ha terminado."
}
