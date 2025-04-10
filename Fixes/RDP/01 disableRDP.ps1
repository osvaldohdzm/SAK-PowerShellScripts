# Ejecutar como Administrador

Write-Host "🔒 Deshabilitando RDP..."

# 1. Deshabilitar RDP en el sistema
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1

# 2. Deshabilitar RDP en el firewall
Disable-NetFirewallRule -DisplayGroup "Remote Desktop"

Write-Host "✅ RDP deshabilitado a nivel de sistema y firewall."

# 3. Verificar si el servicio RDS-RD-Server está instalado
$feature = Get-WindowsFeature -Name RDS-RD-Server

if ($feature -and $feature.Installed) {
    Write-Host "🛠 Desinstalando Remote Desktop Session Host (RDS-RD-Server)..."
    
    # 4. Desinstalar RDS-RD-Server
    Uninstall-WindowsFeature -Name RDS-RD-Server -Restart
} else {
    Write-Host "✅ El servicio RDS-RD-Server no está instalado. No es necesario desinstalar."
    
    # 5. Reiniciar manualmente ya que no hay desinstalación automática
    Write-Host "🔁 Reiniciando el sistema para aplicar cambios..."
}
