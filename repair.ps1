# Obtiene la ruta del directorio actual
$path = Get-Location

# Obtiene todas las carpetas en el directorio actual
$folders = Get-ChildItem -Path $path -Directory | Sort-Object Name

# Inicializa el alfabeto
$alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# Itera sobre las carpetas y les asigna letras en secuencia
$index = 0
foreach ($folder in $folders) {
    # Asigna la letra correspondiente
    $newLetter = $alphabet[$index]
    $newFolderName = $folder.Name -replace "^[A-Z]", $newLetter
    
    # Renombra la carpeta
    Rename-Item -Path $folder.FullName -NewName $newFolderName
    $index++

    # Si ya se han asignado todas las letras, se detiene
    if ($index -eq $alphabet.Length) {
        break
    }
}
