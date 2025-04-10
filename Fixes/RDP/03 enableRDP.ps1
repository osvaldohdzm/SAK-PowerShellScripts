# Ejecutar como Administrador

Write-Host "🔓 Habilitando RDP..."

# 1. Habilitar RDP en el sistema
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

# 2. Habilitar regla de firewall para RDP
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

Write-Host "✅ RDP habilitado a nivel de sistema y firewall."

# 3. Verificar si el servicio RDS-RD-Server está instalado
$feature = Get-WindowsFeature -Name RDS-RD-Server

if (-not $feature.Installed) {
    Write-Host "📦 Instalando Remote Desktop Session Host (RDS-RD-Server)..."
    
    # 4. Instalar RDS-RD-Server
    Install-WindowsFeature -Name RDS-RD-Server -IncludeAllSubFeature -IncludeManagementTools -Restart
} else {
    Write-Host "✅ El servicio RDS-RD-Server ya está instalado. Reiniciando el sistema para asegurar los cambios..."
}
