<#
.SYNOPSIS
    Convierte MD a PDF usando plantilla DOCX de referencia.
    CORRECCIÓN: Casting explícito de rutas para evitar errores de tipo psobject en SaveAs.
#>

$SourceDir = "C:\Users\osvaldohm\Desktop\Base\03 Knowledge"
$TargetDir = "C:\Users\osvaldohm\Desktop\Base\09 Sistema Documental"
$TemplatePath = "C:\Users\osvaldohm\Desktop\Base\10 Plantillas\Plantilla Documental.docx"
$PandocExe = "$env:LOCALAPPDATA\Pandoc\pandoc.exe"

# Códigos de Word
$wdFormatPDF = 17    
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

# --- 3. INICIAR WORD ---
try {
    $WordApp = New-Object -ComObject Word.Application
    $WordApp.Visible = $false
    $WordApp.DisplayAlerts = $wdAlertsNone
}
catch {
    Write-Error "No se pudo iniciar Word."
    exit
}

# --- 4. PROCESAR ---
try {
    $MarkDownFiles = Get-ChildItem -Path $SourceDir -Filter "*.md" -Recurse

    foreach ($File in $MarkDownFiles) {
        $ContentHead = Get-Content -Path $File.FullName -TotalCount 15 -ErrorAction SilentlyContinue
        if ($ContentHead -match "excalidraw-plugin: parsed" -or $File.Name -like "*.excalidraw.md") { continue }

        $RelativePath = $File.DirectoryName.Substring($SourceDir.Length).TrimStart("\")
        $CurrentTargetDir = Join-Path -Path $TargetDir -ChildPath $RelativePath
        if (-not (Test-Path $CurrentTargetDir)) { New-Item -ItemType Directory -Path $CurrentTargetDir -Force | Out-Null }

        # Forzamos las rutas a ser strings puras de .NET
        $DocxOutput = [string](Join-Path -Path $CurrentTargetDir -ChildPath ($File.BaseName + ".docx"))
        $PdfOutput = [string](Join-Path -Path $CurrentTargetDir -ChildPath ($File.BaseName + ".pdf"))

        Write-Host "Procesando: $($File.BaseName)" -ForegroundColor Cyan

        # A. PANDOC
        $PandocArgs = "`"$($File.FullName)`" -o `"$DocxOutput`" --reference-doc=`"$TemplatePath`" --resource-path=`"$($File.DirectoryName)`""
        $Proc = Start-Process -FilePath $PandocExe -ArgumentList $PandocArgs -Wait -PassThru -NoNewWindow

        if ($Proc.ExitCode -eq 0 -and (Test-Path $DocxOutput)) {
            Start-Sleep -Milliseconds 300 
            
            $Doc = $null 
            try {
                # Abrir DOCX
                $Doc = $WordApp.Documents.Open($DocxOutput)
                if ($Doc) {
                    # LLAMADA CORREGIDA: Usamos SaveAs2 si está disponible, o SaveAs con parámetros directos
                    # En PowerShell moderno, pasar la ruta como string pura suele ser suficiente
                    $Doc.SaveAs([string]$PdfOutput, [int]$wdFormatPDF)
                    $Doc.Close([ref]$false)
                    Write-Host "  [OK] PDF generado con éxito." -ForegroundColor Green
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
                # Intentar borrar el DOCX intermedio
                Remove-Item -Path $DocxOutput -Force -ErrorAction SilentlyContinue
            }
        }
    }
}
finally {
    if ($WordApp) { 
        $WordApp.Quit()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($WordApp) | Out-Null 
    }
    Stop-Process -Name "winword" -Force -ErrorAction SilentlyContinue
    Write-Host "`nProceso finalizado. Solo PDFs y SVGs en el destino." -ForegroundColor Magenta
}