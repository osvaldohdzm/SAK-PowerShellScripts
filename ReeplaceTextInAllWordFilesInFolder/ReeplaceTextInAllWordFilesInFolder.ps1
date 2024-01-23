$Word = New-Object -ComObject Word.Application
$Word.Visible = $true

# Search for all Word document types (.doc, .docx, .dot)
$WordFiles = Get-ChildItem -Recurse | Where-Object { $_.Name -like "*.do[c,t]*" }

# Define the replacement hash
$ReplacementHash = @{
    "solicitud del Ingeniero Omar Mata" = "solicitud del administrador del contrato"
    "actividades de análisis estático sobre aplicaciones" = "actividades de análisis de vulnerabilidades sobre infraestructura tecnológica"
    "análisis estático sobre aplicaciones correspondientes" = "análisis de vulnerabilidades sobre la infraestructura correspondiente"
    "el Ingeniero Omar Mata solicitó" = "el administrador del contrato solicitó"
}

foreach ($WordFile in $WordFiles) {
    try {
        # Open the document
        $Document = $Word.Documents.Open($WordFile.FullName)

        Write-Host "Processing document: $($WordFile.FullName)"

        # Set up find/replace parameters for each replacement
        foreach ($FindText in $ReplacementHash.Keys) {
            Write-Host "   FindText: $FindText"

            $ReplaceText = $ReplacementHash[$FindText]

            # Set the encoding for Find and Replace strings
            $FindTextUtf8 = $([System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($FindText)))
            $ReplaceTextUtf8 = $([System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($ReplaceText)))

            $Word.Selection.Find.ClearFormatting()
            $Word.Selection.Find.Replacement.ClearFormatting()

            $Word.Selection.Find.Text = $FindTextUtf8
            $Word.Selection.Find.Replacement.Text = $ReplaceTextUtf8
            $Word.Selection.Find.Forward = $true
            $Word.Selection.Find.Wrap = 0 # wdFindContinue
            $Word.Selection.Find.Format = $false
            $Word.Selection.Find.MatchCase = $false
            $Word.Selection.Find.MatchWholeWord = $false
            $Word.Selection.Find.MatchWildcards = $false
            $Word.Selection.Find.MatchSoundsLike = $false
            $Word.Selection.Find.MatchAllWordForms = $false

            # Execute the find and replace for all occurrences
            $replacements = 0
            while ($Word.Selection.Find.Execute()) {
                $replacements++
                Write-Host "   Successful replacement of '$($FindText)' with '$($ReplaceText)' in document $($WordFile.FullName): $($Word.Selection.Text)"
                $Word.Selection.Text = $ReplaceTextUtf8
            }

            # Display result messages
            if ($replacements -gt 0) {
                Write-Host "   Successful replacements in $($WordFile.FullName)"
            } else {
                Write-Host "   No matches found for '$($FindText)' in $($WordFile.FullName)"
            }

            # Move cursor to the beginning of the document
        $Word.Selection.HomeKey(6)

        }       

        Write-Host "   Presiona Enter para continuar..."
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').Key

        # Save and close the document
        $Document.Save()
        $Document.Close()
    } catch {
        Write-Host "   Error: No se pudo abrir el archivo $($WordFile.FullName). Posiblemente está en uso por otro proceso."
    }
}

$Word.Quit()
