
#
# Script to keep the PC alive, will prevent screen lock and sleep.
# Works by pressing Print Screen every 2 minutes, side effect is that a screenshot will overwrite the clipboard contents
#
Write-Host '                                    '
Write-Host '                                    '
Write-Host '                                    '
Write-Host '                                    '
Write-Host '                                    '
Write-Host '                                    '
Write-Host '                                    '
Write-Host '                                    '
Write-Host '                                    '
Write-Host '                   %                '
Write-Host '                %%%                 '
Write-Host '           %%%%..                   '
Write-Host '         %%%/%    %                 '
Write-Host '        &%%%%%    %%                '
Write-Host '          &%%%%%   %%,              '
Write-Host '              (%%%%                 '
Write-Host '                  %.                '
Write-Host '                                    '
Write-Host ' %&&&&%###&&@@@@@@@@@@@@#           '
Write-Host ' %&&&&%###&&@@@@@@@@@@@@&%&&&#      '
Write-Host ' %&&&&%%#%&&@@@@@@@@@@@@@@     @@*  '
Write-Host ' %&@&&%%#%&&@@@@@@@@@@@&(        &@ '
Write-Host ' %&&&&&%#%&&@@@@@@@@@@@&/        &@ '
Write-Host ' %&&&&&%%%&@@@@@@@@@@@@&*        @@ '
Write-Host ' %&&&&&%%%&@@@@@@@@@@@@&,        && '
Write-Host ' #&&&&&%%%&@@@@@@@@@@@@&/      ,&&  '
Write-Host ' %&&&&&%%%&@@@@@@@@@@@@@@@%&@@&&    '
Write-Host ' %&&&&&%%%&@@@@@@@@@@@&&            '
Write-Host ' .&@&&&&&&&@@@@@@@@@@&&&...         '
Write-Host '                                    '

write-warning "Your PC will not go to sleep while this window is open...\n"

$phrases = "Despertando a Cari...", "Verificando que sus perritos esten en casa...", "Enviando papeleo a Ian...", "Buscando el tesoro perdido..."
while ($true) { 
    Write-Progress -Activity "Manteniendo despierto tu PC" -Status $phrases[(Get-Random -Minimum 0 -Maximum $phrases.Count)] -PercentComplete ((Get-Random -Minimum 1 -Maximum 100)); 
    Start-Sleep -Milliseconds 3000 
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[System.Windows.Forms.SendKeys]::SendWait("{CAPSLOCK}")
[System.Windows.Forms.SendKeys]::SendWait("{CAPSLOCK}")
}
