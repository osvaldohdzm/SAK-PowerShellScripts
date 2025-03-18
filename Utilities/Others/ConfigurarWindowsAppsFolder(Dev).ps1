# Define la ruta de origen y destino
$sourcePath = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
$destinationPath = "D:\WindowsApps"

# Verifica si el directorio de origen existe
if (Test-Path -Path $sourcePath -PathType Container) {
    # Crea el directorio de destino si no existe
    if (-not (Test-Path -Path $destinationPath -PathType Container)) {
        New-Item -Path $destinationPath -ItemType Directory
    }

    # Cambia los permisos de acceso en el directorio de origen
    $acl = Get-Acl $sourcePath
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $fileSystemRights = [System.Security.AccessControl.FileSystemRights]::FullControl
    $inheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
    $propagationFlag = [System.Security.AccessControl.PropagationFlags]::None
    $accessControlType = [System.Security.AccessControl.AccessControlType]::Allow
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($identity.Name, $fileSystemRights, $inheritanceFlag, $propagationFlag, $accessControlType)
    $acl.SetAccessRule($accessRule)
    Set-Acl -Path $sourcePath -AclObject $acl

    # Mueve los archivos y carpetas del directorio de origen al destino
    Get-ChildItem -Path $sourcePath | ForEach-Object {
        Move-Item -Path $_.FullName -Destination $destinationPath -Force
    }

    Write-Host "Se han movido las aplicaciones de Windows Apps correctamente al nuevo directorio."
} else {
    Write-Host "El directorio de origen '$sourcePath' no existe. No se ha realizado ninguna acción."
}

# Verifica y actualiza la variable de entorno PATH del usuario si es necesario
$existingPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
$windowsAppsPath = "D:\WindowsApps"

if ($existingPath -notlike "*$windowsAppsPath*") {
    $newPath = "$existingPath;$windowsAppsPath"
    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    Write-Host "La variable de entorno PATH se ha actualizado para incluir el nuevo directorio de Windows Apps."
} else {
    Write-Host "La variable de entorno PATH ya incluye el nuevo directorio de Windows Apps."
}

Write-Host "Asegúrate de reiniciar cualquier sesión de PowerShell o CMD para que los cambios surtan efecto."
