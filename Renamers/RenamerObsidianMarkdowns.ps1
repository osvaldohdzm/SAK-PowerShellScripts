# Obtener la ruta de la carpeta donde se ejecuta el script
$carpetaActual = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Obtener la lista de archivos Markdown en la carpeta actual
$archivosMarkdown = Get-ChildItem -Path $carpetaActual -Filter *.md

# Inicializar contador para la nueva numeración
$contador = 0

# Recorrer cada archivo Markdown
foreach ($archivo in $archivosMarkdown) {
    # Obtener el nombre base del archivo sin la extensión
    $nombreBase = $archivo.BaseName

    # Verificar si el nombre base del archivo tiene una numeración al principio
    if ($nombreBase -match '^(\d{2,})\s') {
        # Si tiene una numeración al principio, se reemplaza con una nueva numeración
        $nuevoNombre = "{0:D2} {1}" -f $contador, $nombreBase.Substring($matches[0].Length)
    } else {
        # Si no tiene una numeración al principio, se agrega una nueva numeración al principio
        $nuevoNombre = "{0:D2} {1}" -f $contador, $nombreBase
    }

    # Renombrar el archivo
    Rename-Item -Path $archivo.FullName -NewName ($nuevoNombre + '.md')

    # Incrementar el contador para la próxima numeración
    $contador++
}

Write-Host "Archivos Markdown renombrados exitosamente."
