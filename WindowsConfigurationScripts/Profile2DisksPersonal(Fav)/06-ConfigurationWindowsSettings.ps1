# Crear una nueva propiedad de registro con el nombre HideFileExt y el valor 0 Para mostrar exntesiones de archivo
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -PropertyType DWORD -Force

$keyboardList = Get-WinUserLanguageList
$keyboardList.RemoveAll( { $args[0].LanguageTag -clike '*' } )
$keyboardList.Add("en-US")
$keyboardList[0].InputMethodTips.Clear() # 1 is the second language → en-US
$keyboardList[0].InputMethodTips.Add('0409:00020409') # You change this to the number you got from step #1
$keyboardList.Add("es-MX")
Set-WinUserLanguageList -LanguageList $keyboardList -Force 
Write-Output "Teclado Estados Unidos Internacional configurado correctamente."