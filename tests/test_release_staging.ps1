$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $repo 'tools/release-staging.psm1') -Force
function Assert($condition, $message) { if (!$condition) { throw $message } }
$destination = Join-Path $repo ('.output/release-staging-test-' + [guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $destination
$ignored = Join-Path $repo ('docs/local-only-' + [guid]::NewGuid().ToString('N') + '.log')
try {
    [IO.File]::WriteAllText($ignored, 'Synthetic local-only content. Must not ship.')
    CopyTrackedReleaseTree $repo 'Docs' $destination
    Assert (!(Test-Path -LiteralPath (Join-Path $destination ('docs/' + [IO.Path]::GetFileName($ignored))))) 'Ignored local file leaked into release'
    $document = 'docs/additional-user-packages.md'
    Assert ((Get-FileHash (Join-Path $repo $document)).Hash -eq (Get-FileHash (Join-Path $destination $document)).Hash) 'Tracked document missing or changed'
    CopyTrackedReleaseTree $repo 'setup.*' $destination
    Assert (Test-Path -LiteralPath (Join-Path $destination 'setup.ps1')) 'Root entrypoint was not staged'
} finally { [IO.File]::Delete($ignored) }
$tokens = $null; $errors = $null
$null = [Management.Automation.Language.Parser]::ParseFile((Join-Path $repo 'tools/build_release.ps1'), [ref]$tokens, [ref]$errors)
Assert ($errors.Count -eq 0) 'Release builder parse errors'
$builder = [IO.File]::ReadAllText((Join-Path $repo 'tools/build_release.ps1'))
Assert ($builder -notmatch "-replace 'Copyright") 'Release builder rewrites original copyright'
foreach ($name in @('hstwb-installer.wxs','hstwb-installer_packages.wxs')) {
    [xml]$wix = [IO.File]::ReadAllText((Join-Path $repo ('wix/' + $name)))
    $manager = New-Object Xml.XmlNamespaceManager($wix.NameTable)
    $manager.AddNamespace('w', 'http://schemas.microsoft.com/wix/2006/wi')
    Assert ($null -ne $wix.SelectSingleNode('//w:Directory[@Id="DocsComponentDir"]', $manager)) 'MSI docs directory missing'
    Assert ($null -ne $wix.SelectSingleNode('//w:ComponentGroupRef[@Id="DocsComponentGroup"]', $manager)) 'MSI docs feature missing'
    foreach ($document in @('ACKNOWLEDGMENTS.md','CHANGELOG.md','THIRD_PARTY_NOTICES.md','CONTRIBUTING.md','SECURITY.md')) {
        Assert ($null -ne $wix.SelectSingleNode(('//w:File[@Source="' + $document + '"]'), $manager)) "MSI notice missing: $document"
    }
}
Write-Host 'PASS: ignored local content excluded, tracked files preserved, entrypoints staged, copyright preserved, ZIP/MSI notice wiring and script/XML parsing.'
