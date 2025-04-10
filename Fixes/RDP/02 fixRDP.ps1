#Requires -RunAsAdministrator

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

}




#region --- Configuración Inicial y Verificación de Privilegios ---

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host " Script de Diagnóstico y Corrección AUTOMÁTICA RDP " -ForegroundColor Cyan
Write-Host "      ¡APLICA CAMBIOS SIN CONFIRMACIÓN!      " -ForegroundColor Yellow
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "Timestamp: $(Get-Date)"

# Verificar si se está ejecutando como Administrador
Write-Host "`n[*] Verificando privilegios de administrador..." -ForegroundColor Yellow
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Este script requiere privilegios de Administrador. Por favor, ejecútalo como Administrador."
    if ($Host.Name -eq 'ConsoleHost') { Read-Host "Presiona Enter para salir." }
    Exit 1
} else {
    Write-Host "[✓] Ejecutando con privilegios de Administrador." -ForegroundColor Green
}

#endregion

#region --- Variables de Configuración ---

$ComputerName = $env:COMPUTERNAME
$RdpPort = 3389
$RegPathRdpEnable = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server"
$RegKeyRdpEnable = "fDenyTSConnections" # 0 = Habilitado, 1 = Deshabilitado
$PolicyRegPathRdpEnable = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$ServicesToCheck = @("TermService", "UmRdpService")
$NlaRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
$NlaRegName = "UserAuthentication" # 1 = NLA Habilitado (Preferido), 0 = NLA Deshabilitado
$SecurityLayerRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$SecurityLayerRegName = "SecurityLayer"
$SecurityLayerRegValue = 0 # 0 = RDP Security Layer (más compatible)
$FirewallRuleGroup = "Remote Desktop"
$RdpEventLogName = 'Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Operational'

#endregion

# --- Inicio del Diagnóstico ---
Write-Host "`n[*] Iniciando Diagnóstico y Corrección Automática RDP para '$ComputerName'..." -ForegroundColor Cyan
Write-Host "-----------------------------------------------------"

#region --- [1] Verificación de Registro RDP (Habilitación Principal) ---

Write-Host "`n[1] Verificando Configuración de Registro RDP..." -ForegroundColor Yellow
$rdpShouldBeEnabled = $true # Asumimos que debería estar habilitado a menos que GPO diga lo contrario

# 1.1 Verificar y Corregir Configuración Local en el Registro
try {
    $CurrentValue = Get-ItemProperty -Path $RegPathRdpEnable -Name $RegKeyRdpEnable -ErrorAction SilentlyContinue
    if ($CurrentValue -ne $null) {
        if ($CurrentValue.fDenyTSConnections -eq 1) {
            Write-Warning "[!] RDP está DESHABILITADO localmente en el registro. Aplicando corrección..."
            try {
                Set-ItemProperty -Path $RegPathRdpEnable -Name $RegKeyRdpEnable -Value 0 -ErrorAction Stop
                Write-Host "[✓] RDP habilitado automáticamente en el registro local ($RegKeyRdpEnable = 0)." -ForegroundColor Green
            } catch {
                Write-Error "Error al habilitar RDP en el registro '$RegPathRdpEnable\$RegKeyRdpEnable' $($_.Exception.Message)"
            }
        } else {
            Write-Host "[✓] RDP ya está HABILITADO localmente en el registro ($RegPathRdpEnable\$RegKeyRdpEnable = 0)." -ForegroundColor Green
        }
    } else {
        Write-Host "[i] Clave de registro '$RegKeyRdpEnable' no encontrada. Asumiendo RDP habilitado (predeterminado)." -ForegroundColor Green
    }
} catch {
    Write-Error "Error al leer/modificar la clave de registro '$RegPathRdpEnable\$RegKeyRdpEnable' $($_.Exception.Message)"
}

