# Cambiar la etiqueta del disco C a "System Drive"
$systemDriveLabel = "System Drive"
$systemDrive = Get-WmiObject Win32_Volume | Where-Object { $_.DriveLetter -eq 'C:' }
$systemDrive.Label = $systemDriveLabel
$systemDrive.Put()

# Cambiar la etiqueta del disco D a "Data Drive"
$dataDriveLabel = "Data Drive"
$dataDrive = Get-WmiObject Win32_Volume | Where-Object { $_.DriveLetter -eq 'D:' }
$dataDrive.Label = $dataDriveLabel
$dataDrive.Put()

Write-Host "Las etiquetas de los discos se han cambiado correctamente."
