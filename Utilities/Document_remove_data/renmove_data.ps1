# Obtener la ruta actual
$CurrentPath = Get-Location

# Filtrar todos los archivos .docx en la carpeta actual
$WordFiles = Get-ChildItem -Path $CurrentPath -Filter *.docx

# Crear objeto de Word
$Word = New-Object -ComObject Word.Application
$Word.Visible = $false

foreach ($file in $WordFiles) {
    Write-Host "Procesando $($file.Name)..."

    # Abrir documento
    $Doc = $Word.Documents.Open($file.FullName)

    # ===============================
    # 1. Eliminar propiedades personales
    # ===============================
    try { $Doc.RemoveDocumentInformation([Microsoft.Office.Interop.Word.WdRemoveDocInfoType]::wdRDIDocumentProperties) } catch {}

    # ===============================
    # 2. Limpiar autor, empresa y computador
    # ===============================
    foreach ($propName in @("Author","Company","Last Author","Manager","Template")) {
        try {
            $prop = $Doc.BuiltInDocumentProperties.Item($propName)
            if ($prop -ne $null) { $prop.Value = "" }
        } catch {}
    }

    # ===============================
    # 3. Limpiar nombres de revisiones y seguimiento de cambios
    # ===============================
    try {
        # Desactivar seguimiento de cambios
        $Doc.TrackRevisions = $false
        # Aceptar todas las revisiones
        $Doc.AcceptAllRevisions()
        # Limpiar comentarios
        foreach ($comment in @($Doc.Comments)) {
            $comment.Delete()
        }
    } catch {}

    # ===============================
    # 5. Guardar y cerrar documento
    # ===============================
    $Doc.Save()
    $Doc.Close()
}

# Cerrar Word
$Word.Quit()

Write-Host "Todos los documentos .docx han sido despersonalizados en $CurrentPath"
