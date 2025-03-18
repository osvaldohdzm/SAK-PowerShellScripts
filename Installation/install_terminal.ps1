Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -outfile Microsoft.VCLibs.x86.14.00.Desktop.appx
Add-AppxPackage Microsoft.VCLibs.x86.14.00.Desktop.appx

# Download Terminal (Change version)
Invoke-WebRequest -Uri https://github.com/microsoft/terminal/releases/download/v1.7.1091.0/Microsoft.WindowsTerminal_1.7.1091.0_8wekyb3d8bbwe.msixbundle -outfile Microsoft.WindowsTerminal_1.7.1091.0_8wekyb3d8bbwe.msixbundle