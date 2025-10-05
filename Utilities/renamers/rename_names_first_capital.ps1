rename_names_first_capital

# Obtener la ruta de la carpeta donde se encuentra el script
$scriptPath = $PSScriptRoot

# Función para capitalizar solo la primera letra
function Capitalize-FirstLetter {
    param([string]$text)

    if ([string]::IsNullOrEmpty($text)) {
        return $text
    }

    $first = $text.Substring(0,1).ToUpper()
    $rest = $text.Substring(1)
    return "$first$rest"
}

# Función para procesar directorios
function Process-Directories {
    param([string]$path)

    $directories = Get-ChildItem -Path $path -Directory

    foreach ($dir in $directories) {
        $fullPath = $dir.FullName
        $directory = Split-Path $fullPath -Parent
        $name = Split-Path $fullPath -Leaf

        $capitalizedName = Capitalize-FirstLetter $name

        if ($name -cne $capitalizedName) {
            $newPath = Join-Path $directory $capitalizedName
            Rename-Item -Path $fullPath -NewName $capitalizedName
            Write-Host "Renombrado '$fullPath' a '$newPath'"
        } else {
            Write-Host "El directorio '$fullPath' ya está con la primera letra mayúscula."
        }
    }
}

# Función para procesar archivos
function Process-Files {
    param([string]$path)

    $files = Get-ChildItem -Path $path -File

    foreach ($file in $files) {
        $fullPath = $file.FullName
        $directory = Split-Path $fullPath -Parent
        $name = Split-Path $fullPath -Leaf

        $capitalizedName = Capitalize-FirstLetter $name

        if ($name -cne $capitalizedName) {
            $newPath = Join-Path $directory $capitalizedName
            Rename-Item -Path $fullPath -NewName $capitalizedName
            Write-Host "Renombrado '$fullPath' a '$newPath'"
        } else {
            Write-Host "El archivo '$fullPath' ya está con la primera letra mayúscula."
        }
    }
}

# Llamar a las funciones
Write-Host "Procesando directorios..."
Process-Directories -path $scriptPath

Write-Host "Procesando archivos..."
Process-Files -path $scriptPath
