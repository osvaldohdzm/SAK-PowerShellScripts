Write-Host "`n`nInitializing...`n" -NoNewline -ForegroundColor green

Get-Content cnint-list.txt | where {$_.readcount -gt 1 } | Get-Random -Count 300 | Out-File -Encoding utf8 cnint-list-tiny.txt


Write-output "Finished at $(Get-Date)"
[Console]::ReadKey()

