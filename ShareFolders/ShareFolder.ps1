<#
.SYNOPSIS
Este script comparte una carpeta como recurso de red y configura varias opciones de uso compartido.

.DESCRIPTION
Este script permite compartir una carpeta como recurso de red y configurar opciones de uso compartido.
Puedes elegir compartir con autenticación temporal o persistente y habilitar o deshabilitar el modo invitado. 
También puedes dejar de compartir todos los recursos personalizados utilizando la opción -unShareAll.

.PARAMETER tmpAuthShare
Comparte la carpeta con autenticación temporal.

.PARAMETER persistentAuthShare
Comparte la carpeta con autenticación persistente.

.PARAMETER tmpGuestMode
Habilita el modo invitado para acceso temporal.

.PARAMETER persistentGuestMode
Habilita el modo invitado para acceso persistente.

.PARAMETER unShareAll
Deja de compartir todos los recursos personalizados.

.PARAMETER shareName
Especifica el nombre del recurso compartido (obligatorio).

.PARAMETER dir
Especifica la ruta de la carpeta a compartir. Si no se proporciona, se usará el directorio actual del script.

.EXAMPLE
.\ShareFolder.ps1 -persistentAuthShare -shareName "PrivateSharingFolder" -dir "D:\$env:USERNAME\Desktop\Home"

Comparte la carpeta de archivos privados.

.EXAMPLE
.\ShareFolder.ps1 -persistentGuestMode -shareName "PublicSharingFolder" -dir "D:\$env:USERNAME\Desktop\PublicSharingFolder"

Comparte la carpeta de archivos públicos.

.EXAMPLE
.\Share-Folder.ps1 -unShareAll

Deja de compartir todos los recursos.

#>

[CmdletBinding()]
param (
    [switch]$tmpAuthShare,
    [switch]$persistentAuthShare,
    [switch]$tmpGuestMode,
    [switch]$persistentGuestMode,
    [switch]$unShareAll,
    [string]$shareName,
    [string]$dir
)

# Función para normalizar el nombre de recurso compartido
function Normalize-ShareName {
    param (
        [string]$shareName
    )

    # Eliminar caracteres no permitidos (reemplazarlos por guiones bajos)
    $normalizedName = $shareName -replace '[^\w\s-]', '_'

    # Asegurar que el nombre tenga menos de 80 caracteres (restricción de Windows)
    if ($normalizedName.Length -gt 80) {
        $normalizedName = $normalizedName.Substring(0, 80)
    }

    return $normalizedName
}

# Verificar el idioma del sistema
$systemLanguage = (Get-Culture).Name

# Configurar el nombre de la cuenta de invitado según el idioma del sistema
$guestAccountName = "Guest"

if ($systemLanguage -eq "es-ES" -or $systemLanguage -eq "es-MX") {
    $guestAccountName = "Invitado"
}

# Verificar si se proporciona el parámetro -unShareAll
if ($unShareAll) {
    Write-Host "Deshaciendo la compartición de recursos compartidos personalizados..."
    Get-WmiObject Win32_Share | ForEach-Object {
        $shareName = $_.Name
        # Excluir recursos compartidos del sistema
        if ($shareName -notin ('ADMIN$', 'C$', 'D$', 'IPC$')) {
            net user $guestAccountName /active:no
            Remove-SmbShare -Name $shareName -Force -Confirm:$false
            Write-Host "Recurso compartido $shareName eliminado."
        }
    }
    exit
}

# Verificar si se proporciona el parámetro -dir
if ($dir) {
    # Comprobar si la ruta especificada existe
    if (Test-Path -Path $dir -PathType Container) {
        # Utilizar la ruta especificada en lugar de la ubicación actual
        $folderPath = $dir
    } else {
        Write-Host "La ruta especificada en el parámetro -dir no existe. El proceso se detendrá."
        exit 1
    }
} else {
    # Si no se proporciona el parámetro -dir, utilizar la ubicación actual
    $folderPath = $PSScriptRoot
}

