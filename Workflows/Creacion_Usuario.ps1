# --- CONFIGURACIÓN ---
$Username = "asistente"
$Description = "Cuenta Svc - Cumple NIST" 

# --- 1. GENERACIÓN DE CONTRASEÑA ---
$Length = 24
$PasswordRaw = -join ((33..126) | Get-Random -Count $Length | ForEach-Object {[char]$_})
$SecurePassword = $PasswordRaw | ConvertTo-SecureString -AsPlainText -Force

# --- 2. CREACIÓN DEL USUARIO ---
try {
    # CORRECCIÓN: Se eliminó "$true" después de -PasswordNeverExpires
    New-LocalUser -Name $Username `
                  -Password $SecurePassword `
                  -FullName "Asistente Service Account" `
                  -Description $Description `
                  -PasswordNeverExpires `
                  -ErrorAction Stop

    Write-Host "[OK] Usuario '$Username' creado exitosamente." -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Hubo un error: $_" -ForegroundColor Red
    Exit
}

# --- 3. ASIGNACIÓN DE PERMISOS (ADMINISTRADOR) ---
$AdminGroup = Get-LocalGroup | Where-Object { $_.SID -like "*S-1-5-32-544" }

if ($AdminGroup) {
    Add-LocalGroupMember -Group $AdminGroup -Member $Username
    Write-Host "[OK] Usuario añadido al grupo '$($AdminGroup.Name)'." -ForegroundColor Green
} else {
    Write-Host "[ERROR] No se pudo encontrar el grupo de Administradores." -ForegroundColor Red
}

# --- 4. SALIDA DE CREDENCIALES ---
Write-Host "`n------------------------------------------------"
Write-Host " IMPORTANTE: Guarda esta contraseña ahora."
Write-Host "------------------------------------------------"
Write-Host "Usuario:    $Username"
Write-Host "Contraseña: $PasswordRaw" -ForegroundColor Yellow -BackgroundColor Black
Write-Host "------------------------------------------------"