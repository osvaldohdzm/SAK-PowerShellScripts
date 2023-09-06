

# Definir la función con el nombre que quieras
function Create-Files {

    # Recibir la ruta como un parámetro
    param($path)

    Write-Host $path

    # Crear una lista de nombres posibles para los archivos
    $names = "chrome.exe", "firefox.exe", "nmap.exe", "vivaldi.exe", "image.png", "ping.exe", "contabilidad.xlsx", "presentacion.pptx", "documento.docx"

    # Crear un bucle para generar 6 archivos
    for ($i = 1; $i -le 5; $i++) {

        # Elegir un nombre aleatorio de la lista
        $name = Get-Random -InputObject $names

        # Generar un tamaño aleatorio entre 10 y 87.8 MB en bytes
$size = [int](Get-Random -Minimum (10 * 1024 * 1024) -Maximum (87.8 * 1024 * 1024))

        # Crear un archivo vacío del tamaño generado con fsutil en la ruta especificada
        fsutil file createnew "$path\$name" $size

        # Obtener el contenido del archivo como una cadena
        $content = Get-Content -Path "$path\$name" -Raw

        
        # Guardar el nuevo contenido en el archivo
        Set-Content -Path "$path\$name" -Value $content

    }
}



# Pedir al usuario introducir una letra que corresponde a una unidad de almacenamiento
$letra = Read-Host 'Introduce la letra de una unidad de almacenamiento'

$folderPath = "${letra}:\\$([char]0x200B)"

mkdir $folderPath

# Crea un archivo desktop.ini dentro de la carpeta
@"
[.ShellClassInfo]
IconResource=C:\WINDOWS\System32\SHELL32.dll,49
[ViewState]
Mode=
Vid=
FolderType=Generic
"@ | Out-File "$folderPath\desktop.ini" -Encoding ASCII

# Establece los atributos del sistema a los archivos y la carpeta
attrib +s $folderPath
attrib +s +h "$folderPath\desktop.ini"

# Actualiza el explorador de archivos para ver el cambio
ie4uinit.exe -show





# Define una función para generar un nombre aleatorio de 6 caracteres
function Get-RandomName {
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    $name = ""
    for ($i = 0; $i -lt 6; $i++) {
        $name += $chars[(Get-Random -Maximum $chars.Length)]
    }
    return $name
}

# Crea un bucle para crear 10 carpetas con nombres aleatorios
for ($j = 0; $j -lt 3; $j++) {
    # Genera un nombre aleatorio usando la función definida
    $randName = Get-RandomName

    # Crea una carpeta con el nombre aleatorio en la ubicación deseada (por ejemplo, C:\Temp)
    New-Item -Path "$folderPath\$randName" -ItemType Directory


Create-Files "$folderPath\$randName"

}




