# Ruta de la carpeta principal que contiene los repositorios
$carpetaRepositorios = "D:\osvaldohm\Desktop\Repositories"

# Obtiene una lista de las subcarpetas (que representan los repositorios)
$repositorios = Get-ChildItem -Path $carpetaRepositorios -Directory

# Bucle a través de cada repositorio
foreach ($repositorio in $repositorios) {
    # Verifica si el directorio actual es un repositorio Git
    if (Test-Path -Path (Join-Path -Path $repositorio.FullName -ChildPath ".git") -PathType Container) {
        # Cambia el directorio de trabajo al repositorio actual
        Set-Location -Path $repositorio.FullName

        # Agregar todos los cambios
        git add .

        # Obtener los archivos que se han agregado al commit
        $archivosAgregados = git diff --staged --name-only

        # Generar un mensaje de commit basado en los archivos agregados
        $mensajeCommit = "Se agregaron los siguientes archivos:`n$archivosAgregados"

        # Realizar un commit con el mensaje generado
        git commit -m $mensajeCommit

        # Hacer push a la rama origin (asegúrate de tener una rama llamada 'origin' configurada)
        git push origin

        # Volver al directorio principal de repositorios
        Set-Location -Path $carpetaRepositorios
    }
}

# Pausa hasta que el usuario presione Enter
Read-Host -Prompt "Presiona Enter para continuar..."
