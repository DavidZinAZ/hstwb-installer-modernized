$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $repo 'modules/settings-profiles.psm1') -Force
function Assert($condition, $message) { if (!$condition) { throw $message } }
$root = Join-Path $repo ('.output/profiles-test-' + [guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $root
$settings = @{
    Installer = @{ Mode = 'Install' }
    Image = @{ ImageDir = 'C:\Amiga images\A1200' }
    AmigaOs = @{ AmigaOsDir = 'Z:\disconnected'; AmigaOsSet = 'Amiga OS 3.2' }
    Kickstart = @{ KickstartSet = '3.2.3' }
    Packages = @{ InstallPackage1 = 'Example'; PackageFiltering = 'All' }
    UserPackages = @{ InstallUserPackage1 = 'KickSmash'; UserPackagesDir = 'C:\apps' }
    Emulator = @{ EmulatorFile = 'C:\WinUAE\winuae64.exe' }
    Custom = @{ Empty = ''; Unicode = 'Amiga café'; Optional = $null }
}
$hstwb = @{ Version = 'test'; Settings = $settings; Assigns = @{ Global = @{ SystemDir = 'DH0:' }; Example = @{ Work = 'DH1:My Apps' } } }
$path = Join-Path $root 'A1200.hstwb-profile.json'
WriteSettingsProfile $path $hstwb
$loaded = ReadSettingsProfile $path
Assert ($loaded.Settings.Image.ImageDir -eq $settings.Image.ImageDir) 'Paths did not round-trip'
Assert ($loaded.Assigns.Example.Work -eq 'DH1:My Apps') 'Package assigns were lost'
Assert ($loaded.Settings.Custom.ContainsKey('Optional')) 'Null value was lost'
Assert ($loaded.Settings.Custom.Empty -eq '') 'Empty setting was lost'
$hstwb.Settings.Installer.Mode = 'Test'
WriteSettingsProfile $path $hstwb
Assert ((ReadSettingsProfile $path).Settings.Installer.Mode -eq 'Test') 'Profile overwrite failed'
$before = [IO.File]::ReadAllText($path)
$hstwb.Settings.Custom.Invalid = @('not', 'INI')
$rejected = $false
try { WriteSettingsProfile $path $hstwb } catch { $rejected = $true }
Assert $rejected 'Invalid settings were accepted'
Assert ([IO.File]::ReadAllText($path) -eq $before) 'Failed save destroyed profile'
$hstwb.Settings.Custom.Remove('Invalid')
$bad = Join-Path $root 'bad.json'
foreach ($text in @('{broken', ($before.Replace('HstWB.SettingsProfile','Unknown')), ($before.Replace('"SchemaVersion":  1','"SchemaVersion":  99').Replace('"SchemaVersion": 1','"SchemaVersion": 99')), '{"Format":"HstWB.SettingsProfile","SchemaVersion":1,"Settings":{},"Assigns":{}}')) {
    [IO.File]::WriteAllText($bad, $text)
    $rejected = $false
    try { $null = ReadSettingsProfile $bad } catch { $rejected = $true }
    Assert $rejected 'Malformed or unsupported profile accepted'
}
# Exercise the real load function with isolated discovery and persistence.
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile((Join-Path $repo 'setup.ps1'), [ref]$tokens, [ref]$errors)
Assert ($errors.Count -eq 0) 'Setup parse failed'
$fn = $ast.Find({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'LoadInstallerProfile'}, $true)
Invoke-Expression $fn.Extent.Text
function OpenFileDialog { return $script:chosenPath }
function Read-Host { return '' }
function ReadPackages { return @{ Example = @{} } }
function UpgradeSettings { }
function UpgradeAssigns { }
function UpdateAmigaOsEntries { }
function UpdateKickstartEntries { }
function DetectUserPackages { return @{ KickSmash = @{} } }
function FindEmulators { return @() }
function UpdateInstallPackages { }
function UpdateInstallUserPackages { }
function UpdateAssigns { }
function FindAmigaOsFiles($value) { $value.Settings.AmigaOs.AmigaOsDir = '' }
function FindKickstartFiles { }
function UiAmigaOsSetInfo { }
function UiKickstartSetInfo { }
function Save($value) { $script:savedMode = $value.Settings.Installer.Mode }
$hstwb.Paths = @{ SettingsDir = $root; PackagesPath = $root }
$hstwb.UI = @{ AmigaOs = @{}; Kickstart = @{} }
$script:chosenPath = $path
$hstwb.Settings.Installer.Mode = 'Install'
LoadInstallerProfile $hstwb
Assert ($hstwb.Settings.Installer.Mode -eq 'Test' -and $script:savedMode -eq 'Test') 'Loaded profile was not activated and saved'
Assert ($hstwb.Settings.AmigaOs.AmigaOsDir -eq 'Z:\disconnected') 'Disconnected media path was cleared'
$backups = @(Get-ChildItem (Join-Path $root 'profiles') -Filter '*.hstwb-profile.json')
Assert ($backups.Count -eq 1) 'Automatic backup missing'
Assert ((ReadSettingsProfile $backups[0].FullName).Settings.Installer.Mode -eq 'Install') 'Backup did not capture previous settings'
$script:chosenPath = $bad
LoadInstallerProfile $hstwb
Assert ($hstwb.Settings.Installer.Mode -eq 'Test') 'Invalid load changed active settings'
$script:chosenPath = $null
LoadInstallerProfile $hstwb
Assert ($hstwb.Settings.Installer.Mode -eq 'Test') 'Cancel changed settings'
$script:chosenPath = $path
$hstwb.Settings.Installer.Mode = 'Install'
function Save($value) {
    if ($value.Settings.Installer.Mode -eq 'Test') { throw 'Simulated save failure' }
    $script:savedMode = $value.Settings.Installer.Mode
}
LoadInstallerProfile $hstwb
Assert ($hstwb.Settings.Installer.Mode -eq 'Install' -and $script:savedMode -eq 'Install') 'Save failure did not preserve previous settings'
function UpdateAmigaOsEntries { throw 'Simulated refresh failure' }
LoadInstallerProfile $hstwb
Assert ($hstwb.Settings.Installer.Mode -eq 'Install') 'Refresh failure changed current settings'
Write-Host 'PASS: profile round-trip, overwrite, failed-save preservation, malformed/version rejection, load activation, backup, disconnected paths, cancellation and load rollback.'

# Run discovery, upgrades, package reconciliation and INI persistence for real.
foreach ($name in @('ReadPackages','UpgradeSettings','UpgradeAssigns','UpdateAmigaOsEntries','UpdateKickstartEntries','DetectUserPackages','FindEmulators','UpdateInstallPackages','UpdateInstallUserPackages','UpdateAssigns','FindAmigaOsFiles','FindKickstartFiles','UiAmigaOsSetInfo','UiKickstartSetInfo','Save')) {
    Remove-Item ('Function:' + $name)
}
Import-Module (Join-Path $repo 'modules/config.psm1') -Force
Import-Module (Join-Path $repo 'modules/data.psm1') -Force
$fn = $ast.Find({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Save'}, $true)
Invoke-Expression $fn.Extent.Text
$hstwb.Paths.SettingsFile = Join-Path $root 'active-settings.ini'
$hstwb.Paths.AssignsFile = Join-Path $root 'active-assigns.ini'
$hstwb.Paths.AmigaOsEntriesFile = Join-Path $repo 'data/amiga-os-entries.csv'
$hstwb.Paths.KickstartEntriesFile = Join-Path $repo 'data/kickstart-entries.csv'
$hstwb.Settings.UserPackages.UserPackagesDir = $root
$hstwb.Settings.Installer.Mode = 'Install'
$hstwb.Settings.AmigaOs.AmigaOsSet = 'Amiga OS 3.2'
$hstwb.Settings.Kickstart.KickstartSet = 'Kickstart 3.2.3'
$realPath = Join-Path $root 'real.hstwb-profile.json'
WriteSettingsProfile $realPath $hstwb
$hstwb.Settings.Installer.Mode = 'Test'
$script:chosenPath = $realPath
LoadInstallerProfile $hstwb
Assert ($hstwb.Settings.Installer.Mode -eq 'Install') 'Real profile load failed'
Assert ($hstwb.Settings.Image.ImageDir -eq 'C:\Amiga images\A1200') 'Upgrade cleared disconnected image path'
Assert ($hstwb.AmigaOsEntries.Count -gt 0 -and $hstwb.KickstartEntries.Count -gt 0) 'Media entries not refreshed'
Assert (!$hstwb.Settings.Packages.ContainsKey('InstallPackage1')) 'Unavailable package remained selected'
Assert ((ReadIniFile $hstwb.Paths.SettingsFile).Installer.Mode -eq 'Install') 'Active settings not persisted'
Assert ((ReadIniFile $hstwb.Paths.AssignsFile).Global.SystemDir -eq 'DH0:') 'Global assigns not persisted'
Write-Host 'PASS: real discovery, package reconciliation, UI refresh and active settings/assigns persistence.'
