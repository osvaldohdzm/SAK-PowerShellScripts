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
        "AppData" = [guid]::new("3EB685DB-65F9-4CF6-A03A-E3EF65729F3D")
        "Local AppData" = [guid]::new("F1B32785-6FBA-4FCF-9D55-7B8E7F157091")
        "Favorites" = [guid]::new("1777F761-68AD-4D8A-87BD-30B759FA33DD")
        "History" = [guid]::new("D9DC8A3B-B784-432E-A781-5A1130A75963")
        "NetHood" = [guid]::new("C5ABBF53-E17F-4121-8900-86626FC2C973")
        "PrintHood" = [guid]::new("9274BD8D-CFD1-41C3-B35E-B13F55A758F4")
        "SendTo" = [guid]::new("8983036C-27C0-404B-8F08-102D10DCFD74")
        "Recent" = [guid]::new("AE50C081-EBD2-438A-8655-8A092E34987A")
        "Start Menu" = [guid]::new("625B53C3-AB48-4EC1-BA1F-A1EF4146FC19")
        "Startup" = [guid]::new("B97D20BB-F46A-4C97-BA10-5E3608430854")
        "Templates" = [guid]::new("A63293E8-664E-48DB-A079-DF759E0509F7")
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

# Crear las carpetas necesarias en D: si no existen
$carpetas = @(
    "D:\Users\osvaldohm\Desktop",
    "D:\Users\osvaldohm\Music",
    "D:\Users\osvaldohm\Pictures",
    "D:\Users\osvaldohm\Videos",
    "D:\Users\osvaldohm\Favorites",
    "D:\Users\osvaldohm\AppData\Local\Microsoft\Windows\History",
    "D:\Users\osvaldohm\AppData\Roaming\Microsoft\Windows\Network Shortcuts",
    "D:\Users\osvaldohm\AppData\Roaming\Microsoft\Windows\Printer Shortcuts",
    "D:\Users\osvaldohm\AppData\Roaming\Microsoft\Windows\SendTo",
    "D:\Users\osvaldohm\AppData\Roaming\Microsoft\Windows\Recent",
    "D:\Users\osvaldohm\AppData\Roaming\Microsoft\Windows\Start Menu",
    "D:\Users\osvaldohm\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup",
    "D:\Users\osvaldohm\AppData\Roaming\Microsoft\Windows\Templates"
)

foreach ($carpeta in $carpetas) {
    if (-not (Test-Path $carpeta)) {
        New-Item -Path $carpeta -ItemType Directory | Out-Null
        Write-Host "Carpeta creada: $carpeta"
    }
}

# Set the new paths for the specified folders
$nuevaRutaEscritorio = "D:\Users\osvaldohm\Desktop"
$nuevaRutaMusica = "D:\Users\osvaldohm\Music"
$nuevaRutaImagenes = "D:\Users\osvaldohm\Pictures"
$nuevaRutaVideos = "D:\Users\osvaldohm\Videos"
$nuevaRutaAppData = "D:\Users\osvaldohm\AppData\Roaming"
$nuevaRutaLocalAppData = "D:\Users\osvaldohm\AppData\Local"
$nuevaRutaFavoritos = "D:\Users\osvaldohm\Favorites"
$nuevaRutaHistorial = "D:\Users\osvaldohm\AppData\Local\Microsoft\Windows\History"
$nuevaRutaNetHood = "D:\Users\osvaldohm\AppData\Roaming\Microsoft\Windows\Network Shortcuts"
$nuevaRutaPrintHood = "D:\Users\osvaldohm\AppData\Roaming\Microsoft\Windows\Printer Shortcuts"
$nuevaRutaSendTo = "D:\Users\osvaldohm\AppData\Roaming\Microsoft\Windows\SendTo"
$nuevaRutaRecent = "D:\Users\osvaldohm\AppData\Roaming\Microsoft\Windows\Recent"
$nuevaRutaStartMenu = "D:\Users\osvaldohm\AppData\Roaming\Microsoft\Windows\Start Menu"
$nuevaRutaStartup = "D:\Users\osvaldohm\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
$nuevaRutaTemplates = "D:\Users\osvaldohm\AppData\Roaming\Microsoft\Windows\Templates"

# Cambiar la ubicación de Desktop si es necesario
if ($env:USERPROFILE + "\Desktop" -ne $nuevaRutaEscritorio) {
    Set-KnownFolderPath -KnownFolder "Desktop" -Path $nuevaRutaEscritorio
    Write-Host "La ubicación de la carpeta de escritorio se ha cambiado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de escritorio."
}

# Cambiar la ubicación de Music si es necesario
if ($env:USERPROFILE + "\Music" -ne $nuevaRutaMusica) {
    Set-KnownFolderPath -KnownFolder "Music" -Path $nuevaRutaMusica
    Write-Host "La ubicación de la carpeta de música se ha cambiado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de música."
}

