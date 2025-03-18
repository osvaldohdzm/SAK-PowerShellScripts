# Lista de carpetas con repositorios
$carpetasRepositorios = @(
    "D:\Users\osvaldohm\Repositories",
    "D:\Users\osvaldohm\Repositories"
)

# Bucle a través de cada carpeta de repositorio
foreach ($carpetaRepositorio in $carpetasRepositorios) {
    # Obtiene una lista de las subcarpetas (que representan los repositorios)
    $repositorios = Get-ChildItem -Path $carpetaRepositorio -Directory

    # Bucle a través de cada repositorio en la carpeta actual
    foreach ($repositorio in $repositorios) {
        # Verifica si el directorio actual es un repositorio Git
        if (Test-Path -Path (Join-Path -Path $repositorio.FullName -ChildPath ".git") -PathType Container) {
            write-host working on $repositorio.FullName
            # Configura el comando safe.directory            

            # Cambia el directorio de trabajo al repositorio actual
            Set-Location -Path $repositorio.FullName            
            
            git config --global --add safe.directory $repositorio.FullName
            git config --local --add safe.directory $repositorio.FullName

            # Realiza las operaciones Git necesarias (pull, add, commit, push)
            git pull origin
            git add .
            $mensajeCommit = "Se agregaron o modificaron los siguientes archivos:`n$archivosAgregados"
            git commit -m "$mensajeCommit"
            git push origin

            # Volver al directorio principal de repositorios
            Set-Location -Path $carpetaRepositorio
        }
    }
}

# Pausa hasta que el usuario presione Enter
Read-Host -Prompt "Presiona Enter para continuar..."
