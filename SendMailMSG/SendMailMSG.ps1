# Hora programada fija a las 6:00:00
# $horaProgramada = Get-Date -Hour 22 -Minute 37 -Second 0
# $horaProgramada = Get-Date -Hour 6 -Minute 0 -Second 0

# Ruta del archivo .msg
    $rutaArchivoMsg = "D:\osvaldohm\Desktop\WorkSpaces\ADANSECURE\Proyectos\MNEMO\Plantillas\CorreoElectronico\Notificacion-fin-pruebas-Mnemo.msg"

# Especifica la fecha deseada en formato "dd/MM/yyyy"
$fechaDeseada = "30/09/2023"

$horaProgramada = Get-Date -Hour 6 -Minute 0 -Second 0

# Agregar un número aleatorio de minutos no mayor a 5 minutos
$minutosAleatorios = Get-Random -Minimum 2 -Maximum 5
$horaProgramada = $horaProgramada.AddMinutes($minutosAleatorios)

# Convierte la fecha deseada en un objeto DateTime
$fechaEspecifica = [datetime]::ParseExact($fechaDeseada, "dd/MM/yyyy", $null)

# Convierte la hora programada y la fecha especificada en formatos legibles
$horaFormateada = $horaProgramada.ToString("HH:mm tt")
$fechaFormateada = $fechaEspecifica.ToString("yyyy-MM-dd")

# Mostrar mensaje de inicio con la fecha y hora programada
Write-Host "Programando mensaje para el $fechaFormateada a las $horaFormateada..."

# Obtener la fecha y hora actual
$fechaHoraActual = Get-Date

# Combinar la fecha de la hora programada con la fecha actual para comparar
$fechaHoraProgramada = $fechaEspecifica.Add($horaProgramada.TimeOfDay)

# Comparar la fecha y hora programadas con la fecha y hora actual
if ($fechaHoraProgramada -le $fechaHoraActual) {
    Write-Host "Error al enviar el revisa la fecha de envío, debe ser superior a la actual"
    exit 0
}

# Calcular la cantidad de segundos hasta la hora programada
$segundosParaEnvio = ($fechaHoraProgramada - $fechaHoraActual).TotalSeconds

write-host $segundosParaEnvio

# Esperar hasta la hora programada
Start-Sleep -Seconds $segundosParaEnvio

try {
    # Crear una instancia de Outlook
    $Outlook = New-Object -ComObject Outlook.Application

    
    # Abrir el archivo .msg
    $MailItem = $Outlook.Session.OpenSharedItem($rutaArchivoMsg)

    # Enviar el correo
    $MailItem.Send()

    # Mostrar mensaje de confirmación con la fecha y hora programada
    Write-Host "Mensaje enviado el $fechaFormateada a las $horaFormateada."
}
catch {
    Write-Host "Error al enviar el mensaje: $_"
}
