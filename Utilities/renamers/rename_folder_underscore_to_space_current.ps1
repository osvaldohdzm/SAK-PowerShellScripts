# rename_folder_underscore_to_space_current.ps1
# Autor: Osvaldo
# Descripción: Renombra todas las carpetas del directorio actual reemplazando "_" por espacios.

# Obtener la ruta actual
$CurrentPath = Get-Location

# Obtener todas las carpetas en el directorio actual
$Folders = Get-ChildItem -Path $CurrentPath -Directory

foreach ($Folder in $Folders) {
    $OldName = $Folder.Name
    $NewName = $OldName -replace "_", " "

    if ($OldName -ne $NewName) {
        Write-Host "Renombrando: '$OldName' -> '$NewName'" -ForegroundColor Cyan
        Rename-Item -Path $Folder.FullName -NewName $NewName
    }
    else {
        Write-Host "Sin cambios: '$OldName'" -ForegroundColor DarkGray
    }
}

Write-Host "`nProceso completado." -ForegroundColor Green
