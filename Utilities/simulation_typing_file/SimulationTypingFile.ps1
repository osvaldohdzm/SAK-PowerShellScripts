#.\SimulationTypingFile.ps1 -File "D:\osvaldohm\Desktop\encoded-b64-file.txt" -InitialDelay 3 -StringDelay 200

param (
    [string]$File,
    [int]$InitialDelay = 3,
    [int]$StringDelay = 200,  # 200 milisegundos por defecto
    [int]$WriteLine = $null  # WriteLine es opcional y tiene valor predeterminado $null
)

# Verifica si se proporcionó un archivo de texto válido
if (-not $File -or -not (Test-Path -Path $File -PathType Leaf)) {
    Write-Host "Por favor, proporciona un archivo de texto válido como parámetro."
    exit
}

# Verifica si los valores de InitialDelay son válidos (deben ser valores positivos)
if ($InitialDelay -lt 0) {
    Write-Host "Los valores de los parámetros deben ser números positivos."
    exit
}

# Cargar el ensamblado System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms

# Función para escapar caracteres especiales
function Escape-SendKeysCharacters {
    param (
        [string]$text
    )
    $text = $text -replace '([{}^%~])', '{$1}'  # Escapa caracteres especiales
    return $text
}

# Función para simular la pulsación de la tecla "Enter"
function Simulate-EnterKey {
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
}

# Agregar espera inicial antes de empezar a escribir
Write-Host "Esperando $InitialDelay segundos antes de empezar a escribir..."
Start-Sleep -Seconds $InitialDelay

$texto = Get-Content $File

# Si se especifica WriteLine y no es $null, escribir solo esa línea
if ($WriteLine -ne $null -and $WriteLine -gt 0) {
    $linea = $texto[$WriteLine - 1]
    $linea = Escape-SendKeysCharacters $linea
    [System.Windows.Forms.SendKeys]::SendWait($linea)
}
else {
    # Dividir el texto en líneas y enviar cada línea con un salto de línea
    $lineas = $texto -split "`n"
    foreach ($linea in $lineas) {
        $linea = Escape-SendKeysCharacters $linea
        foreach ($caracter in $linea.ToCharArray()) {
            [System.Windows.Forms.SendKeys]::SendWait($caracter)
            Start-Sleep -Milliseconds $StringDelay  # Usar el valor de StringDelay especificado
        }
        Simulate-EnterKey  # Simula un salto de línea al final de cada línea
    }
}

Write-Host "Proceso completado."
