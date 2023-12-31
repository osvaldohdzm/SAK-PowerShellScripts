# Instala el módulo PSReadLine si aún no está instalado
if (-not (Get-Module -Name PSReadLine -ListAvailable)) {
    Install-Module -Name PSReadLine -Scope CurrentUser -Force -AllowClobber
}

# Importa el módulo PSReadLine
Import-Module PSReadLine

# Ruta del archivo en el que se creará el flujo alternativo
$archivo = "archivo.txt"

# Crear un archivo de texto
Set-Content -Path $archivo -Value "Este es el flujo principal del archivo."

# Datos que se escribirán en el flujo alternativo
$datosFlujoAlternativo = "Estos son datos en el flujo alternativo."

# Crear el flujo alternativo en el archivo utilizando un comando externo
Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "/c echo $($datosFlujoAlternativo) > $($archivo):stream1"

# Mostrar la sección de identificación de flujos
$msgIdentificacionFlujos = "Identificación de flujos:" | Write-Host -ForegroundColor Green

# Ejecutar streams.exe y cambiar su color de salida
& "C:\SysinternalsSuite\streams.exe" $archivo | ForEach-Object { Write-Host $_ -ForegroundColor Green }

# Leer el flujo principal del archivo
$flujoPrincipal = Get-Content $archivo

# Cambiar el color de las palabras específicas a verde y mostrar el contenido con el formato deseado
$msgflujoPrincipal = "Flujo principal:" | Write-Host -ForegroundColor Green

# Imprimir el flujo principal con el formato de color
Write-Host $msgflujoPrincipal
Write-Host $flujoPrincipal

# Leer el flujo alternativo del archivo
$flujoAlternativo = Get-Content $archivo -Stream "stream1"

# Cambiar el color de las palabras específicas a verde y mostrar el contenido con el formato deseado
$msgflujoAlternativo = "Flujo alternativo:" | Write-Host -ForegroundColor Green

# Imprimir el flujo alternativo con el formato de color
Write-Host $msgflujoAlternativo
Write-Host $flujoAlternativo
