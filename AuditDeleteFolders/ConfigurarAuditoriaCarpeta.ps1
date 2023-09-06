param (
    [string]$Path
)

# Verificar si se proporciona la ruta
if ([string]::IsNullOrWhiteSpace($Path)) {
    Write-Host "Uso: .\AuditarCarpeta.ps1 -Path RUTA_DE_LA_CARPETA"
    exit
}

# Verificar si el directorio de destino existe
if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Host "El directorio '$Path' no existe."
    exit
}

Set-ItemProperty -Path HKLM:\\System\\CurrentControlSet\\Services\\Audiosrv -Name ObjectAudit -Value 1

# Type: File System
$fsGuid = "{0CCE921D-69AE-11D9-BED3-505054503030}"
# Type: File Share
$fshGuid = "{0CCE9224-69AE-11D9-BED3-505054503030}"

# Enable auditing on both local deletions and network share deletions.
$auditCmd = "auditpol /set /subcategory:""$fsGuid"" /success:enable /failure:enable"
Invoke-Expression $auditCmd
$auditCmd = "auditpol /set /subcategory:""$fshGuid"" /success:enable /failure:enable"
Invoke-Expression $auditCmd

$auditCmd = "auditpol /get /category:""{6997984A-797A-11D9-BED3-505054503030}"""
Invoke-Expression $auditCmd

# Recursivamente auditar la carpeta y sus elementos
function Audit-Folder($Folder) {
    $auditFlags = [System.Security.AccessControl.AuditFlags]::Success
    $ruleDeleteSubfoldersAndFiles = New-Object System.Security.AccessControl.FileSystemAuditRule("Everyone", "DeleteSubdirectoriesAndFiles", $auditFlags)
    $ruleDelete = New-Object System.Security.AccessControl.FileSystemAuditRule("Everyone", "Delete", $auditFlags)

    $acl = Get-Acl -Path $Folder.FullName
    $acl.AddAuditRule($ruleDeleteSubfoldersAndFiles)
    $acl.AddAuditRule($ruleDelete)
    Set-Acl -Path $Folder.FullName -AclObject $acl
}

# Aplicar auditoría a la carpeta principal
Audit-Folder (Get-Item -Path $Path)

# Aplicar auditoría a los elementos en subdirectorios
$items = Get-ChildItem -Path $Path -File -Recurse
$folders = Get-ChildItem -Path $Path -Directory -Recurse

$items | ForEach-Object {
    Audit-Folder $_
}

$folders | ForEach-Object {
    Audit-Folder $_
}

gpupdate /force
Write-Host "La configuración de auditoría se ha completado para la carpeta '$Path' y sus elementos."
