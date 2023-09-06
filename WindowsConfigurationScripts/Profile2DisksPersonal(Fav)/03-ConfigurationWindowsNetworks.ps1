# Nombre de la red (SSID) y contraseña
$networkName = "HMWLAN2"
$networkPassword = "60aghNaMEwuYSM"

# Convertir el nombre de red a hexadecimal
$hexNetworkName = -join ([System.Text.Encoding]::UTF8.GetBytes($networkName) | ForEach-Object { $_.ToString("X2") })

# Configurar la conexión Wi-Fi
$wifiProfileXml = @"
<?xml version='1.0'?>
<WLANProfile xmlns='http://www.microsoft.com/networking/WLAN/profile/v1'>
	<name>$networkName</name>
	<SSIDConfig>
		<SSID>
			<hex>$hexNetworkName</hex>
			<name>$networkName</name>
		</SSID>
	</SSIDConfig>
	<connectionType>ESS</connectionType>
	<connectionMode>auto</connectionMode>
	<MSM>
		<security>
			<authEncryption>
				<authentication>WPA2PSK</authentication>
				<encryption>AES</encryption>
				<useOneX>false</useOneX>
			</authEncryption>
			<sharedKey>
				<keyType>passPhrase</keyType>
				<protected>false</protected>
				<keyMaterial>$networkPassword</keyMaterial>
			</sharedKey>
		</security>
	</MSM>
</WLANProfile>
"@

# Obtener la ruta de la carpeta temporal del sistema
$tempFolderPath = [System.IO.Path]::GetTempPath()

# Ruta completa del archivo de perfil de red Wi-Fi en la carpeta temporal
$wifiProfilePath = Join-Path -Path $tempFolderPath -ChildPath "wifi.xml"

# Agregar el perfil de red Wi-Fi
$wifiProfileXml | Out-File -Encoding utf8 -FilePath $wifiProfilePath
netsh wlan add profile filename=$wifiProfilePath

# Conectar a la red Wi-Fi
netsh wlan connect name=$networkName
