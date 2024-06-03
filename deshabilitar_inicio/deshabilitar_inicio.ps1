# Función para verificar privilegios de administrador
function Check-AdminPrivileges {
    # Verifica si el usuario actual tiene privilegios de administrador
    if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        # Relanza el script con privilegios elevados
        Start-Process "powershell" -ArgumentList "-ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Definition)`"" -Verb RunAs
        # Salir del script actual
        exit
    }
}

# Función para deshabilitar propiedades del registro
function Disable-RegistryProperties {
    param (
        [string[]]$programsToDisable,
        [string]$registryPath
    )

    # Verificar si la ruta de registro existe
    if (Test-Path $registryPath) {
        # Obtener las propiedades del registro en la ruta especificada
        $properties = Get-ItemProperty -Path $registryPath

        # Recorrer cada propiedad
        foreach ($property in $properties.PSObject.Properties) {
            foreach ($program in $programsToDisable) {
                # Verificar si el nombre o el valor de la propiedad coincide con el programa
                if ($property.Name -like "*$program*" -or ($property.PSDefaultValue | Out-String) -like "*$program*") {
                    # Eliminar la propiedad del registro para deshabilitar el programa
                    Remove-ItemProperty -Path $registryPath -Name $property.Name -Force
                    Write-Host "Deshabilitado programa de inicio: $property.Name de la ruta $registryPath"
                }
            }
        }
    } else {
        # Mostrar mensaje si la ruta no se encuentra
        Write-Host "Ruta de registro no encontrada: $registryPath"
    }
}

# Función para eliminar o desactivar programas de inicio en las rutas especificadas
function Disable-AutostartPrograms {
    param (
        [string[]]$registryPaths,  # Lista de rutas de registro para verificar
        [string[]]$programsToDisable  # Lista de programas a deshabilitar
    )

    # Iterar sobre cada ruta de registro
    foreach ($registryPath in $registryPaths) {
        # Verificar si la ruta de registro existe
        if (Test-Path $registryPath) {
            # Obtener las propiedades del registro en la ruta especificada
            $properties = Get-ItemProperty -Path $registryPath

            # Recorrer cada propiedad
            foreach ($property in $properties.PSObject.Properties) {
                foreach ($program in $programsToDisable) {
                    # Verificar si el nombre o el valor de la propiedad coincide con el programa a deshabilitar
                    if ($property.Name -like "*$program*" -or ($property.PSDefaultValue | Out-String) -like "*$program*") {
                        # Eliminar la propiedad del registro para deshabilitar el programa de inicio
                        Remove-ItemProperty -Path $registryPath -Name $property.Name -Force
                        Write-Host "Deshabilitado programa de inicio: $property.Name de la ruta $registryPath"
                    }
                }
            }
        } else {
            # Mostrar mensaje si la ruta no se encuentra
            Write-Host "Ruta de registro no encontrada: $registryPath"
        }
    }
}

# Función para deshabilitar tareas programadas relacionadas
function Disable-ScheduledTasks {
    param (
        [string[]]$programs
    )

    foreach ($program in $programs) {
        # Obtener tareas programadas relacionadas
        $tasks = Get-ScheduledTask -TaskName "*$program*" -ErrorAction SilentlyContinue
        foreach ($task in $tasks) {
            try {
                # Deshabilitar la tarea programada
                Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false
                Write-Host "Deshabilitado $program eliminando tarea programada: $task.TaskName."

                # Verificar la acción de la tarea programada
                $taskAction = $task.Actions | Where-Object { $_.ActionType -eq "Execute" }
                if ($taskAction) {
                    $processName = [System.IO.Path]::GetFileNameWithoutExtension($taskAction.Path)

                    # Ejecutar `taskkill` para finalizar el proceso
                    taskkill /F /IM "$processName.exe" /T
                    Write-Host "Finalizado el proceso asociado: $processName.exe"
                }
            } catch {
                Write-Host "No se pudo deshabilitar la tarea programada o finalizar el proceso asociado a: $task.TaskName"
            }
        }
    }
}


function Disable-RelatedServices {
  param (
    [string[]]$programs
  )

  foreach ($program in $programs) {
    # Obtener servicios relacionados con el programa
    $services = Get-Service | Where-Object { $_.Name -like "*$program*" -or $_.DisplayName -like "*$program*" }
    foreach ($service in $services) {
      try {
        # Deshabilitar el servicio
        Set-Service -Name $service.Name -StartupType Disabled
        Write-Host "Deshabilitado el servicio $service.DisplayName ($service.Name)."
      } catch {
        Write-Host "No se pudo deshabilitar el servicio $service.DisplayName ($service.Name). Verifica permisos."
      }
    }
  }
}

# Función para deshabilitar programas de inicio en las rutas de registro especificadas
function StartupProgramsInRegistry {
    param (
        [Parameter(Mandatory = $true)]
        [array] $programsToDisable,
        
        [Parameter(Mandatory = $true)]
        [array] $registryPaths
    )

    # Iterar sobre las rutas de registro
    foreach ($registryPath in $registryPaths) {
        # Iterar sobre los programas a deshabilitar
        foreach ($program in $programsToDisable) {
            # Verificar si el programa está en la lista de inicio
            try {
                $registryProperties = Get-ItemProperty -Path $registryPath
                if ($registryProperties.PSObject.Properties.Name -contains $program) {
                    # Eliminar la entrada del programa del registro
                    Remove-ItemProperty -Path $registryPath -Name $program -Force
                    Write-Host "Deshabilitado el programa de inicio: $program"
                }
            } catch {
                Write-Error "Error al deshabilitar el programa de inicio: $program en la ruta de registro: $registryPath. Error: ($_.Exception.Message)"
            }
        }
    }
}



