<#
.SYNOPSIS
    MASTER SCRIPT: Markdown -> DOCX (Temp) -> PDF -> PUBLISH
    VERSIÓN: 7.0 (Clean Start + Hidden Folder Filter)
    REGLAS:
      1. NO generar DOCX en destino (Solo PDF).
      2. NUNCA leer carpetas que inicien con "." (ej. .obsidian).
      3. SIEMPRE limpiar carpeta destino antes de empezar.
#>

# --- 0. CONFIGURACIÓN DE ENTORNO ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

# --- 1. RUTAS (AJUSTAR AQUÍ) ---
$SourceDir    = "C:\Users\osvaldohm\Desktop\Base\03 Knowledge Center"
$TargetDir    = "C:\Users\osvaldohm\Desktop\Base\09 Sistema Documental"
$TemplatePath = "C:\Users\osvaldohm\Desktop\Base\10 Plantillas\Plantilla Documental.docx"

# Constantes de Word
$wdFormatPDF        = 17      
$wdAlertsNone       = 0
$wdDoNotSaveChanges = 0

# --- 2. FUNCIONES DE UTILIDAD ---

function Log-Activity {
    param(
        [string]$Message,
        [string]$Type = "INFO" 
    )
    $Timestamp = Get-Date -Format "HH:mm:ss"
    switch ($Type) {
        "INFO"    { Write-Host "[$Timestamp] [INFO]    $Message" -ForegroundColor Gray }
        "STEP"    { Write-Host "[$Timestamp] [PANDO]   $Message" -ForegroundColor Cyan }
        "WORD"    { Write-Host "[$Timestamp] [WORD]    $Message" -ForegroundColor Blue }
        "SUCCESS" { Write-Host "[$Timestamp] [OK]      $Message" -ForegroundColor Green }
        "WARN"    { Write-Host "[$Timestamp] [WARN]    $Message" -ForegroundColor Yellow }
        "ERROR"   { Write-Host "[$Timestamp] [ERROR]   $Message" -ForegroundColor Red }
        "CLEAN"   { Write-Host "[$Timestamp] [CLEAN]   $Message" -ForegroundColor Magenta }
    }
}

function Invoke-DocReplace {
    param($Document, [string]$FindText, [string]$ReplaceText)
    if ($ReplaceText.Length -gt 250) { $ReplaceText = $ReplaceText.Substring(0, 250) }

    foreach ($StoryRange in $Document.StoryRanges) {
        $Range = $StoryRange
        do {
            try {
                $Find = $Range.Find
                $Find.Text = $FindText
                $Find.Replacement.Text = $ReplaceText
                $Find.Execute($FindText, $false, $false, $false, $false, $false, $true, 1, $false, $ReplaceText, 2) | Out-Null
            } catch {}
            $Range = $Range.NextStoryRange
        } while ($Range -ne $null)
    }
}

# --- 3. INICIO Y LIMPIEZA AGRESIVA ---
Write-Host "`n========================================================" -ForegroundColor Magenta
Write-Host "   SISTEMA DE DOCUMENTACIÓN - V7.0" -ForegroundColor Magenta
Write-Host "========================================================`n" -ForegroundColor Magenta

if (!(Test-Path $SourceDir)) { Log-Activity "No existe origen: $SourceDir" "ERROR"; exit }
if (!(Test-Path $TemplatePath)) { Log-Activity "No existe plantilla: $TemplatePath" "ERROR"; exit }

# REGLA 2: LIMPIEZA TOTAL DEL DESTINO
if (Test-Path $TargetDir) {
    Log-Activity "Vaciando carpeta destino (Clean Start)..." "CLEAN"
    # Borra todo el contenido dentro de TargetDir, pero deja la carpeta raíz
    Get-ChildItem -Path $TargetDir -Recurse | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
} else {
    New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null
}

# Limpieza de procesos Word
Get-Process winword -ErrorAction SilentlyContinue | Stop-Process -Force

