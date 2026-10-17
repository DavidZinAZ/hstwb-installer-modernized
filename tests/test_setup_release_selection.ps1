$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $repo 'modules/amigaos-release.psm1') -Force
Import-Module (Join-Path $repo 'modules/config.psm1') -Force
$manifest = Get-Content (Join-Path $repo 'data/release-manifest.json') -Raw | ConvertFrom-Json
$entries = @(Import-Csv (Join-Path $repo 'data/amiga-os-entries.csv') -Delimiter ';')
# Synthetic detections exercise the real catalog without licensed payloads.
foreach ($entry in $entries) {
    $entry | Add-Member File 'synthetic.adf'
    $entry | Add-Member MatchType 'MD5'
}
function Assert($condition, $message) { if (!$condition) { throw $message } }
foreach ($version in @('3.2', '3.2.1', '3.2.2', '3.2.3')) {
    $plan = GetAmigaOs32InstallPlan $entries $version $manifest
    Assert ($plan.State.TargetVersion -eq $version) "Wrong target for $version"
    $updates = @($plan.Entries | Where-Object { $_.Filename -match '^amiga-os-(321|322|323)-' })
    if ($version -eq '3.2') { Assert ($updates.Count -eq 0) 'Base unexpectedly includes updates' }
    else {
        Assert ($updates.Count -gt 0) "No update media for $version"
        Assert (@($updates | Where-Object { !$_.Filename.StartsWith('amiga-os-' + $version.Replace('.', '') + '-') }).Count -eq 0) 'Unselected update leaked into plan'
        Assert ($plan.State.SourceVersion -eq '3.2') 'Fresh image source must be base 3.2'
    }
}
foreach ($version in @('3.2.2.1', '9.9')) {
    $rejected = $false
    try { $null = GetAmigaOs32InstallPlan $entries $version $manifest } catch { $rejected = $true }
    Assert $rejected "Unsafe/unknown target accepted: $version"
}
$incomplete = @($entries | Where-Object { $_.Filename -ne 'amiga-os-323-update.adf' })
$rejected = $false
try { $null = GetAmigaOs32InstallPlan $incomplete '3.2.3' $manifest } catch { $rejected = $true }
Assert $rejected 'Missing selected update accepted'
foreach ($disk in @('classes', 'extras', 'disk-doctor')) {
    $incomplete = @($entries | Where-Object { $_.Filename -ne "amiga-os-323-$disk.adf" })
    $rejected = $false
    try { $null = GetAmigaOs32InstallPlan $incomplete '3.2.3' $manifest } catch { $rejected = $true }
    Assert $rejected "Incomplete 3.2.3 companion media accepted: $disk"
}
$unverified = @($entries | ForEach-Object { $_.PSObject.Copy() })
foreach ($entry in $unverified) { if ($entry.Filename -eq 'amiga-os-323-update.adf') { $entry.MatchType = 'VolumeName' } }
$rejected = $false
try { $null = GetAmigaOs32InstallPlan $unverified '3.2.3' $manifest } catch { $rejected = $true }
Assert $rejected 'Unverified update accepted'

# Run the actual setup selector with only the interactive prompt replaced.
$tokens = $null; $parseErrors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $repo 'setup.ps1'), [ref]$tokens, [ref]$parseErrors)
Assert ($parseErrors.Count -eq 0) 'Setup parse errors'
foreach ($name in @('SelectAmigaOs32Version', 'Save')) {
    $fn = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $name }, $true)
    Invoke-Expression $fn.Extent.Text
}
function FindAmigaOsFiles($hstwb) { }
function EnterChoiceColor($title, $options) {
    Assert (@($options | Where-Object { $_.Value -eq '3.2.3' }).Count -eq 1) 'Setup did not offer 3.2.3'
    return $options | Where-Object { $_.Value -eq '3.2.3' }
}
$settingsDir = Join-Path ([IO.Path]::GetTempPath()) ('hstwb-setup-test-' + [guid]::NewGuid())
$null = New-Item -ItemType Directory $settingsDir
$hstwb = @{ Settings = @{ AmigaOs = @{ AmigaOsSet = 'Amiga OS 3.2' } }; AmigaOsEntries = $entries; Assigns = @{}; Paths = @{ SettingsFile = (Join-Path $settingsDir 'settings.ini'); AssignsFile = (Join-Path $settingsDir 'assigns.ini') } }
$hstwb.Paths.AmigaOsEntriesFile = Join-Path $repo 'data/amiga-os-entries.csv'
SelectAmigaOs32Version $hstwb
$saved = ReadIniFile $hstwb.Paths.SettingsFile
Assert ($saved.AmigaOs.TargetVersion -eq '3.2.3') 'Setup choice not persisted'
Assert ($saved.AmigaOs.AmigaOsSet -eq 'Amiga OS 3.2') 'Existing set model changed'
Write-Host 'PASS: release plans, missing/unsafe media, and setup selection/settings round-trip'
