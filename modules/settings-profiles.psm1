# Profiles contain configuration data only, never executable PowerShell.
function ConvertProfileSections($value)
{
    if ($value -isnot [System.Management.Automation.PSCustomObject]) { throw 'Profile configuration must contain INI sections.' }
    $result = @{}
    foreach ($section in $value.PSObject.Properties) {
        if (!$section.Name -or $section.Name -match '[\r\n\[\]]') { throw 'Invalid profile section name.' }
        if ($section.Value -isnot [System.Management.Automation.PSCustomObject]) { throw 'Invalid profile section.' }
        $entries = @{}
        foreach ($entry in $section.Value.PSObject.Properties) {
            if ($null -ne $entry.Value -and $entry.Value -isnot [string]) { throw 'Profile values must be strings.' }
            if ($section.Name -match '[\r\n\[\]]' -or $entry.Name -match '[\r\n=]' -or $entry.Value -match '[\r\n]') { throw 'Invalid INI data in profile.' }
            $entries[$entry.Name] = $entry.Value
        }
        $result[$section.Name] = $entries
    }
    return $result
}

function ReadSettingsProfile([string]$path)
{
    $profile = [IO.File]::ReadAllText($path) | ConvertFrom-Json -ErrorAction Stop
    if ($profile.Format -ne 'HstWB.SettingsProfile' -or $profile.SchemaVersion -ne 1) { throw 'Unsupported settings profile format or version.' }
    $settings = ConvertProfileSections $profile.Settings
    $assigns = ConvertProfileSections $profile.Assigns
    foreach ($section in @('Installer','Image','AmigaOs','Kickstart','Packages','UserPackages','Emulator')) {
        if (!$settings.ContainsKey($section)) { throw "Profile is missing settings section '$section'." }
    }
    if (!$assigns.ContainsKey('Global')) { throw 'Profile is missing global assigns.' }
    if ($settings.Installer.Mode -notin @('Install','BuildSelfInstall','BuildPackageInstallation','BuildUserPackageInstallation','Test')) { throw 'Invalid installer mode in profile.' }
    return @{ Settings = $settings; Assigns = $assigns }
}

function WriteSettingsProfile([string]$path, $hstwb)
{
    $json = [ordered]@{
        Format = 'HstWB.SettingsProfile'
        SchemaVersion = 1
        InstallerVersion = $hstwb.Version
        SavedAt = (Get-Date).ToUniversalTime().ToString('o')
        Settings = $hstwb.Settings
        Assigns = $hstwb.Assigns
    } | ConvertTo-Json -Depth 10
    $temporary = $path + '.' + [guid]::NewGuid().ToString('N') + '.tmp'
    try {
        [IO.File]::WriteAllText($temporary, $json, (New-Object Text.UTF8Encoding($false)))
        $null = ReadSettingsProfile $temporary
        if ([IO.File]::Exists($path)) {
            # Windows PowerShell converts a null backup name to an invalid empty path.
            $previous = $temporary + '.previous'
            [IO.File]::Replace($temporary, $path, $previous)
            [IO.File]::Delete($previous)
        }
        else { [IO.File]::Move($temporary, $path) }
    } finally {
        if ([IO.File]::Exists($temporary)) { [IO.File]::Delete($temporary) }
    }
}

Export-ModuleMember -Function ReadSettingsProfile, WriteSettingsProfile