# --- 4. STAGING AREA (TEMP) ---
$SessionID = -join ((65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object {[char]$_})
$StagingDir = Join-Path $env:TEMP "DocGen_$SessionID"
New-Item -Path $StagingDir -ItemType Directory -Force | Out-Null
Log-Activity "Staging temporal: $StagingDir" "INFO"

# Detectar Pandoc
$PandocExe = Get-Command pandoc -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (!$PandocExe) { Log-Activity "Pandoc no instalado." "ERROR"; exit }

# --- 5. BUCLE PRINCIPAL ---
$WordApp = $null
$TotalErrors = 0
$TotalProcessed = 0

try {
    Log-Activity "Iniciando motor Word..." "WORD"
    $WordApp = New-Object -ComObject Word.Application
    $WordApp.Visible = $false
    $WordApp.DisplayAlerts = $wdAlertsNone

    $Files = Get-ChildItem -Path $SourceDir -Filter "*.md" -Recurse

    foreach ($File in $Files) {
        
        # --- REGLA 1: FILTROS DE CARPETA (.obsidian, etc) ---
        # Si la ruta contiene "\.", es una carpeta oculta o de sistema
        if ($File.FullName -match "\\\.") {
            # No lo logueamos como WARN para no ensuciar la consola, solo lo ignoramos silenciosamente o como debug
            # Log-Activity "Ignorando archivo oculto/sistema: $($File.Name)" "INFO"
            continue
        }

        # Filtros estándar (Drafts)
        if ($File.Name -match "^(DRAFT|FIX|IGNORE)") { continue }
        
        # Filtro Excalidraw
        if ($File.Name -like "*.excalidraw.md") { continue }

        Write-Host "--------------------------------------------------------" -ForegroundColor DarkGray
        $TotalProcessed++
        Log-Activity "Procesando: $($File.BaseName)" "INFO"

        # --- A. METADATOS ---
        $HeadContent = (Get-Content $File.FullName -TotalCount 50 -Encoding UTF8 -ErrorAction SilentlyContinue) -join "`n"
        $Metadata = @{
            "{{TITLE}}" = $File.BaseName.ToUpper(); "{{CODIGO}}" = "SIN-CODIGO"; 
            "{{VERSION}}" = "1.0"; "{{DATE}}" = (Get-Date -Format "yyyy-MM-dd")
        }
        if ($HeadContent -match '(?im)^title:\s*["'']?([^"''\r\n]+)["'']?') { $Metadata["{{TITLE}}"] = $Matches[1].Trim() }
        if ($HeadContent -match '(?im)^codigo:\s*["'']?([^"''\r\n]+)["'']?') { $Metadata["{{CODIGO}}"] = $Matches[1].Trim() }
        
        # --- B. RUTAS ---
        $RelPath = $File.DirectoryName.Substring($SourceDir.Length).TrimStart("\")
        $FinalDestDir = Join-Path $TargetDir $RelPath
        if (!(Test-Path $FinalDestDir)) { New-Item -Type Directory -Path $FinalDestDir -Force | Out-Null }

        $TempDocx = Join-Path $StagingDir ($File.BaseName + ".docx")
        $TempPdf  = Join-Path $StagingDir ($File.BaseName + ".pdf")
        $FinalPdfPath = Join-Path $FinalDestDir ($File.BaseName + ".pdf")

        # --- C. PANDOC (Markdown -> DOCX en Temp) ---
        $PandocArgs = "`"$($File.FullName)`" -o `"$TempDocx`" --reference-doc=`"$TemplatePath`" --resource-path=`"$($File.DirectoryName)`" --toc --toc-depth=2 --metadata toc-title=`"Índice`" -V lang=es-MX"
        $Proc = Start-Process $PandocExe -ArgumentList $PandocArgs -Wait -PassThru -NoNewWindow
        
        if ($Proc.ExitCode -ne 0) {
            Log-Activity "Error Pandoc." "ERROR"; $TotalErrors++; continue
        }

        # --- D. WORD (DOCX -> PDF en Temp) ---
        $Doc = $null
        try {
            $Doc = $WordApp.Documents.Open($TempDocx)
            foreach ($Key in $Metadata.Keys) { Invoke-DocReplace -Document $Doc -FindText $Key -ReplaceText $Metadata[$Key] }
            try { $Doc.Fields.Update() | Out-Null } catch {}
            
            $Doc.SaveAs([string]$TempPdf, [int]$wdFormatPDF)
            $Doc.Close($wdDoNotSaveChanges)
            [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Doc) | Out-Null
            $Doc = $null
        } catch {
            Log-Activity "Error Word: $($_.Exception.Message)" "ERROR"
            if ($Doc) { $Doc.Close($wdDoNotSaveChanges); [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Doc) | Out-Null }
            $TotalErrors++; continue
        }

        # --- E. MOVER PDF FINAL ---
        if (Test-Path $TempPdf) {
            Move-Item -Path $TempPdf -Destination $FinalPdfPath -Force
            Log-Activity "Publicado OK" "SUCCESS"
        }
    }

} catch {
    Log-Activity "FATAL: $($_.Exception.Message)" "ERROR"
} finally {
    # --- 6. LIMPIEZA FINAL ---
    if ($WordApp) { $WordApp.Quit($wdDoNotSaveChanges); [System.Runtime.InteropServices.Marshal]::ReleaseComObject($WordApp) | Out-Null }
    if (Test-Path $StagingDir) { Remove-Item $StagingDir -Recurse -Force -ErrorAction SilentlyContinue }
    [GC]::Collect()
    
    Write-Host "`nRESUMEN:"
    Write-Host " Archivos Procesados: $TotalProcessed" -ForegroundColor Cyan
    Write-Host " Errores:             $TotalErrors" -ForegroundColor ($TotalErrors -gt 0 ? "Red" : "Gray")
    Write-Host " Destino Limpio:      SÍ" -ForegroundColor Green
}