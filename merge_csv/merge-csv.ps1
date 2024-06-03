$output_path = "outputs"
If(!(test-path -PathType container $output_path))
{
      New-Item -ItemType Directory -Path $output_path
}


Get-ChildItem *.csv -PipelineVariable File |
  ForEach-Object { Import-Csv $_ | Select *,@{l='FileName';e={$File.Name}}} |
  Export-Csv $output_path\output.csv -NoTypeInformation