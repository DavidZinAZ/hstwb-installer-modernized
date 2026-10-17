# Plan an explicitly selected release using the existing, detected media catalog.
function GetAmigaOs32InstallPlan($entries, $targetVersion, $manifest)
{
    $target = @($manifest.Releases | Where-Object { $_.Version -eq $targetVersion }) | Select-Object -First 1
    if (!$target) { throw "Unknown Amiga OS release '$targetVersion'." }
    if ($target.ReleaseType -ne 'base' -and @($target.AcceptedSources) -notcontains '3.2')
    {
        throw "Amiga OS $targetVersion requires an installed source system and cannot be selected for a fresh image."
    }

    $baseEntries = @($entries | Where-Object { $_.Set -eq 'Amiga OS 3.2' -and $_.Filename -match '^amiga-os-32-[^.]+\.adf$' })
    foreach ($required in @($baseEntries | Where-Object { $_.Required -eq 'True' } | Group-Object Name))
    {
        if (!@($required.Group | Where-Object { $_.File -and $_.MatchType -eq 'MD5' }).Count)
        { throw "Required Amiga OS 3.2 disk missing or unverified: $($required.Name)." }
    }
    if (!@($baseEntries | Where-Object { $_.Required -eq 'True' }).Count)
    { throw 'Amiga OS 3.2 base media catalog is missing.' }

    $selectedEntries = $baseEntries
    if ($targetVersion -ne '3.2')
    {
        $updatePrefix = 'amiga-os-' + $targetVersion.Replace('.', '') + '-'
        $updateEntries = @($entries | Where-Object { $_.Set -eq 'Amiga OS 3.2' -and $_.Filename.StartsWith($updatePrefix) -and $_.File -and $_.MatchType -eq 'MD5' })
        $requiredNames = @($updatePrefix + 'update.adf')
        if ($targetVersion -eq '3.2.1') { $requiredNames += $updatePrefix + 'classes.adf' }
        if ($targetVersion -eq '3.2.3') {
            $requiredNames += @('classes', 'extras', 'disk-doctor') | ForEach-Object { $updatePrefix + $_ + '.adf' }
        }
        foreach ($name in $requiredNames)
        {
            if (!@($updateEntries | Where-Object { $_.Filename -eq $name }).Count)
            { throw "Required Amiga OS $targetVersion disk missing or unverified: $name." }
        }
        $selectedEntries += $updateEntries
    }

    return @{
        Entries = @($selectedEntries)
        State = [ordered]@{
            FormatVersion = '1.0'
            Family = 'AmigaOS 3.2.x'
            TargetVersion = [string]$target.Version
            SourceVersion = $(if ($target.ReleaseType -eq 'base') { $null } else { '3.2' })
            MediaSequence = $(if ($target.ReleaseType -eq 'base') { @('3.2') } else { @('3.2', [string]$target.Version) })
            InstallEntryPoint = [string]$target.InstallEntryPoint
            KickstartVersion = [string]$target.RomSet.KickstartVersion
        }
    }
}
