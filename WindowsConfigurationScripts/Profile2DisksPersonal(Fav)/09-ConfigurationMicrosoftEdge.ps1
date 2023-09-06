# Fake MDM-Enrollment - Key 1 of 2 - let a Win10 and Win11 Machine "feel" MDM-Managed
$mdmKey1Path = "HKLM:\SOFTWARE\Microsoft\Enrollments\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
$mdmKey2Path = "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"

# Create MDM-Enrollment Keys
if (-not (Test-Path $mdmKey1Path)) {
    New-Item -Path $mdmKey1Path -Force
}

if (-not (Test-Path $mdmKey2Path)) {
    New-Item -Path $mdmKey2Path -Force
}

# Set values for MDM-Enrollment Keys
$mdmKey1Properties = @{
    "EnrollmentState" = 0x00000001;
    "EnrollmentType" = 0x00000000;
    "IsFederated" = 0x00000000;
}

$mdmKey2Properties = @{
    "Flags" = 0x00d6fb7f;
    "AcctUId" = "0x000000000000000000000000000000000000000000000000000000000000000000000000";
    "RoamingCount" = 0x00000000;
    "SslClientCertReference" = "MY;User;0000000000000000000000000000000000000000";
    "ProtoVer" = "1.2";
}

foreach ($property in $mdmKey1Properties.GetEnumerator()) {
    Set-ItemProperty -Path $mdmKey1Path -Name $property.Key -Value $property.Value -Force
}

foreach ($property in $mdmKey2Properties.GetEnumerator()) {
    Set-ItemProperty -Path $mdmKey2Path -Name $property.Key -Value $property.Value -Force
}

# Define the URLs for the homepage and new tab page
$homepageURL = "https://www.google.com/"
$newTabURL = "https://www.google.com/"

# Define the base path for Edge policies in the Registry
$edgePolicyBaseRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"

# Create the base policies key if it doesn't exist
if (-not (Test-Path $edgePolicyBaseRegPath)) {
    New-Item -Path $edgePolicyBaseRegPath -Force
}

# Define the path for configuring the new tab page and homepage in the Registry
$edgeRegPath = Join-Path $edgePolicyBaseRegPath "RestoreOnStartupURLs"

# Create the key for the homepage and new tab page URLs if they don't exist
if (-not (Test-Path $edgeRegPath)) {
    New-Item -Path $edgeRegPath -Force
}

# Define the path for the new tab page in the Registry
$edgeNewTabPagePath = Join-Path $edgePolicyBaseRegPath "NewTabPageLocation"

# Create the key for the new tab page URL if it doesn't exist
if (-not (Test-Path $edgeNewTabPagePath)) {
    New-Item -Path $edgeNewTabPagePath -Force
}

# Define the value for the PasswordManagerEnabled policy (0 = Always disabled, 1 = Always enabled)
$PasswordManagerEnabledValue = 0  # Change to 0 to always disable, or 1 to always enable

# Create or modify the DWORD value for the PasswordManagerEnabled policy
Set-ItemProperty -Path $edgePolicyBaseRegPath -Name "PasswordManagerEnabled" -Value $PasswordManagerEnabledValue -Force

Write-Host "Configuring Microsoft Edge password saving policy..."

# Set the homepage and new tab page URLs
Set-ItemProperty -Path $edgeRegPath -Name '1' -Value $homepageURL -Force
Set-ItemProperty -Path $edgeNewTabPagePath -Name 'NewTabPageLocation' -Value $newTabURL -Force

Write-Host "Configuring homepage and new tab page in Microsoft Edge completed."

# Create the "Main" key under the policy path if it doesn't exist
$edgeMainRegPath = Join-Path $edgePolicyBaseRegPath "Main"
if (-not (Test-Path $edgeMainRegPath)) {
    New-Item -Path $edgeMainRegPath -Force
}

# Set "FormSuggest" to "no" in the registry
$edgeFormSuggestPath = Join-Path $edgeMainRegPath "FormSuggest"
if (-not (Test-Path $edgeFormSuggestPath)) {
    New-Item -Path $edgeFormSuggestPath -Force
}
Set-ItemProperty -Path $edgeFormSuggestPath -Value "no" -Name "(Default)" -Force
Write-Host "Set FormSuggest Passwords to 'no' in the registry."

# Additional settings
$additionalRegPath = Join-Path $edgePolicyBaseRegPath "Recommended"

# Create the recommended key if it doesn't exist
if (-not (Test-Path $additionalRegPath)) {
    New-Item -Path $additionalRegPath -Force
}