# Validar que al menos uno de los parámetros de acción sea proporcionado
if (-not ($tmpAuthShare -or $persistentAuthShare -or $tmpGuestMode -or $persistentGuestMode)) {
    Write-Host "Debes proporcionar al menos uno de los siguientes parámetros: -tmpAuthShare, -persistentAuthShare, -tmpGuestMode, -persistentGuestMode."
    exit 1
}

# Validar que el parámetro -share-name sea proporcionado
if (-not ($shareName)) {
    Write-Host "El parámetro -share-name es obligatorio."
    exit 1
}

# Verificar si el script se está ejecutando con privilegios de administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script requiere privilegios de administrador. Elevando privilegios..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Normalizar el nombre de recurso compartido
$shareName = Normalize-ShareName -shareName $shareName

# Verificar si la carpeta a compartir existe
if (-not (Test-Path -Path $folderPath -PathType Container)) {
    Write-Host "La carpeta especificada no existe. El proceso se detendrá."
    exit 1
}

# Obtener información sobre las interfaces de red
$networkAdapters = Get-WmiObject Win32_NetworkAdapter | Where-Object { $_.NetConnectionID -ne $null }

foreach ($adapter in $networkAdapters) {
    $adapterName = $adapter.Name
    $adapterType = $adapter.NetConnectionID
    $ipAddresses = Get-NetIPAddress -InterfaceAlias $adapterType | Where-Object { $_.AddressFamily -eq "IPv4" }

    foreach ($ipAddress in $ipAddresses) {
        $interfaceType = ""
        $wifiName = ""

        # Determinar el tipo de interfaz (Ethernet/Wi-Fi)
        if ($adapterType -like "*Wi-Fi*") {
            $interfaceType = "Wi-Fi"
            # Obtener el nombre de la red Wi-Fi utilizando netsh
            $wifiName = (netsh wlan show interfaces | Select-String "SSID" | ForEach-Object { $_ -replace "^\s*SSID\s*:\s*", "" }).Trim()
        } elseif ($adapterType -like "*Ethernet*") {
            $interfaceType = "Ethernet"
        } else {
            $interfaceType = "Desconocido"
        }

        # Mostrar la información en la misma línea
        Write-Host "IP: $($ipAddress.IPAddress), Tipo de conexión: $interfaceType, Nombre de la red: $wifiName, Nombre del adaptador: $adapterName"
    }
}

# Compartir la carpeta con autenticación temporal o persistente
if ($tmpAuthShare -or $persistentAuthShare) {
    Write-Host "Compartiendo carpeta: $($folderPath) como recurso compartido $($shareName) con autenticación."

    # Compartir la carpeta con el nombre normalizado
    New-SmbShare -Name $shareName -Path $folderPath -Description "Carpeta compartida para lectura y escritura" -FullAccess "Everyone" -Confirm:$false

    # Establecer FolderEnumerationMode en el recurso compartido
    $folderEnumerationMode = "Unrestricted"
    Set-SmbShare -Name $shareName -FolderEnumerationMode $folderEnumerationMode -Confirm:$false
}

