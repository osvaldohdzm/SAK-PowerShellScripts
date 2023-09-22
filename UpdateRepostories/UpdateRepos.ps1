# Lista de carpetas con repositorios
$carpetasRepositorios = @(
"D:\osvaldohm\Desktop\Repositories",
"D:\osvaldohm\Desktop\KaliHome\Repositories"
)

# Bucle a través de cada carpeta de repositorio
foreach ($carpetaRepositorio in $carpetasRepositorios) {
    # Obtiene una lista de las subcarpetas (que representan los repositorios)
    $repositorios = Get-ChildItem -Path $carpetaRepositorio -Directory

    # Bucle a través de cada repositorio en la carpeta actual
    foreach ($repositorio in $repositorios) {
        # Verifica si el directorio actual es un repositorio Git
        if (Test-Path -Path (Join-Path -Path $repositorio.FullName -ChildPath ".git") -PathType Container) {
            # Cambia el directorio de trabajo al repositorio actual
            Set-Location -Path $repositorio.FullName
            
            git pull origin

            # Agregar todos los cambios
            git add .

            # Obtener los archivos que se han agregado al commit
            $archivosAgregados = git diff --staged --name-only

            # Generar un mensaje de commit basado en los archivos agregados
            $mensajeCommit = "Se agregaron o modificaron los siguientes archivos:`n$archivosAgregados"

            # Realizar un commit con el mensaje generado
            git commit -m $mensajeCommit

            # Hacer push a la rama origin (asegúrate de tener una rama llamada 'origin' configurada)
            git push origin

            # Volver al directorio principal de repositorios
            Set-Location -Path $carpetaRepositorio
        }
    }
}

# Pausa hasta que el usuario presione Enter
Read-Host -Prompt "Presiona Enter para continuar..."
