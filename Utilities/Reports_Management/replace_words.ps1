<#
.SYNOPSIS
    Busca y reemplaza una frase específica en todos los documentos de Word (.docx)
    en el directorio actual y todos sus subdirectorios, manteniendo el formato.

.DESCRIPTION
    Este script requiere que Microsoft Word esté instalado en el equipo.
    Automatiza el proceso de abrir cada documento de Word, realizar una operación
    de "Buscar y Reemplazar" y luego guardar y cerrar el documento.

.NOTES
    Autor: Asistente de IA
    Versión: 1.1
    Requisito: Microsoft Word debe estar instalado.
    IMPORTANTE: ¡Realice una copia de seguridad de sus archivos antes de ejecutar este script!
#>

# --- CONFIGURACIÓN ---

# La frase exacta que quieres encontrar.
# Nota: Se incluyó el espacio al final, como en tu solicitud "las pruebas de intrusión ".
$textoBuscar = "pruebas de penetración"

# El nuevo texto que lo reemplazará.
$textoReemplazar = "pruebas de seguridad y analisis de vulnerabilidades"

# --- Fin de la Configuración (No es necesario modificar más) ---


try {
    # Crear una instancia invisible de la aplicación Word
    Write-Host "Iniciando la aplicación Microsoft Word en segundo plano..."
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false # No mostrar la ventana de Word

    # Obtener la ruta de la carpeta donde se está ejecutando el script
    $directorioInicial = Get-Location
    Write-Host "Buscando archivos .docx en '$($directorioInicial.Path)' y subcarpetas..." -ForegroundColor Cyan

    # Buscar todos los archivos .docx de forma recursiva
    $archivosWord = Get-ChildItem -Path $directorioInicial -Recurse -Filter "*.docx"

    if ($archivosWord.Count -eq 0) {
        Write-Host "No se encontraron archivos .docx en esta ubicación." -ForegroundColor Yellow
    } else {
        Write-Host "Se encontraron $($archivosWord.Count) archivos. Iniciando el proceso de reemplazo..." -ForegroundColor Green
        Write-Host "------------------------------------------------------------------"

        # Definir constantes de Word para la operación de reemplazo
        $wdReplaceAll = 2 # Constante para reemplazar todas las ocurrencias
        $wdSaveChanges = -1 # Constante para guardar los cambios al cerrar

        # Procesar cada archivo encontrado
        foreach ($archivo in $archivosWord) {
            try {
                Write-Host "Procesando: $($archivo.FullName)"
                
                # Abrir el documento
                $documento = $word.Documents.Open($archivo.FullName)
                
                # Obtener el objeto de búsqueda (Find) del contenido del documento
                $findObject = $documento.Content.Find
                
                # Limpiar cualquier formato de búsqueda previo
                $findObject.ClearFormatting()
                $findObject.Replacement.ClearFormatting()
                
                # Ejecutar la operación de "Buscar y Reemplazar"
                # Los parámetros son: FindText, MatchCase, MatchWholeWord, ..., ReplaceWith, Replace
                $findObject.Execute($textoBuscar, $false, $false, $false, $false, $false, $true, 1, $false, $textoReemplazar, $wdReplaceAll) | Out-Null
                
                # Guardar los cambios y cerrar el documento
                $documento.Close($wdSaveChanges)
            }
            catch {
                Write-Warning "ERROR al procesar el archivo '$($archivo.FullName)': $_"
                # Intentar cerrar el documento sin guardar si hubo un error
                if ($documento) {
                    $documento.Close(0) # 0 = wdDoNotSaveChanges
                }
            }
        }
        Write-Host "------------------------------------------------------------------"
        Write-Host "Proceso completado con éxito." -ForegroundColor Green
    }
}
catch {
    Write-Error "Ocurrió un error general: $_"
    Write-Error "Asegúrese de que Microsoft Word esté instalado correctamente."
}
finally {
    # Asegurarse de que la aplicación Word se cierre correctamente, incluso si hay errores
    if ($word) {
        $word.Quit()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
        Remove-Variable word -ErrorAction SilentlyContinue
        Write-Host "La aplicación Word se ha cerrado."
    }
}