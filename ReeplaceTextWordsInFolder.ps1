$Word = New-Object -ComObject Word.Application

# Search for all Word document types (.doc, .docx, .doct, etc.)
$WordFiles = Get-ChildItem -Recurse | Where-Object { $_.Name -like "*.do[c,t]*" }

# Define the replacement hash
$ReplacementHash = @{
    "Ingeniero Omar Mata" = "administrador del contrato"
}

$MatchCase = $false
$MatchWholeWorld = $true
$MatchWildcards = $false
$MatchSoundsLike = $false
$MatchAllWordForms = $false
$Forward = $false
$Wrap = 1
$Format = $false
$Replace = 2

foreach ($WordFile in $WordFiles) {
    # Open the document
    $Document = $Word.Documents.Open($WordFile.FullName)
    
    # Find and replace the text using the replacement hash
    $ReplacementsPerformed = 0
    foreach ($FindText in $ReplacementHash.Keys) {
        $ReplaceText = $ReplacementHash[$FindText]
        $result = $Document.Content.Find.Execute($FindText, $MatchCase, $MatchWholeWorld, $MatchWildcards, $MatchSoundsLike, $MatchAllWordForms, $Forward, $Wrap, $Format, $ReplaceText, $Replace)
        if ($result -eq $true) {
            $ReplacementsPerformed++
        }
    }

    # Save and close the document
    $Document.Close(-1) # The -1 corresponds to https://docs.microsoft.com/en-us/office/vba/api/word.wdsaveoptions

    # Display result messages
    if ($ReplacementsPerformed -gt 0) {
        Write-Host "Reemplazos exitosos ($ReplacementsPerformed) en $WordFile"
    } else {
        Write-Host "No se encontraron coincidencias en $WordFile"
    }
}

$Word.Quit()
