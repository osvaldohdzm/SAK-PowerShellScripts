<#
.SYNOPSIS
    Convierte MD a PDF usando plantilla DOCX de referencia, inyecta TOC, estilos de código
    y procesa metadatos personalizados (Versión, Código) vía Lua Filter.
    AUTOR: Osvaldo Hernández
#>

# --- CONFIGURACIÓN DE RUTAS ---
$SourceDir    = "C:\Users\osvaldohm\Desktop\Base\03 Knowledge"
$TargetDir    = "C:\Users\osvaldohm\Desktop\Base\09 Sistema Documental"
$TemplatePath = "C:\Users\osvaldohm\Desktop\Base\10 Plantillas\Plantilla Documental.docx"
# Ruta exacta donde guardaste el archivo Lua
$LuaFilterPath = "C:\Users\osvaldohm\Desktop\Base\10 Plantillas\metadata.lua"
$PandocExe    = "$env:LOCALAPPDATA\Pandoc\pandoc.exe"

# Códigos de Word
$wdFormatPDF  = 17      
$wdAlertsNone = 0      

# --- 1. LIMPIEZA ---
Write-Host "Limpiando procesos y preparando destino..." -ForegroundColor DarkGray
Stop-Process -Name "winword" -Force -ErrorAction SilentlyContinue

if (Test-Path $TargetDir) {
    Get-ChildItem -Path $TargetDir -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}
New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null

# --- 2. COPIAR SVGs ---
Write-Host "Copiando archivos SVG..." -ForegroundColor Yellow
Get-ChildItem -Path $SourceDir -Filter "*.svg" -Recurse | ForEach-Object {
    $RelativePath = $_.DirectoryName.Substring($SourceDir.Length).TrimStart("\")
    $DestSvgDir = Join-Path -Path $TargetDir -ChildPath $RelativePath
    if (-not (Test-Path $DestSvgDir)) { New-Item -ItemType Directory -Path $DestSvgDir -Force | Out-Null }
    Copy-Item -Path $_.FullName -Destination $DestSvgDir -Force
}

# --- 3. INICIAR WORD (En segundo plano) ---
try {
    $WordApp = New-Object -ComObject Word.Application
    $WordApp.Visible = $false
    $WordApp.DisplayAlerts = $wdAlertsNone
}
catch {
    Write-Error "No se pudo iniciar Word. Verifica la instalación de Office."
    exit
}

# --- 4. PROCESAMIENTO ---
try {
    $MarkDownFiles = Get-ChildItem -Path $SourceDir -Filter "*.md" -Recurse

    foreach ($File in $MarkDownFiles) {
        # Ignorar archivos de excalidraw o metadatos técnicos
        $ContentHead = Get-Content -Path $File.FullName -TotalCount 15 -ErrorAction SilentlyContinue
        if ($ContentHead -match "excalidraw-plugin: parsed" -or $File.Name -like "*.excalidraw.md") { continue }

        # Estructura de carpetas espejo
        $RelativePath = $File.DirectoryName.Substring($SourceDir.Length).TrimStart("\")
        $CurrentTargetDir = Join-Path -Path $TargetDir -ChildPath $RelativePath
        if (-not (Test-Path $CurrentTargetDir)) { New-Item -ItemType Directory -Path $CurrentTargetDir -Force | Out-Null }

        # Rutas de salida
        $DocxOutput = [string](Join-Path -Path $CurrentTargetDir -ChildPath ($File.BaseName + ".docx"))
        $PdfOutput = [string](Join-Path -Path $CurrentTargetDir -ChildPath ($File.BaseName + ".pdf"))

        Write-Host "Procesando: $($File.BaseName)" -ForegroundColor Cyan

        # --- A. PANDOC ---
        # NUEVO: Se agregó --lua-filter para procesar los metadatos personalizados
        $PandocArgs = "`"$($File.FullName)`" -o `"$DocxOutput`" --reference-doc=`"$TemplatePath`" --lua-filter=`"$LuaFilterPath`" --resource-path=`"$($File.DirectoryName)`" --toc --toc-depth=2 --syntax-highlighting=breezedark"
        
        $Proc = Start-Process -FilePath $PandocExe -ArgumentList $PandocArgs -Wait -PassThru -NoNewWindow

        if ($Proc.ExitCode -eq 0 -and (Test-Path $DocxOutput)) {
            Start-Sleep -Milliseconds 300 
            
            $Doc = $null 
            try {
                # --- B. WORD TO PDF ---
                $Doc = $WordApp.Documents.Open($DocxOutput)
                
                if ($Doc) {
                    # Actualizar campos (Importante para que STYLEREF capture los nuevos datos del Lua)
                    $Doc.Fields.Update() 
                    
                    # Guardar como PDF
                    $Doc.SaveAs([string]$PdfOutput, [int]$wdFormatPDF)
                    $Doc.Close([ref]$false)
                    Write-Host "  [OK] PDF generado con metadatos y estilos." -ForegroundColor Green
                }
            }
            catch {
                Write-Host "  [!] ERROR EN WORD: $($_.Exception.Message)" -ForegroundColor Red
            }
            finally {
                if ($Doc) { 
                    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Doc) | Out-Null 
                    $Doc = $null
                }
                # Borrar DOCX intermedio para dejar limpia la carpeta
                Remove-Item -Path $DocxOutput -Force -ErrorAction SilentlyContinue
            }
        } else {
            Write-Host "  [!] Error en Pandoc. Verifica el Markdown o la ruta del Lua." -ForegroundColor Magenta
        }
    }
}
finally {
    if ($WordApp) { 
        $WordApp.Quit()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($WordApp) | Out-Null 
    }
    Stop-Process -Name "winword" -Force -ErrorAction SilentlyContinue
    Write-Host "`nProceso finalizado." -ForegroundColor Cyan
}