# Función para deshabilitar programas de inicio en las rutas de registro especificadas
function StartupProgramsInRegistry {
    param (
        [Parameter(Mandatory = $true)]
        [array] $programsToDisable,
        
        [Parameter(Mandatory = $true)]
        [array] $registryPaths
    )

    # Iterar sobre las rutas de registro
    foreach ($registryPath in $registryPaths) {
        # Verificar si la ruta de registro existe
        if (Test-Path $registryPath) {
            # Iterar sobre los programas a deshabilitar
            foreach ($program in $programsToDisable) {
                try {
                    # Obtener las propiedades del registro en la ruta especificada
                    $registryProperties = Get-ItemProperty -Path $registryPath
                    # Verificar si la propiedad existe en las propiedades del registro
                    if ($registryProperties.PSObject.Properties.Name -contains $program) {
                        # Eliminar la entrada del programa del registro
                        Remove-ItemProperty -Path $registryPath -Name $program -Force
                        Write-Host "Deshabilitado el programa de inicio: $program en la ruta de registro: $registryPath"
                    } else {
                        Write-Host "El programa $program no existe en la ruta de registro: $registryPath, no se realizó ninguna acción."
                    }
                } catch {
                    Write-Error "Error al deshabilitar el programa de inicio: $program en la ruta de registro: $registryPath. Error: ($_.Exception.Message)"
                }
            }
        } else {
            Write-Host "La ruta de registro $registryPath no existe, se omitirá."
        }
    }
}



# Lista de programas a deshabilitar
$programsToDisable = @(
    'btweb',
    'Logitech',
    'Java',
    'vmware',
    'Adobe',
    'CCXProcess',
    'VMware'
)

# Define las rutas de registro para verificar
$registryPaths = @(
    'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
    'HKCU\Software\Microsoft NT\CurrentVersion\Windows\Run',
    'HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce',
    'HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnceEx',
    'HKCU\Software\Microsoft\Windows\CurrentVersion\RunServices',
    'HKCU\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce',
    'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
    'HKLM\System\CurrentControlSet\Services',
    'HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce',
    'HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnceEx',
    'HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run'
)

# Verificar privilegios elevados
Check-AdminPrivileges

# Deshabilitar programas de inicio
Disable-AutostartPrograms -programsToDisable $programsToDisable -registryPaths $registryPaths

# Deshabilitar servicios relacionados
Disable-RelatedServices -programs $programsToDisable

# Deshabilitar tareas programadas relacionadas
Disable-ScheduledTasks -programs $programsToDisable

StartupProgramsInRegistry -programsToDisable $programsToDisable -registryPaths $registryPaths


function Disable-StartupProgram {
    param(
        [Parameter(Mandatory = $true)]
        [string] $ProgramName
    )

    # Define la ruta del registro
    $registryPath = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"

    try {
        # Verifica si la propiedad existe en la ruta de registro
        $properties = Get-ItemProperty -Path $registryPath
        if ($properties.PSObject.Properties.Name -contains $ProgramName) {
            # Elimina la propiedad del registro si existe
            Remove-ItemProperty -Path $registryPath -Name $ProgramName -Force
            Write-Host "Successfully disabled startup program: $ProgramName"
        } else {
            Write-Host "The startup program $ProgramName does not exist in the registry path: $registryPath."
        }
    } catch {
        # Maneja cualquier otro error que pueda ocurrir
        Write-Error "Error disabling startup program: $ProgramName. Error: ($_.Exception.Message)"
    }
}

# Ejemplos de uso (reemplaza los nombres de programas con los tuyos)
Disable-StartupProgram -ProgramName "SunJavaUpdateSched"
Disable-StartupProgram -ProgramName "vmware-tray.exe"
Disable-StartupProgram -ProgramName "Adobe CCXProcess"


function Disable-StartupProgram {
    param(
        [Parameter(Mandatory = $true)]
        [string] $ProgramName
    )

    # Define la ruta del registro
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"

    try {
        # Verifica si la propiedad existe en la ruta de registro
        $properties = Get-ItemProperty -Path $registryPath
        if ($properties.PSObject.Properties.Name -contains $ProgramName) {
            # Elimina la propiedad del registro si existe
            Remove-ItemProperty -Path $registryPath -Name $ProgramName -Force
            Write-Host "Successfully disabled startup program: $ProgramName"
        } else {
            Write-Host "The startup program $ProgramName does not exist in the registry path: $registryPath."
        }
    } catch {
        # Maneja cualquier otro error que pueda ocurrir
        Write-Error "Error disabling startup program: $ProgramName. Error: ($_.Exception.Message)"
    }
}

Disable-StartupProgram -ProgramName "btweb"


# Define la ruta de la clave de registro para los programas de inicio de Windows
$logitechKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"

# Obtén las propiedades de la clave de registro
$registryProperties = Get-ItemProperty -Path $logitechKey

# Verifica si el Logitech Download Assistant está en las entradas de inicio
if ($registryProperties.PSObject.Properties.Name -contains "Logitech Download Assistant") {
    # Elimina la entrada de Logitech Download Assistant de los programas de inicio
    Remove-ItemProperty -Path $logitechKey -Name "Logitech Download Assistant"
    Write-Host "Logitech Download Assistant has been disabled from startup."
} else {
    Write-Host "Logitech Download Assistant is not found in the startup programs."
}


# Specify the exact path to the registry key and the value name you want to remove
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$programName = "btweb"

# Remove the specified registry entry
Remove-ItemProperty -Path $registryPath -Name $programName

Write-Host "Startup entry for '$programName' has been removed from the registry."

