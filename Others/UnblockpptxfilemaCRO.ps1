Install-Package Microsoft.Office.Interop.PowerPoint -Scope CurrentUser

$pptFilePath = "C:\path\to\your\file.pptm"
$outputFolder = "C:\path\to\output\folder"

# Load the PowerPoint COM object
$pptApp = New-Object -ComObject PowerPoint.Application
$pptApp.Visible = [Microsoft.Office.Core.MsoTriState]::msoTrue

# Open the presentation
$presentation = $pptApp.Presentations.Open($pptFilePath)

# Ensure the output folder exists
if (-not (Test-Path $outputFolder)) {
    New-Item -Path $outputFolder -ItemType Directory
}

# Loop through each slide and save as PNG
for ($i = 1; $i -le $presentation.Slides.Count; $i++) {
    $slide = $presentation.Slides.Item($i)
    $outputPath = Join-Path $outputFolder ("Slide_$i.png")
    $slide.Export($outputPath, "PNG")
}

# Close and quit PowerPoint
$presentation.Close()
$pptApp.Quit()
