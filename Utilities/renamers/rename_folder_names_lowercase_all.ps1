# rename_folder_names_first_capital.ps1
# Script para renombrar únicamente carpetas cambiando solo la primera letra a mayúscula

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

# Función para procesar carpetas
function Process-Directories {
    param([string]$path)

    # Obtener todas las carpetas (recursivo)
    $directories = Get-ChildItem -Path $path -Directory -Recurse

    # Ordenar por longitud inversa para evitar conflictos al renombrar rutas
    $directories = $directories | Sort-Object { $_.FullName.Length } -Descending

    foreach ($dir in $directories) {
        $fullPath = $dir.FullName
        $parent = Split-Path $fullPath -Parent
        $name = Split-Path $fullPath -Leaf

        $capitalizedName = Capitalize-FirstLetter $name

        if ($name -cne $capitalizedName) {
            Rename-Item -Path $fullPath -NewName $capitalizedName
            Write-Host "Renombrado '$fullPath' → '$capitalizedName'"
        } else {
            Write-Host "La carpeta '$fullPath' ya empieza con mayúscula."
        }
    }
}

Write-Host "Procesando carpetas..."
Process-Directories -path $scriptPath
