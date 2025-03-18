# Extrae la información del sistema utilizando msinfo32 y la guarda en un archivo de texto
$msinfoOutputFile = "Machine-info.txt"

# Abre un archivo para escritura
$streamWriter = [System.IO.StreamWriter]::new($msinfoOutputFile)

# Muestra la información de memoria
Get-WmiObject -Class "Win32_PhysicalMemory" | ForEach-Object {
    $manufacturer = $_.Manufacturer
    $capacity = $_.Capacity / 1GB
    $memoryType = switch ($_.MemoryType) {
        20 { "DDR" }
        21 { "DDR2" }
        22 { "DDR2 FB-DIMM" }
        24 { "DDR3" }
        26 { "DDR4" }
        default { "Desconocido" }
    }
    
    # Escribe la información en el archivo
    $streamWriter.WriteLine("Tipo de memoria: $memoryType")
    $streamWriter.WriteLine("Fabricante: $manufacturer")
    $streamWriter.WriteLine("Capacidad: $capacity GB")
}

# Cierra el archivo después de terminar de escribir
$streamWriter.Close()