# 1.2 Verificar si una Política de Grupo (GPO) anula la configuración (Informativo)
Write-Host "`n[1.1] Verificando Política de Grupo para RDP (Informativo)..." -ForegroundColor Yellow
try {
    $PolicyValue = Get-ItemProperty -Path $PolicyRegPathRdpEnable -Name $RegKeyRdpEnable -ErrorAction SilentlyContinue
    if ($PolicyValue -ne $null) {
        if ($PolicyValue.fDenyTSConnections -eq 1) {
            Write-Warning "[!!!] La Política de Grupo (GPO) está DESHABILITANDO RDP ($PolicyRegPathRdpEnable\$RegKeyRdpEnable = 1)."
            Write-Warning "      Esta GPO anula los ajustes locales. ¡RDP NO funcionará! Se requiere cambio manual de GPO."
            $rdpShouldBeEnabled = $false
        } elseif ($PolicyValue.fDenyTSConnections -eq 0) {
            Write-Host "[✓] La Política de Grupo (GPO) HABILITA explícitamente RDP." -ForegroundColor Green
        }
    } else {
        Write-Host "[i] No se encontró GPO explícita para habilitar/deshabilitar RDP."
    }
} catch {
    Write-Error "Error al leer la clave de registro de GPO '$PolicyRegPathRdpEnable\$RegKeyRdpEnable' $($_.Exception.Message)"
}

#endregion

#region --- [2] Verificación y Corrección de Servicios RDP ---

if ($rdpShouldBeEnabled) {
    Write-Host "`n[2] Verificando e iniciando Servicios RDP requeridos..." -ForegroundColor Yellow
    $allServicesRunningOrStarted = $true # Asumir éxito inicial
    foreach ($ServiceName in $ServicesToCheck) {
        try {
            $ServiceInfo = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
            if ($ServiceInfo) {
                $status = $ServiceInfo.Status
                $displayName = $ServiceInfo.DisplayName
                if ($status -eq 'Running') {
                    Write-Host "[✓] Servicio '$displayName' ($ServiceName) ya está [$status]." -ForegroundColor Green
                } else {
                    Write-Warning "[!] Servicio '$displayName' ($ServiceName) está [$status]. Intentando iniciar..."
                    try {
                        Start-Service -Name $ServiceName -ErrorAction Stop
                        Start-Sleep -Seconds 2 # Pausa breve
                        $ServiceInfo = Get-Service -Name $ServiceName # Re-verificar
                        if ($ServiceInfo.Status -eq 'Running') {
                            Write-Host "[✓] Servicio '$displayName' iniciado correctamente. Estado actual [$($ServiceInfo.Status)]." -ForegroundColor Green
                        } else {
                             Write-Warning "[!] Fallo al iniciar el servicio '$displayName'. Estado actual [$($ServiceInfo.Status)]."
                             $allServicesRunningOrStarted = $false
                        }
                    } catch {
                        Write-Error "Error al iniciar el servicio '$ServiceName' $($_.Exception.Message)"
                        $allServicesRunningOrStarted = $false
                    }
                }
            } else {
                Write-Warning "[!] Servicio requerido '$ServiceName' no encontrado."
                $allServicesRunningOrStarted = $false
            }
        } catch {
            Write-Error "Error al consultar/iniciar el servicio '$ServiceName' $($_.Exception.Message)"
            $allServicesRunningOrStarted = $false
        }
    }
    if (-not $allServicesRunningOrStarted) {
         Write-Warning "[!] Uno o más servicios RDP no pudieron ser iniciados."
    }
} else {
     Write-Host "`n[2] Omitiendo Servicios RDP porque una GPO deshabilita RDP." -ForegroundColor Yellow
}

#endregion

#region --- [3] Verificación del Listener RDP (RDP-Tcp) ---

if ($rdpShouldBeEnabled) {
    Write-Host "`n[3] Verificando Listener RDP (RDP-Tcp) vía WMI..." -ForegroundColor Yellow
    $listenerOk = $false
    try {
        $Listener = Get-CimInstance -ClassName "Win32_TSNetworkAdapterListener" -Namespace "ROOT\CIMV2\TerminalServices" -Filter "NetworkAdapterName='RDP-Tcp'" -ErrorAction SilentlyContinue
        if ($Listener) {
            Write-Host "[✓] Listener RDP 'RDP-Tcp' encontrado y activo." -ForegroundColor Green
            $listenerOk = $true
        } else {
            Write-Warning "[!] Listener RDP 'RDP-Tcp' no encontrado o inactivo."
        }
    } catch {
        Write-Error "Error al verificar el Listener RDP vía WMI $($_.Exception.Message)"
    }
} else {
     Write-Host "`n[3] Omitiendo Listener RDP porque una GPO deshabilita RDP." -ForegroundColor Yellow
}

