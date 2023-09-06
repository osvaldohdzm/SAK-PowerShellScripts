Write-Host "`n`nInitializing...`n" -NoNewline -ForegroundColor green

$current_path = (Get-Location).Path


Write-Host "`n`nChanging file names...`n" -NoNewline -ForegroundColor green
Get-ChildItem -r $current_path | Where {!$_.PSIsContainer} | 
                   Rename-Item -NewName {$_.Name.ToLower() -replace ' ','-'  }


Write-output "Finished at $(Get-Date)"
[Console]::ReadKey()

