# Limpiar el portapapeles
[System.Windows.Forms.Clipboard]::Clear()

Write-Host "Este script copiará el texto que ya tengas en el portapapeles, así que pulsa Enter cuando estés listo para continuar."
Read-Host "Presiona Enter después de copiar el texto al portapapeles."

# Captura el contenido del portapapeles y verifica si contiene texto
$clipboardText = [System.Windows.Forms.Clipboard]::GetText()
if (![string]::IsNullOrEmpty($clipboardText)) {
    # Mostrar el texto completo del portapapeles
    Write-Host "Texto en el portapapeles:"
    Write-Host $clipboardText

    # Espera 3 segundos (puedes ajustar este valor si es necesario)
    Start-Sleep -Seconds 3

    # Simula la escritura del texto en el área donde se encuentra el cursor y utiliza el carácter especial para hacer saltos de línea
    Add-Type -AssemblyName System.Windows.Forms
    foreach ($char in $clipboardText.ToCharArray()) {
        Write-Host "Simulando escritura de: $char"
        [System.Windows.Forms.SendKeys]::SendWait($char)
        if ($char -eq '|') {
            [System.Windows.Forms.SendKeys]::SendWait('{Enter}')
        }
    }
} else {
    Write-Host "El portapapeles está vacío o no contiene texto válido."
}