#endregion

#region --- [4] Verificación del Puerto RDP ---

if ($rdpShouldBeEnabled) {
    Write-Host "`n[4] Verificando si el puerto TCP $RdpPort está escuchando..." -ForegroundColor Yellow
    $portListening = $false
    try {
        $PortCheck = Get-NetTCPConnection -LocalPort $RdpPort -State Listen -ErrorAction SilentlyContinue
        if ($PortCheck) {
            Write-Host "[✓] El puerto TCP $RdpPort está en estado 'Listen'." -ForegroundColor Green
            $portListening = $true
        } else {
            Write-Warning "[!] El puerto TCP $RdpPort NO está en estado 'Listen'."
            # No se intenta corregir aquí, depende de los servicios/listener/firewall
        }
    } catch {
        Write-Error "Error al verificar conexiones TCP en el puerto $RdpPort $($_.Exception.Message)"
    }
} else {
    Write-Host "`n[4] Omitiendo Puerto RDP porque una GPO deshabilita RDP." -ForegroundColor Yellow
}

#endregion

#region --- [5] Verificación y Corrección de Reglas del Firewall de Windows ---

if ($rdpShouldBeEnabled) {
    Write-Host "`n[5] Verificando y habilitando Reglas del Firewall para '$FirewallRuleGroup'..." -ForegroundColor Yellow
    $firewallRulesOk = $false
    try {
        $FirewallRules = Get-NetFirewallRule -DisplayGroup $firewallRuleGroup -ErrorAction SilentlyContinue

        if ($FirewallRules) {
            $anyEnabled = $false
            $anyDisabled = $false
            foreach ($rule in $FirewallRules) {
                if ($rule.Enabled) {
                    $anyEnabled = $true
                } else {
                    $anyDisabled = $true
                    Write-Warning "[!] Regla de firewall '$($rule.DisplayName)' (Perfil $($rule.Profile -join ',')) está Deshabilitada."
                }
            }

            if ($anyEnabled -and -not $anyDisabled) {
                 Write-Host "[✓] Todas las reglas encontradas para '$firewallRuleGroup' ya están habilitadas." -ForegroundColor Green
                 $firewallRulesOk = $true
            } elseif ($anyDisabled) {
                Write-Warning "[!] Se encontraron reglas deshabilitadas para '$firewallRuleGroup'. Habilitando automáticamente..."
                try {
                    Enable-NetFirewallRule -DisplayGroup $firewallRuleGroup -ErrorAction Stop
                    Write-Host "[✓] Grupo de reglas '$firewallRuleGroup' habilitado en el firewall." -ForegroundColor Green
                    $firewallRulesOk = $true
                } catch {
                    Write-Error "Error al habilitar el grupo de reglas '$firewallRuleGroup' $($_.Exception.Message)"
                }
            } else { # $anyEnabled es true y $anyDisabled es true (estado mixto)
                 Write-Host "[i] Algunas reglas de '$firewallRuleGroup' están habilitadas, otras deshabilitadas. Habilitando todas..." -ForegroundColor Yellow
                  try {
                    Enable-NetFirewallRule -DisplayGroup $firewallRuleGroup -ErrorAction Stop
                    Write-Host "[✓] Grupo de reglas '$firewallRuleGroup' habilitado en el firewall." -ForegroundColor Green
                    $firewallRulesOk = $true
                } catch {
                    Write-Error "Error al habilitar el grupo de reglas '$firewallRuleGroup' $($_.Exception.Message)"
                }
            }
        } else {
            Write-Warning "[!] No se encontraron reglas de Firewall para el grupo '$firewallRuleGroup'. No se realizó ninguna acción."
            # No intentar habilitar un grupo que no existe.
        }
    } catch {
        Write-Error "Error al obtener/evaluar/habilitar las reglas del firewall $($_.Exception.Message)"
    }
} else {
     Write-Host "`n[5] Omitiendo Firewall porque una GPO deshabilita RDP." -ForegroundColor Yellow
}