# Configurar opciones de acceso para el modo invitado (temporal o persistente)
if ($tmpGuestMode -or $persistentGuestMode) {
    Write-Host "Configurando opciones de acceso para el modo invitado en el recurso compartido $($shareName)."

    # Habilitar la cuenta de Invitado si no está habilitada
    Write-Host "Habilitando cuenta $guestAccountName."
    $guestAccount = Get-WmiObject -Class Win32_UserAccount -Filter "Name='$guestAccountName'"
    if ($guestAccount -ne $null -and $guestAccount.Disabled) {
        Write-Host "Habilitando la cuenta de $guestAccountName..."
        Enable-LocalUser -Name $guestAccountName
        net user $guestAccountName /active:yes

        # Comprobar el valor de la directiva
        Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "GuestLogonEnabled"
    }

    # Deshabilitar el acceso desde la red para el usuario Invitado
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "restrictnullsessaccess" -Value 0
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "EveryoneIncludesAnonymous" -Value 1
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LocalAccountTokenFilterPolicy" -Value 1

    # Habilitar el acceso desde la red para el usuario Invitado
    $User = "Invitado"
    $PolicyName = "Network access: Sharing and security model for local accounts"

    # Obtener el valor actual de la directiva
    $CurrentValue = (secedit /export /cfg "$env:temp\security.cfg" | Select-String -Pattern "$PolicyName")

    # Verificar si la directiva ya está configurada para permitir el acceso desde la red
    if ($CurrentValue -match "0") {
        Write-Host "La política ya está configurada para permitir el acceso desde la red al usuario $User."
    } else {
        # Configurar la directiva para permitir el acceso desde la red
        secedit /configure /db "$env:windir\security\local.sdb" /cfg "$env:temp\security.cfg" /areas SECURITYPOLICY
        Write-Host "La política se ha actualizado para permitir el acceso desde la red al usuario $User."
    }

    secedit /export /cfg "$env:temp\security_policy.inf"
    (Get-Content "$env:temp\security_policy.inf" -Raw) -replace 'SeDenyNetworkLogonRight.*', 'SeDenyNetworkLogonRight = ' | Set-Content "$env:temp\security_policy.inf"
    secedit /configure /db c:\windows\security\local.sdb /cfg "$env:temp\security_policy.inf"

    # Generar una contraseña aleatoria para la cuenta de Invitado
     $newPassword = -join ((48..57) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_})

    # Cambiar la contraseña de la cuenta de Invitado utilizando Net User
    net user $guestAccountName $newPassword

    Write-Host "Usuario $guestAccountName activado, nueva contraseña: $newPassword"

    # Configurar permisos de acceso para Invitado
    $sharePath = Join-Path -Path $env:SystemDrive -ChildPath $shareName

    # Obtener el acceso actual y otorgar acceso de solo lectura a Invitado
    $acl = Get-Acl -Path $folderPath
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("$guestAccountName", "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)
    Set-Acl -Path $folderPath -AclObject $acl

    Write-Host "El acceso a $guestAccountName ha sido configurado para la carpeta compartida."

    # Habilitar la cuenta de Invitado en el registro
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "GuestLogonEnabled" -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LocalAccountTokenFilterPolicy" -Value 1

    # Deshabilitar la protección con contraseña para compartir mediante PowerShell
    Set-SmbServerConfiguration -EnableSMB2Protocol $true -Confirm:$false

    # Actualizar la Directiva de Grupo
    gpupdate /force

    # Configurar recursos compartidos que pueden ser accesibles anónimamente mediante PowerShell
    New-SmbShare -Name $shareName -Path $folderPath -Description "Carpeta compartida para lectura y escritura" -FullAccess "Everyone" -Confirm:$false
}

if ($persistentAuthShare -or $persistentGuestMode) {
    Write-Host "La carpeta se ha compartido de forma persistente."
} else {
    # Mostrar las carpetas compartidas en el equipo
    Write-Host "Recursos compartidos:"
    Get-WmiObject Win32_Share | Where-Object { $_.Type -eq 0 } | Select-Object Name, Path

    if ($tmpAuthShare -or $tmpGuestMode) {
        Write-Host "Presiona Enter para dejar de compartir..."
        Read-Host

        # Dejar de compartir antes de salir (sin solicitar confirmación)
        Remove-SmbShare -Name $shareName -Force -Confirm:$false
        net user $guestAccountName /active:no
        Write-Host "La carpeta se ha dejado de compartir."
    } else {
        # Esperar a que el usuario presione Enter para salir
        Write-Host "Presiona Enter para salir..."
        Read-Host
    }
}
