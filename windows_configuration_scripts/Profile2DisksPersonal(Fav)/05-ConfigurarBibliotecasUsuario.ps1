# Definir la función Set-KnownFolderPath
function Set-KnownFolderPath {
    param (
        [string]$KnownFolder,
        [string]$Path
    )

    $signature = @"
    [DllImport("shell32.dll")]
    public static extern int SHSetKnownFolderPath(
        [MarshalAs(UnmanagedType.LPStruct)] Guid rfid,
        uint dwFlags,
        IntPtr hToken,
        [MarshalAs(UnmanagedType.LPWStr)] string pszPath
    );
"@
    $knownFoldersType = Add-Type -MemberDefinition $signature -Namespace Shell32 -Name KnownFolders -PassThru

    $knownFolders = @{
        "Desktop" = [guid]::new("B4BFCC3A-DB2C-424C-B029-7FE99A87C641")
        "Documents" = [guid]::new("FDD39AD0-238F-46AF-ADB4-6C85480369C7")
        "Downloads" = [guid]::new("374DE290-123F-4565-9164-39C4925E467B")
        "Music" = [guid]::new("4BD8D571-6D19-48D3-BE97-422220080E43")
        "Pictures" = [guid]::new("33E28130-4E1E-4676-835A-98395C3BC3BB")
        "Videos" = [guid]::new("18989B1D-99B5-455B-841C-AB7C74E4DDFC")
    }

    $knownFolderGuid = $knownFolders[$KnownFolder]

    if ($knownFolderGuid) {
        $result = $knownFoldersType::SHSetKnownFolderPath($knownFolderGuid, 0, [IntPtr]::Zero, $Path)
        return $result -eq 0
    } else {
        Write-Host "Known folder '$KnownFolder' not found."
        return $false
    }
}

# Set the new paths for the specified folders
$nuevaRutaEscritorio = "D:\osvaldohm\Desktop"
$nuevaRutaDocumentos = "D:\osvaldohm\Documents"
$nuevaRutaDescargas = "D:\osvaldohm\Downloads"
$nuevaRutaMusica = "D:\osvaldohm\Music"
$nuevaRutaImagenes = "D:\osvaldohm\Pictures"
$nuevaRutaVideos = "D:\osvaldohm\Videos"

# Cambiar la ubicación de Desktop si es necesario
if ($env:USERPROFILE + "\Desktop" -ne $nuevaRutaEscritorio) {
    Set-KnownFolderPath -KnownFolder "Desktop" -Path $nuevaRutaEscritorio
    Write-Host "La ubicación de la carpeta del escritorio se ha cambiado correctamente."

    $carpetasShellUsuario = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
    $carpetasShellUsuario.Desktop = $nuevaRutaEscritorio
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Desktop" -Value $nuevaRutaEscritorio

    Write-Host "Las ubicaciones en el registro de Windows han sido cambiadas."

    Write-Host "El proceso ha finalizado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual del escritorio."
}

# Cambiar la ubicación de Documents si es necesario
if ($env:USERPROFILE + "\Documents" -ne $nuevaRutaDocumentos) {
    Set-KnownFolderPath -KnownFolder "Documents" -Path $nuevaRutaDocumentos
    Write-Host "La ubicación de la carpeta de documentos se ha cambiado correctamente."

    $carpetasShellUsuario = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
    $carpetasShellUsuario.Personal = $nuevaRutaDocumentos
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Personal" -Value $nuevaRutaDocumentos

    Write-Host "Las ubicaciones en el registro de Windows han sido cambiadas."

    Write-Host "El proceso ha finalizado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de documentos."
}

# Cambiar la ubicación de Downloads si es necesario
if ($env:USERPROFILE + "\Downloads" -ne $nuevaRutaDescargas) {
    Set-KnownFolderPath -KnownFolder "Downloads" -Path $nuevaRutaDescargas
    Write-Host "La ubicación de la carpeta de descargas se ha cambiado correctamente."

    $carpetasShellUsuario = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
    $carpetasShellUsuario.Downloads = $nuevaRutaDescargas
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Downloads" -Value $nuevaRutaDescargas

    Write-Host "Las ubicaciones en el registro de Windows han sido cambiadas."

    Write-Host "El proceso ha finalizado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de descargas."
}

# Cambiar la ubicación de Music si es necesario
if ($env:USERPROFILE + "\Music" -ne $nuevaRutaMusica) {
    Set-KnownFolderPath -KnownFolder "Music" -Path $nuevaRutaMusica
    Write-Host "La ubicación de la carpeta de música se ha cambiado correctamente."

    Write-Host "El proceso ha finalizado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de música."
}

# Cambiar la ubicación de Pictures si es necesario
if ($env:USERPROFILE + "\Pictures" -ne $nuevaRutaImagenes) {
    Set-KnownFolderPath -KnownFolder "Pictures" -Path $nuevaRutaImagenes
    Write-Host "La ubicación de la carpeta de imágenes se ha cambiado correctamente."

    Write-Host "El proceso ha finalizado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de imágenes."
}

# Cambiar la ubicación de Videos si es necesario
if ($env:USERPROFILE + "\Videos" -ne $nuevaRutaVideos) {
    Set-KnownFolderPath -KnownFolder "Videos" -Path $nuevaRutaVideos
    Write-Host "La ubicación de la carpeta de videos se ha cambiado correctamente."

    Write-Host "El proceso ha finalizado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de videos."
}