# Set additional registry values
Set-ItemProperty -Path $additionalRegPath -Name "ShowHomeButton" -Value 0x00000001 -Force
Set-ItemProperty -Path $additionalRegPath -Name "HomepageLocation" -Value $homepageURL -Force
Set-ItemProperty -Path $additionalRegPath -Name "NewTabPageLocation" -Value $newTabURL -Force
Set-ItemProperty -Path $additionalRegPath -Name "RestoreOnStartup" -Value 0x00000004 -Force

# Set DefaultSearchProvider values
$defaultSearchProviderRegPath = Join-Path $edgePolicyBaseRegPath "Recommended"
Set-ItemProperty -Path $defaultSearchProviderRegPath -Name "DefaultSearchProviderName" -Value "Google" -Force
Set-ItemProperty -Path $defaultSearchProviderRegPath -Name "DefaultSearchProviderSearchURL" -Value "{google:baseURL}search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}ie={inputEncoding}" -Force
Set-ItemProperty -Path $defaultSearchProviderRegPath -Name "DefaultSearchProviderEnabled" -Value 0x00000001 -Force
Set-ItemProperty -Path $defaultSearchProviderRegPath -Name "DefaultSearchProviderSuggestURL" -Value "{google:baseURL}complete/search?output=chrome&q={searchTerms}" -Force
Set-ItemProperty -Path $defaultSearchProviderRegPath -Name "DefaultSearchProviderImageURL" -Value "{google:baseURL}searchbyimage/upload" -Force
Set-ItemProperty -Path $defaultSearchProviderRegPath -Name "DefaultSearchProviderImageURLPostParams" -Value "encoded_image={google:imageThumbnail},image_url={google:imageURL},sbisrc={google:imageSearchSource},original_width={google:imageOriginalWidth},original_height={google:imageOriginalHeight}" -Force

# Set additional registry values for DefaultSearchProvider
Set-ItemProperty -Path $edgePolicyBaseRegPath -Name "DefaultSearchProviderEnabled" -Value 0x00000001 -Force
Set-ItemProperty -Path $edgePolicyBaseRegPath -Name "DefaultSearchProviderSearchURL" -Value "{google:baseURL}search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}ie={inputEncoding}" -Force
Set-ItemProperty -Path $edgePolicyBaseRegPath -Name "DefaultSearchProviderName" -Value "Google-Policy-Locked" -Force


# Define the registry key path
$registryPath = "HKLM:\Software\Policies\Microsoft\Edge"

# Check if the registry path exists, and create it if it doesn't
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}

# Set the value to disable translation prompts for all websites
Set-ItemProperty -Path $registryPath -Name "GlobalBlockTranslation" -Value 1 -Type DWord

# Define the registry key for TranslateEnabled
$translateEnabledRegistryPath = "$registryPath"
$translateEnabledName = "TranslateEnabled"
$translateEnabledValue = 0

# Create or modify the DWORD value for TranslateEnabled
Set-ItemProperty -Path $translateEnabledRegistryPath -Name $translateEnabledName -Value $translateEnabledValue -Type DWord

Write-Host "Translation prompts disabled for all websites."

# Define the registry key paths for form suggestions in Microsoft Edge
$edgeUserSettingsKeyPath = "HKLM:\Software\Microsoft\Edge\Main"
$edgeFormSuggestEmailKeyPath = "$edgeUserSettingsKeyPath\FormSuggest Passwords"
$edgeFormSuggestUserNameKeyPath = "$edgeUserSettingsKeyPath\FormSuggest Passwords Username"

# Create the necessary registry keys if they don't exist
if (-not (Test-Path $edgeFormSuggestEmailKeyPath)) {
    New-Item -Path $edgeFormSuggestEmailKeyPath -Force
}

if (-not (Test-Path $edgeFormSuggestUserNameKeyPath)) {
    New-Item -Path $edgeFormSuggestUserNameKeyPath -Force
}

# Disable email and username suggestions on forms
Set-ItemProperty -Path $edgeFormSuggestEmailKeyPath -Name "Enabled" -Value 0 -Force
Set-ItemProperty -Path $edgeFormSuggestUserNameKeyPath -Name "Enabled" -Value 0 -Force

# Define la ruta de la clave del registro
$registryPath = "HKLM:\SOFTWARE\Microsoft\Edge\Main"

# Desactiva la función de autocompletado de información básica
Set-ItemProperty -Path $registryPath -Name "AutoFillBasicInfo" -Value 0

# Desactiva la función de autocompletado de números de teléfono
Set-ItemProperty -Path $registryPath -Name "AutoFillPhoneNumbers" -Value 0

# Desactiva la función de autocompletado de direcciones de correo electrónico
Set-ItemProperty -Path $registryPath -Name "AutoFillEmailAddresses" -Value 0

# Desactiva la función de autocompletado de direcciones de envío
Set-ItemProperty -Path $registryPath -Name "AutoFillShippingAddresses" -Value 0
