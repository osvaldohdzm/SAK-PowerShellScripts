<#
.SYNOPSIS
    Convierte todos los documentos de Word (.docx, .doc) a PDF de alta calidad.

.DESCRIPTION
    Este script busca recursivamente archivos de Word en el directorio actual y sus
    subdirectorios. Luego, utiliza la aplicación Microsoft Word para guardar una
    copia de cada documento como un archivo PDF en la misma carpeta que el original.
    Está optimizado para generar PDFs de alta calidad (calidad de impresión).

.NOTES
    Autor: Asistente de IA
    Versión: 1.0
    Requisito: Microsoft Word debe estar instalado en el equipo.
    Comportamiento: Por defecto, si un PDF con el mismo nombre ya existe, el script
                 omitirá la conversión de ese archivo para ahorrar tiempo.
#>

# --- CONFIGURACIÓN ---

# Cambia a $true si quieres que el script sobrescriba los PDFs que ya existen.
# $false = Omitir si ya existe (más seguro y rápido en ejecuciones repetidas).
# $true  = Sobrescribir siempre el PDF existente.
$sobrescribirExistentes = $false

# ---------------------------------------------


# --- Inicio del Script (No es necesario modificar a partir de aquí) ---

try {
    # Crear una instancia invisible de la aplicación Word
    Write-Host "Iniciando la aplicación Microsoft Word en segundo plano..."
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false

    # Definir constantes de Word para la exportación a PDF
    $wdFormatPDF = 17              # Formato de archivo para PDF
    $wdExportOptimizeForPrint = 0  # Optimizar para calidad de impresión (alta calidad)
    $wdDoNotSaveChanges = 0        # Constante para cerrar sin guardar cambios en el Word original

    # Obtener la ruta de la carpeta donde se está ejecutando el script
    $directorioInicial = Get-Location
    Write-Host "Buscando archivos de Word en '$($directorioInicial.Path)' y subcarpetas..." -ForegroundColor Cyan

    # Buscar todos los archivos .docx y .doc de forma recursiva
    $archivosWord = Get-ChildItem -Path $directorioInicial -Recurse -Include "*.docx", "*.doc"

    if ($archivosWord.Count -eq 0) {
        Write-Host "No se encontraron archivos de Word en esta ubicación." -ForegroundColor Yellow
    } else {
        Write-Host "Se encontraron $($archivosWord.Count) archivos. Iniciando la conversión a PDF..." -ForegroundColor Green
        Write-Host "------------------------------------------------------------------"

        # Procesar cada archivo encontrado
        foreach ($archivo in $archivosWord) {
            # Construir la ruta completa para el archivo PDF de salida
            $pdfPath = [System.IO.Path]::ChangeExtension($archivo.FullName, ".pdf")

            # Comprobar si el PDF ya existe y si se debe sobrescribir
            if ((Test-Path $pdfPath) -and (-not $sobrescribirExistentes)) {
                Write-Host "Omitiendo: $($archivo.Name) (el PDF ya existe)" -ForegroundColor Gray
                continue # Pasa al siguiente archivo en el bucle
            }

            try {
                Write-Host "Convirtiendo: $($archivo.Name) -> $($pdfPath.Split('\')[-1])"
                
                # Abrir el documento de Word en modo de solo lectura para mayor seguridad
                $documento = $word.Documents.Open($archivo.FullName, $false, $true) # Open(FileName, ConfirmConversions, ReadOnly)
                
                # Exportar el documento a PDF con alta calidad
                # ExportAsFixedFormat(OutputFileName, ExportFormat, OpenAfterExport, OptimizeFor)
                $documento.ExportAsFixedFormat($pdfPath, $wdFormatPDF, $false, $wdExportOptimizeForPrint)
                
                # Cerrar el documento original sin guardar ningún cambio
                $documento.Close($wdDoNotSaveChanges)
            }
            catch {
                Write-Warning "ERROR al convertir el archivo '$($archivo.FullName)': $_"
                # Intentar cerrar el documento si quedó abierto tras un error
                if ($documento) {
                    $documento.Close($wdDoNotSaveChanges)
                }
            }
        }
        Write-Host "------------------------------------------------------------------"
        Write-Host "Proceso de conversión completado." -ForegroundColor Green
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