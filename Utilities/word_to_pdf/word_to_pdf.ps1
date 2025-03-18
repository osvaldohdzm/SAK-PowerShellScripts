# Script: Export Word documents to PDF
# Author: OpenAI Assistant
# Purpose: Convert all Word documents in the same folder as the script to high-quality PDFs.

# Load Word COM object
$wordApp = New-Object -ComObject Word.Application
$wordApp.Visible = $false

# Get the folder where the script is located
$scriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Path

# Get all Word documents (*.doc, *.docx) in the folder
$wordFiles = Get-ChildItem -Path $scriptFolder -Include *.doc, *.docx -Recurse

if ($wordFiles.Count -eq 0) {
    Write-Output "No Word documents found in the folder."
    exit
}

# Process each Word document
foreach ($file in $wordFiles) {
    try {
        # Open the Word document
        $doc = $wordApp.Documents.Open($file.FullName)

        # Define the output PDF file path
        $pdfPath = [System.IO.Path]::ChangeExtension($file.FullName, "pdf")

        # Export the document to PDF with high quality
        $doc.SaveAs([ref]$pdfPath, [ref]17) # 17 is the format for PDF

        Write-Output "Exported to PDF: $pdfPath"
    } catch {
        Write-Output "Error processing file: $($file.FullName). Details: $_"
    } finally {
        # Close the document
        if ($doc -ne $null) {
            $doc.Close($false)
        }
    }
}

# Quit Word application
$wordApp.Quit()

# Release COM object
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($wordApp) | Out-Null
[GC]::Collect()
[GC]::WaitForPendingFinalizers()

Write-Output "All Word documents have been exported to PDF."
