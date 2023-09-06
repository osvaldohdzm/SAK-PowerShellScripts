# Prompt user for program origin folder path
$originFolderPath = Read-Host "Enter the path of the program origin folder"

# Validate input path
if (-not (Test-Path -Path $originFolderPath -PathType Container)) {
    Write-Host "Error: Program origin folder path does not exist."
    exit
}

# Prompt user for destination folder path
$destinationFolderPath = Read-Host "Enter the path of the destination folder (without the folder app name)"

# Validate input path
if (-not (Test-Path -Path $destinationFolderPath -PathType Container)) {
    Write-Host "Error: Destination folder path does not exist."
    exit
}

# Get the name of the program folder
$programFolderName = (Get-Item $originFolderPath).Name

# Construct full destination path
$destinationPathWithFolder = Join-Path -Path $destinationFolderPath -ChildPath $programFolderName

# Display confirmation message
$confirmationMessage = "Do you want to continue with this origin folder '$originFolderPath' and this destination folder '$destinationPathWithFolder'? (y/n)"
$confirmation = Read-Host -Prompt $confirmationMessage

if ($confirmation -ne "y") {
    Write-Host "Operation cancelled."
    exit
}

# Check if there are processes using files in the program origin folder
$processesUsingFiles = Get-Process | Where-Object { $_.Modules.ModuleName -match [Regex]::Escape($programFolderName) }

# If there are processes using files, prompt to close them or cancel
if ($processesUsingFiles.Count -gt 0) {
    Write-Host "Processes are currently using files in the program origin folder:"
    $processesUsingFiles | Format-Table Id, ProcessName, FileName -AutoSize

    $closeProcesses = Read-Host "Do you want to attempt to close these processes before proceeding? (y/n)"
    
    if ($closeProcesses -eq "y") {
        $processesUsingFiles | ForEach-Object {
            Write-Host "Stopping process: $($_.ProcessName) ($($_.Id))"
            Stop-Process -Id $_.Id -Force
        }
    } else {
        Write-Host "Operation cancelled."
        exit
    }
}

# Move the program origin folder to the destination
Move-Item -Path $originFolderPath -Destination $destinationPathWithFolder -Force

# Remove existing symbolic link or item at the source location
$originItem = Get-Item $originFolderPath -Force -ErrorAction SilentlyContinue
if ($originItem -and ($originItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
    Remove-Item -Path $originFolderPath -Force
} elseif ($originItem -and ($originItem.PSIsContainer)) {
    Remove-Item -Path $originFolderPath -Recurse -Force
}

# Create symbolic link in the original location pointing to the destination
$sourceLink = $originFolderPath
New-Item -Path $sourceLink -ItemType SymbolicLink -Value $destinationPathWithFolder

Write-Host "Program origin folder has been moved to the destination and a symbolic link has been created."
Write-Host "Symbolic link source: $sourceLink"
Write-Host "Symbolic link destination: $destinationPathWithFolder"