#endregion

#region --- [6] Verificación y Corrección de Autenticación a Nivel de Red (NLA) ---

if ($rdpShouldBeEnabled) {
    Write-Host "`n[6] Verificando y configurando Autenticación a Nivel de Red (NLA)..." -ForegroundColor Yellow
    Write-Host "    (Se configurará NLA como HABILITADO por seguridad)"

    try {
        if (Test-Path $NlaRegPath) {
            $nlaValue = Get-ItemProperty -Path $NlaRegPath -Name $NlaRegName -ErrorAction SilentlyContinue
            # Comprobar si existe y si es 0 (Deshabilitado)
            if ($nlaValue -ne $null -and $nlaValue.$NlaRegName -eq 1) {
                 Write-Warning "[!] NLA está HABILITADO (Registro $NlaRegName = 0). Deshabilitando NLA automáticamente..."
                 try {
                    Set-ItemProperty -Path $NlaRegPath -Name $NlaRegName -Value 0 -ErrorAction Stop
                    Write-Host "[✓] NLA DESHABILITADO automáticamente en el registro." -ForegroundColor Green
                } catch {
                    Write-Error "Error al deshabilitar NLA $($_.Exception.Message)"
                }
            } elseif ($nlaValue -ne $null -and $nlaValue.$NlaRegName -eq 1) {
                Write-Host "[✓] NLA ya está HABILITADO (Registro $NlaRegName = 1)." -ForegroundColor Green
            } else {
                 Write-Warning "[!] No se pudo determinar el estado de NLA o tiene un valor inesperado en '$NlaRegPath\$NlaRegName'."
                 Write-Warning "    Intentando establecer NLA a HABILITADO (1) por defecto..."
                 try {
                    Set-ItemProperty -Path $NlaRegPath -Name $NlaRegName -Value 1 -Type DWord -Force -ErrorAction Stop # Force crea si no existe
                    Write-Host "[✓] NLA HABILITADO automáticamente en el registro (valor forzado/creado)." -ForegroundColor Green
                 } catch {
                     Write-Error "Error al intentar forzar/crear la configuración NLA a Habilitado $($_.Exception.Message)"
                 }
            }
        } else {
            Write-Warning "[!] La ruta de registro NLA '$NlaRegPath' no existe. Creando y habilitando NLA..."
             try {
                # Si la ruta no existe, Set-ItemProperty con -Force la creará (junto con el valor)
                Set-ItemProperty -Path $NlaRegPath -Name $NlaRegName -Value 1 -Type DWord -Force -ErrorAction Stop
                Write-Host "[✓] NLA HABILITADO automáticamente (ruta y clave creadas)." -ForegroundColor Green
            } catch {
                Write-Error "Error al crear la ruta/clave y habilitar NLA $($_.Exception.Message)"
            }
        }
    } catch {
        Write-Error "Error general al procesar la configuración NLA $($_.Exception.Message)"
    }
} else {
     Write-Host "`n[6] Omitiendo NLA porque una GPO deshabilita RDP." -ForegroundColor Yellow
}

#endregion

#region --- [7] Comprobación de Eventos de Error RDP Recientes (Informativo) ---

Write-Host "`n[7] Comprobando Eventos de Error/Advertencia de RDP recientes (últimas 24h)..." -ForegroundColor Yellow
try {
    $StartTime = (Get-Date).AddDays(-1)
    $rdpEvents = Get-WinEvent -FilterHashtable @{
        LogName = $RdpEventLogName
        Level = 1, 2, 3 # Critical, Error, Warning
        StartTime = $StartTime
    } -ErrorAction SilentlyContinue

    if ($rdpEvents) {
        Write-Warning "[!] Se encontraron errores o advertencias de RDP recientes en '$RdpEventLogName'."
        Write-Host "    Mostrando los 5 más recientes (informativo):"
        $rdpEvents | Sort-Object TimeCreated -Descending | Select-Object -First 5 | Format-Table TimeCreated, Id, LevelDisplayName, Message -AutoSize -Wrap
    } else {
        Write-Host "[✓] No se encontraron errores o advertencias de RDP recientes en '$RdpEventLogName'." -ForegroundColor Green
    }
} catch {
     Write-Error "Error al consultar el log de eventos '$RdpEventLogName' $($_.Exception.Message)"
}

