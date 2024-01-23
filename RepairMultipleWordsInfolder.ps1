# Ruta de la carpeta de ejecución
$carpeta = Split-Path $MyInvocation.MyCommand.Path

# Crear una instancia de Word y hacerla visible
$wordApp = New-Object -ComObject Word.Application
$wordApp.Visible = $true

# Obtener todos los archivos .docx en la carpeta
$archivos = Get-ChildItem -Path $carpeta -Filter *.docx

foreach ($archivo in $archivos) {
    try {
        # Abrir el documento en modo de solo lectura y reparación
        $doc = $wordApp.Documents.Open($archivo.FullName, $false, $false, $false, "", "", $false, "", "", 0, $null, $null, $true)

        # Realizar cambios necesarios para reparar el documento

        # Guardar el documento automáticamente
        $doc.SaveAs($archivo.FullName)

        # Cerrar el documento
        $doc.Close()

        Write-Host "Archivo reparado y guardado: $($archivo.FullName)"
    }
    catch {
        Write-Host "Error al procesar el archivo: $($archivo.FullName)"
    }
}

# Cerrar la instancia de Word
$wordApp.Quit()
