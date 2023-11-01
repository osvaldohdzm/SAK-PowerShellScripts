param (
    [string]$sfile,
    [int]$keystrokeDelay = 20,
    [int]$count = 10,  # Nuevo parámetro para el número de caracteres por grupo
    [switch]$test
)

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

# Si no se proporcionó un archivo y no se está en modo de prueba, solicita al usuario que copie un texto
if (-not $sfile -and -not $test) {
    $texto = Read-Host "Por favor, copia el texto y presiona Enter"
    $texto = Escape-SendKeysCharacters $texto

    # Agregar retraso de 3 segundos antes de empezar a escribir
    Start-Sleep -Seconds 3

    # Divide el texto en partes de acuerdo a $count caracteres y envía cada parte con un Enter
    $chunks = [System.Collections.Generic.List[string]]@{}
    for ($i = 0; $i -lt $texto.Length; $i += $count) {
        $chunk = $texto.Substring($i, [Math]::Min($count, $texto.Length - $i))
        $chunks.Add($chunk)
    }

    # Envía cada parte con el retraso especificado y luego simula la pulsación de Enter
    foreach ($chunk in $chunks) {
        [System.Windows.Forms.SendKeys]::SendWait($chunk)
        Start-Sleep -Milliseconds $keystrokeDelay
        Simulate-EnterKey  # Simula la pulsación de Enter
    }
}
else {
    if ($sfile) {
        # Verifica si se proporcionó un archivo de texto válido
        if (-not (Test-Path -Path $sfile -PathType Leaf)) {
            Write-Host "Por favor, proporciona un archivo de texto válido como parámetro."
            exit
        }
        
        # Verifica si el retraso entre pulsaciones es válido (debe ser un valor positivo)
        if ($keystrokeDelay -le 0) {
            Write-Host "El valor del parámetro -keystrokeDelay debe ser un número positivo."
            exit
        }

        # Agregar retraso de 3 segundos antes de empezar a escribir
        Start-Sleep -Seconds 3

        $texto = Get-Content $sfile
        $texto = Escape-SendKeysCharacters $texto

        # Divide el texto en partes de acuerdo a $count caracteres y envía cada parte con un Enter
        $chunks = [System.Collections.Generic.List[string]]@{}
        for ($i = 0; $i -lt $texto.Length; $i += $count) {
            $chunk = $texto.Substring($i, [Math]::Min($count, $texto.Length - $i))
            $chunks.Add($chunk)
        }

        # Envía cada parte con el retraso especificado y luego simula la pulsación de Enter
        foreach ($chunk in $chunks) {
            [System.Windows.Forms.SendKeys]::SendWait($chunk)
            Start-Sleep -Milliseconds $keystrokeDelay
            Simulate-EnterKey  # Simula la pulsación de Enter
        }
    }
    elseif ($test) {
        # Preámbulo que se escribirá solo cuando se use la opción -test
        $preambulo = "AC-O-M-E-N-Z-A-N-D-O-T-R-A-N-S-F-E-R-E-N-C-I-A-D-E-A-R-C-H-I-V-O"
        $preambulo = Escape-SendKeysCharacters $preambulo

        # Agregar retraso de 3 segundos antes de empezar a escribir
        Start-Sleep -Seconds 3

        # Divide el preámbulo en partes de acuerdo a $count caracteres y envía cada parte con un Enter
        $chunks = [System.Collections.Generic.List[string]]@{}
        for ($i = 0; $i -lt $preambulo.Length; $i += $count) {
            $chunk = $preambulo.Substring($i, [Math]::Min($count, $preambulo.Length - $i))
            $chunks.Add($chunk)
        }

        # Envía cada parte con el retraso especificado y luego simula la pulsación de Enter
        foreach ($chunk in $chunks) {
            [System.Windows.Forms.SendKeys]::SendWait($chunk)
            Start-Sleep -Milliseconds $keystrokeDelay
            Simulate-EnterKey  # Simula la pulsación de Enter
        }
    }
}
