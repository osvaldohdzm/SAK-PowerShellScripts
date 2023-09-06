Import-Module PSWorkflow

Write-Host "`nCreating tmp dir...`n" -NoNewline -ForegroundColor green

$tmp_path = "tmp"
If(!(Test-Path -PathType Container $tmp_path))
{
    New-Item -ItemType Directory -Path $tmp_path
}

$output_path = "outputs"
If(!(Test-Path -PathType Container $output_path))
{
    New-Item -ItemType Directory -Path $output_path
}

$targetsFilePath = Read-Host "Enter the path of the file containing targets"
$targetsFilePath = $targetsFilePath -replace '"', ''  # Remove double quotes if present

Write-Host "`nAdding nmap to temporal path...`n" -NoNewline -ForegroundColor green

$nmap_path = "C:\Program Files (x86)\Nmap\"
$env:Path += ";$nmap_path"

Write-Host "`nSplitting list...`n" -NoNewline -ForegroundColor green

$target_list_num_lines = (Get-Content $targetsFilePath).Length
$num_terminals = 10
$num_files_scan = [int]($target_list_num_lines / $num_terminals)

$i = 0
Get-Content $targetsFilePath -ReadCount $num_files_scan | ForEach-Object {
    $i++
    $_ | Out-File "$tmp_path\scan_$i.txt"
}

Write-Host "`nGetting list of current powershell process...`n" -NoNewline -ForegroundColor green

$start_process_id = (Get-Process powershell).ID
Write-Host $start_process_id

Write-Host "`nExecuting parallel scans...`n" -NoNewline -ForegroundColor green

Workflow NMAPParallelScans {

    $lists = Get-ChildItem "tmp" -Recurse | Where-Object { $_.Extension -eq ".txt" } | ForEach-Object {
        Write-Output $_.FullName
    }

    ForEach -Parallel ($list in $lists) {
        $Command = @"
        { 
            `$env:Path += `';C:\Program Files (x86)\Nmap\`'; 
            foreach (`$line in Get-Content -Encoding UTF8 `"$list`") { 
                nmap -Pn -sS -p- -sV -n --min-rate 5432 --open --stats-every 3s --host-timeout 120m --initial-rtt-timeout 315ms --min-rtt-timeout 280ms --max-rtt-timeout 350ms --max-retries 1 --max-scan-delay 0 -oA outputs\`$(`$line) `$line 
            }; 
            exit 
        }
"@
        Start-Process powershell -ArgumentList "-noexit","-Command", "& $Command"  
    }
}

NMAPParallelScans

$sec = $num_terminals * 3
Start-Sleep -Seconds $sec

$running_process_id = (Get-Process powershell).ID
Write-Host $running_process_id

$process_ids = Compare-Object -ReferenceObject $start_process_id -DifferenceObject $running_process_id -PassThru

Wait-Process -Id $process_ids

Remove-Item $tmp_path -Recurse -Force -Confirm:$false 

Write-Host "`nScans completed at $(Get-Date)`n" -NoNewline -ForegroundColor green
