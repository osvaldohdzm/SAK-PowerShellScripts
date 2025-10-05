# Obtener la ruta de la carpeta donde se encuentra el script
$scriptPath = $PSScriptRoot

# Función para procesar directorios (carpetas)
function Process-Directories {
    param(
        [string]$path
    )

    # Obtener todos los directorios en la carpeta
    $directories = Get-ChildItem -Path $path -Directory

    # Recorrer cada directorio
    foreach ($dir in $directories) {
        # Obtener la ruta completa del directorio
        $fullPath = $dir.FullName
        
        # Separar la ruta y el nombre del directorio
        $directory = Split-Path $fullPath -Parent
        $name = Split-Path $fullPath -Leaf
        
        # Convertir el nombre del directorio a minúsculas
        $lowerCaseName = $name.ToLowerInvariant()
        
        # Verificar si el nombre actual es diferente al nombre en minúsculas
        if ($name -cne $lowerCaseName) {
            # Combinar la ruta original con el nuevo nombre en minúsculas
            $newPath = Join-Path $directory $lowerCaseName
            
            # Renombrar el directorio con el nuevo nombre en minúsculas
            Rename-Item -Path $fullPath -NewName $newPath
            Write-Host "Renombrado '$fullPath' a '$newPath'"
        } else {
            Write-Host "El directorio '$fullPath' ya está en minúsculas."
        }
    }
}

# Función para procesar archivos
function Process-Files {
    param(
        [string]$path
    )

    # Obtener todos los archivos en la carpeta
    $files = Get-ChildItem -Path $path -File

    # Recorrer cada archivo
    foreach ($file in $files) {
        # Obtener la ruta completa del archivo
        $fullPath = $file.FullName
        
        # Separar la ruta y el nombre del archivo
        $directory = Split-Path $fullPath -Parent
        $name = Split-Path $fullPath -Leaf
        
        # Convertir el nombre del archivo a minúsculas
        $lowerCaseName = $name.ToLowerInvariant()
        
        # Verificar si el nombre actual es diferente al nombre en minúsculas
        if ($name -cne $lowerCaseName) {
            # Combinar la ruta original con el nuevo nombre en minúsculas
            $newPath = Join-Path $directory $lowerCaseName
            
            # Renombrar el archivo con el nuevo nombre en minúsculas
            Rename-Item -Path $fullPath -NewName $newPath
            Write-Host "Renombrado '$fullPath' a '$newPath'"
        } else {
            Write-Host "El archivo '$fullPath' ya está en minúsculas."
        }
    }
}

# Llamar a las funciones para procesar directorios y archivos
Write-Host "Procesando directorios..."
Process-Directories -path $scriptPath

Write-Host "Procesando archivos..."
Process-Files -path $scriptPath
