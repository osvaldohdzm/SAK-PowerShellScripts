# Solicita al usuario que copie un texto y lo almacena en una variable
$texto = Read-Host "Por favor, copia el texto y presiona Enter"

# Espera 3 segundos
Start-Sleep -Seconds 3

# Simula pulsaciones de teclado para "teclear" el contenido del portapapeles
Add-Type -AssemblyName System.Windows.Forms
$textBox = New-Object Windows.Forms.TextBox
$textBox.Paste()
$textoPegado = $textBox.Text

# Simula la escritura del texto en el área donde se encuentra el cursor
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait($textoPegado)
