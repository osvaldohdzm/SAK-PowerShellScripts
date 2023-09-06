Write-Warning "Este proceso puede demorar."
Write-Host "Consultando eventos..."

$events = Get-WinEvent -LogName Security
$relevantEvents = $events | Where-Object {
    ($_.ID -eq 4663 -or $_.ID -eq 4659) -and
    $_.ProviderName -eq "Microsoft-Windows-Security-Auditing"
}

# Procesar los eventos y obtener informacion relevante.
$eventInfo = @()
foreach ($event in $relevantEvents) {
    $properties = $event.Properties
    $eventId = $event.ID

    if ($eventId -eq 4663) {
        $eventDesc = "Intento de acceso a un objeto"
        $userName = $properties[1].Value
        $processName = $properties[11].Value
        $rawRequestAccessInfo = $properties[8].Value
        $objectName = $properties[6].Value
        $objectType = "Archivo"
        $message = "Se elimino ${objectType}: $objectName"
    } elseif ($eventId -eq 4659) {
        $eventDesc = "Inicio de una operacion de rastreo de volumen"
        $userName = $properties[1].Value
        $processName = "ProcessId: 0x" + $properties[12].Value
        $rawRequestAccessInfo = $properties[9].Value
        $objectName = $properties[6].Value
        $objectType = "Volumen"
        $message = "Se elimino $objectName"
    }

    # Convertir rawRequestAccessInfo a valor numerico
    $requestAccessInfo = [int]($rawRequestAccessInfo -replace '[%\.]')

    $accessRightsMapping = @{
        1537 = "DELETE"
        1538 = "READ_CONTROL"
        1539 = "WRITE_DAC"
        1540 = "WRITE_OWNER"
        1541 = "SYNCHRONIZE"
        1542 = "ACCESS_SYS_SEC"
    }

    $accessRight = $accessRightsMapping[$requestAccessInfo]
    if (-not $accessRight) {
        $accessRight = "Desconocido"
    }

    $dateTime = $event.TimeCreated
    $eventInfoEntry = [PSCustomObject]@{
        'EventId' = $eventId
        'Event' = $eventDesc
        'AccountName' = $userName
        'ProcessName' = $processName
        'RequestInformationAccess' = $accessRight
        'DateTime' = $dateTime
        'Tipo de Objeto Eliminado' = $objectType
        'Ruta del Objeto Eliminado' = $objectName
    }

    Write-Host $message
    $eventInfo += $eventInfoEntry
}

# Verificar si hay resultados.
if ($eventInfo.Count -eq 0) {
    Write-Warning "No se encontraron registros de los eventos de interes."
}
else {
    # Guardar los resultados en un archivo CSV
    $csvPath = "Resultados.csv"
    $eventInfo | Export-Csv -Path $csvPath -NoTypeInformation
    Write-Host "Los resultados se han guardado en: $csvPath"
}
