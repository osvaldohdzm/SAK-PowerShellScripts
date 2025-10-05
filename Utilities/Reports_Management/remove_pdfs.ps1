<#
.SYNOPSIS
    Deletes all PDF files (.pdf) from the current directory and all subdirectories.

.DESCRIPTION
    This script performs a recursive search for all files ending with the .pdf extension,
    starting from the folder where the script is run. It will count the files and then
    prompt the user for confirmation before permanently deleting them.

.NOTES
    Author: AI Assistant
    Version: 1.0
    WARNING: This action is PERMANENT. Deleted files cannot be easily recovered.
             It is highly recommended to have a backup of your data before running this script.
#>

# --- Script Start ---

try {
    # Get the current directory where the script is being run
    $startPath = Get-Location

    Write-Host "Searching for .pdf files in '$($startPath.Path)' and all subdirectories..." -ForegroundColor Cyan

    # Find all PDF files recursively. The -ErrorAction SilentlyContinue will ignore any potential access denied errors on folders.
    $pdfFiles = Get-ChildItem -Path $startPath -Recurse -Filter "*.pdf" -ErrorAction SilentlyContinue

    # Check if any PDF files were found
    if ($null -eq $pdfFiles -or $pdfFiles.Count -eq 0) {
        Write-Host "No .pdf files found in this location. No action taken." -ForegroundColor Green
        exit
    }

    $fileCount = $pdfFiles.Count
    Write-Host "--------------------------------------------------------" -ForegroundColor Yellow
    Write-Host "FOUND: $fileCount PDF file(s) to be deleted." -ForegroundColor Yellow
    Write-Host "WARNING: This action is PERMANENT and cannot be undone." -ForegroundColor Red
    Write-Host "--------------------------------------------------------"

    # Ask the user for confirmation before proceeding
    $confirmation = Read-Host "Are you absolutely sure you want to delete these $fileCount files? (Type 'Y' to confirm, any other key to cancel)"

    # If the user confirms with 'Y' (case-insensitive), proceed with deletion
    if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
        Write-Host "Confirmation received. Starting deletion process..." -ForegroundColor Green
        
        # Loop through each file and delete it
        foreach ($file in $pdfFiles) {
            try {
                Write-Host "Deleting: $($file.FullName)"
                Remove-Item -Path $file.FullName -Force -ErrorAction Stop
            }
            catch {
                # This will catch errors if a file is in use or there are permission issues
                Write-Warning "Could not delete '$($file.FullName)'. It might be in use or protected. Error: $($_.Exception.Message)"
            }
        }
        
        Write-Host "--------------------------------------------------------"
        Write-Host "Deletion process complete. $fileCount file(s) removed." -ForegroundColor Green

    } else {
        # If the user does not confirm, cancel the operation
        Write-Host "Deletion cancelled by user. No files were deleted." -ForegroundColor Red
    }
}
catch {
    # Catch any other unexpected errors during the script execution
    Write-Error "An unexpected error occurred: $($_.Exception.Message)"
}