# Cambiar la ubicación de Pictures si es necesario
if ($env:USERPROFILE + "\Pictures" -ne $nuevaRutaImagenes) {
    Set-KnownFolderPath -KnownFolder "Pictures" -Path $nuevaRutaImagenes
    Write-Host "La ubicación de la carpeta de imágenes se ha cambiado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de imágenes."
}

# Cambiar la ubicación de Videos si es necesario
if ($env:USERPROFILE + "\Videos" -ne $nuevaRutaVideos) {
    Set-KnownFolderPath -KnownFolder "Videos" -Path $nuevaRutaVideos
    Write-Host "La ubicación de la carpeta de videos se ha cambiado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de videos."
}

# Cambiar la ubicación de AppData si es necesario
if ($env:APPDATA -ne $nuevaRutaAppData) {
    Set-KnownFolderPath -KnownFolder "AppData" -Path $nuevaRutaAppData
    Write-Host "La ubicación de la carpeta de AppData se ha cambiado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de AppData."
}

# Cambiar la ubicación de Local AppData si es necesario
if ($env:LOCALAPPDATA -ne $nuevaRutaLocalAppData) {
    Set-KnownFolderPath -KnownFolder "Local AppData" -Path $nuevaRutaLocalAppData
    Write-Host "La ubicación de la carpeta de Local AppData se ha cambiado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de Local AppData."
}

# Cambiar la ubicación de Favorites si es necesario
if ($env:USERPROFILE + "\Favorites" -ne $nuevaRutaFavoritos) {
    Set-KnownFolderPath -KnownFolder "Favorites" -Path $nuevaRutaFavoritos
    Write-Host "La ubicación de la carpeta de Favoritos se ha cambiado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de Favoritos."
}

# Cambiar la ubicación de History si es necesario
if ($env:USERPROFILE + "\AppData\Local\Microsoft\Windows\History" -ne $nuevaRutaHistorial) {
    Set-KnownFolderPath -KnownFolder "History" -Path $nuevaRutaHistorial
    Write-Host "La ubicación de la carpeta de Historial se ha cambiado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de Historial."
}

# Cambiar la ubicación de NetHood si es necesario
if ($env:USERPROFILE + "\AppData\Roaming\Microsoft\Windows\Network Shortcuts" -ne $nuevaRutaNetHood) {
    Set-KnownFolderPath -KnownFolder "NetHood" -Path $nuevaRutaNetHood
    Write-Host "La ubicación de la carpeta de NetHood se ha cambiado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de NetHood."
}

# Cambiar la ubicación de PrintHood si es necesario
if ($env:USERPROFILE + "\AppData\Roaming\Microsoft\Windows\Printer Shortcuts" -ne $nuevaRutaPrintHood) {
    Set-KnownFolderPath -KnownFolder "PrintHood" -Path $nuevaRutaPrintHood
    Write-Host "La ubicación de la carpeta de PrintHood se ha cambiado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de PrintHood."
}

# Cambiar la ubicación de SendTo si es necesario
if ($env:USERPROFILE + "\AppData\Roaming\Microsoft\Windows\SendTo" -ne $nuevaRutaSendTo) {
    Set-KnownFolderPath -KnownFolder "SendTo" -Path $nuevaRutaSendTo
    Write-Host "La ubicación de la carpeta de SendTo se ha cambiado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de SendTo."
}

# Cambiar la ubicación de Recent si es necesario
if ($env:USERPROFILE + "\AppData\Roaming\Microsoft\Windows\Recent" -ne $nuevaRutaRecent) {
    Set-KnownFolderPath -KnownFolder "Recent" -Path $nuevaRutaRecent
    Write-Host "La ubicación de la carpeta de Recent se ha cambiado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de Recent."
}

# Cambiar la ubicación de Start Menu si es necesario
if ($env:USERPROFILE + "\AppData\Roaming\Microsoft\Windows\Start Menu" -ne $nuevaRutaStartMenu) {
    Set-KnownFolderPath -KnownFolder "Start Menu" -Path $nuevaRutaStartMenu
    Write-Host "La ubicación de la carpeta de Start Menu se ha cambiado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de Start Menu."
}

# Cambiar la ubicación de Startup si es necesario
if ($env:USERPROFILE + "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" -ne $nuevaRutaStartup) {
    Set-KnownFolderPath -KnownFolder "Startup" -Path $nuevaRutaStartup
    Write-Host "La ubicación de la carpeta de Startup se ha cambiado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de Startup."
}

# Cambiar la ubicación de Templates si es necesario
if ($env:USERPROFILE + "\AppData\Roaming\Microsoft\Windows\Templates" -ne $nuevaRutaTemplates) {
    Set-KnownFolderPath -KnownFolder "Templates" -Path $nuevaRutaTemplates
    Write-Host "La ubicación de la carpeta de Templates se ha cambiado correctamente."
} else {
    Write-Host "La ubicación especificada ya es la ubicación actual de Templates."
}

Write-Host "Proceso completado."