#endregion

#region --- [8] Verificación y Corrección de Capa de Seguridad RDP ---

if ($rdpShouldBeEnabled) {
    Write-Host "`n[8] Verificando/Configurando Capa de Seguridad RDP a '$SecurityLayerRegValue' (Compatibilidad)..." -ForegroundColor Yellow
    try {
        # Crear ruta de políticas si no existe, necesario para Set-ItemProperty -Force si no hay GPOs
        if (-not (Test-Path $SecurityLayerRegPath)) {
            Write-Host "[i] Creando ruta de registro para políticas $SecurityLayerRegPath" -ForegroundColor DarkGray
            New-Item -Path $SecurityLayerRegPath -Force -ErrorAction Stop | Out-Null
        }

        $currentSecLayer = Get-ItemProperty -Path $SecurityLayerRegPath -Name $SecurityLayerRegName -ErrorAction SilentlyContinue

        if ($currentSecLayer -ne $null -and $currentSecLayer.$SecurityLayerRegName -eq $SecurityLayerRegValue) {
             Write-Host "[✓] La capa de seguridad RDP ya está configurada al valor deseado ($SecurityLayerRegValue)." -ForegroundColor Green
        } else {
            if ($currentSecLayer -ne $null) {
                Write-Warning "[!] La capa de seguridad RDP actual es '$($currentSecLayer.$SecurityLayerRegName)'. Estableciendo a '$SecurityLayerRegValue'..."
            } else {
                Write-Warning "[!] La capa de seguridad RDP no está definida explícitamente. Estableciendo a '$SecurityLayerRegValue'..."
            }
            try {
                Set-ItemProperty -Path $SecurityLayerRegPath -Name $SecurityLayerRegName -Value $SecurityLayerRegValue -Type DWord -Force -ErrorAction Stop
                Write-Host "[✓] Valor de registro 'SecurityLayer' establecido automáticamente a '$SecurityLayerRegValue'." -ForegroundColor Green
                Write-Host "[i] Ejecutando gpupdate /force..." -ForegroundColor DarkGray
                gpupdate /force
            } catch {
                Write-Error "Error al configurar la capa de seguridad RDP $($_.Exception.Message)"
            }
        }
    } catch {
        Write-Error "Error general al procesar la capa de seguridad RDP $($_.Exception.Message)"
    }
} else {
     Write-Host "`n[8] Omitiendo Capa de Seguridad RDP porque una GPO deshabilita RDP." -ForegroundColor Yellow
}

#endregion

wevtutil clear-log "Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Operational" 

# Check the status of the TermService (Remote Desktop Service)
$service = Get-Service -Name "TermService"
$serviceStatus = $service.Status

# Check if the service is stuck in "Stop Pending" state
if ($serviceStatus -eq "StopPending") {
    Write-Host "Service is stuck in Stop Pending state. Attempting to force stop..."

    # Get the PID of the TermService
    $serviceQuery = sc queryex TermService
    $pid = ($serviceQuery | Select-String -Pattern "PID" | ForEach-Object { $_.ToString().Split(":")[1].Trim() })

    # Kill the process associated with TermService
    Write-Host "Killing process with PID $pid..."
    Stop-Process -Id $pid -Force

    # Wait a few seconds to ensure the service stops
    Start-Sleep -Seconds 3
}

# Restart the TermService
Write-Host "Restarting the TermService..."
Restart-Service -Name "TermService" -Force

# Wait a few seconds to ensure the service restarts
Start-Sleep -Seconds 5

# Verify the service status
$service = Get-Service -Name "TermService"
if ($service.Status -eq "Running") {
    Write-Host "Remote Desktop Service (TermService) is successfully restarted and running."
} else {
    Write-Host "Failed to restart Remote Desktop Service (TermService)."
}

# Verify RDP session status
$rdpSessions = qwinsta
if ($rdpSessions -match "rdp-tcp\s+(\d+)\s+Listen") {
    Write-Host "RDP session is in Listen state. Remote Desktop should be functional."
} else {
    Write-Host "No RDP session is in Listen state. Please check manually."
}
