function Copy-FolderStructure {
  param(
    [string]$SourcePath,
    [string]$DestinationPath
  )

  # Get all the subfolders in the source folder
  $SubFolders = Get-ChildItem -Path $SourcePath -Directory

  # Loop through each subfolder and copy its structure to the destination folder
  foreach ($SubFolder in $SubFolders) {
    # Create a new destination path for the subfolder
    $NewDestinationPath = Join-Path -Path $DestinationPath -ChildPath $SubFolder.Name
    # Copy the subfolder structure from source to destination
    Copy-Item -Path $SubFolder.FullName -Destination $NewDestinationPath -Recurse -Container
    # Get all the files in the destination subfolder
    $Files = Get-ChildItem -Path $NewDestinationPath -Recurse -File

    # Loop through each file and create an empty file with the same name and size
    foreach ($File in $Files) {
      fsutil file createnew $File.FullName $File.Length
    }
  }
}

$SourcePath = $args[0]
$folderPath = (Get-Item -Path $SourcePath).Parent.FullName

# Crea un bucle para crear 10 carpetas con nombres aleatorios
for ($j = 0; $j -lt 3; $j++) {
    # Genera un nombre aleatorio usando la función definida
    $randName = Get-RandomName

    # Crea una carpeta con el nombre aleatorio en la ubicación deseada (por ejemplo, C:\Temp)
    New-Item -Path "$folderPath\$randName" -ItemType Directory

Copy-FolderStructure $SourcePath "$folderPath\$randName"

}



