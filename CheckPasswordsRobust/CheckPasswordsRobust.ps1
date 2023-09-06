function EstimateCrackTime {
    param (
        [string]$password
    )

    # Define los conjuntos de caracteres
    $lowercase = 'abcdefghijklmnopqrstuvwxyz'
    $uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $numbers = '0123456789'
    $symbols = '!@#$%^&*()-_=+[]{}|;:,.<>?'

    $charsets = @($lowercase, $uppercase, $numbers, $symbols)

    # Calcula la cantidad de caracteres únicos en la contraseña
    $unique_chars = ($password.ToCharArray() | Select-Object -Unique).Count

    # Calcula la entropía en bits
    $entropy_bits = [math]::Log([math]::Pow($unique_chars, $password.Length), 2)

    # Estimación de tiempo de descifrado
    $attempts_per_second = 1  # intentos por segundo
    $adjuster_value = 200 
    $seconds_per_attempt = [math]::Pow(2, $entropy_bits) / ($attempts_per_second * $adjuster_value)

    # Convierte segundos a una unidad de tiempo legible
    $time_units = @('seconds', 'minutes', 'hours', 'days', 'months', 'years', 'centuries')
    $time_ratios = @(1, 60, 3600, 86400, 2628000, 31536000, 3153600000)

    $time_index = [math]::Min([math]::Floor([math]::Log($seconds_per_attempt, 60)), $time_units.Length - 1)
    
    # Cambia "instantly" si el tiempo es muy pequeño
    if ($time_index -le 0) {
    $time_value = 0
    $time_unit = "instantly"
} else {
    $time_value = $seconds_per_attempt / $time_ratios[$time_index]
    $time_unit = $time_units[$time_index]
}

    # Format the output based on the condition
if ($time_unit -eq "instantly") {
    Write-Host "Estimated time to crack password with $($password.Length) characters and complexity: $time_unit"
} else {
    Write-Host "Estimated time to crack password with $($password.Length) characters and complexity: $($time_value.ToString("F2")) $time_unit"
}
}

# Solicitar al usuario ingresar una palabra propuesta como contraseña
$password = Read-Host "Enter proposed password"
EstimateCrackTime -password $password
