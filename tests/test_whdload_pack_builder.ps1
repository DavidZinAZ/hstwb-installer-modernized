$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
# Guard the native startup setting that previously stalled archive operations.
Get-ChildItem (Join-Path $repo 'amiga') -Recurse -File | Where-Object { $_.Directory.Name -eq 'S' -or $_.FullName -match '[\\/]S[\\/]' } | ForEach-Object {
    $content = [IO.File]::ReadAllText($_.FullName)
    if ($content -match '(?im)^\s*Resident\s+[^\r\n]*INSTALLDIR:C/LhA[^\r\n]*\bPURE\b') {
        throw ('Unsafe LhA PURE residency: ' + $_.Name)
    }
}
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('hstwb-pack-builder-' + [guid]::NewGuid().ToString('N'))
try {
    $pack = Join-Path $fixture 'WHDLoad Fixture'
    New-Item -ItemType Directory -Path $pack -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $pack '_installdir'), 'DH1:WHDLoad/Test')
    # The builder reads filenames, not archive payloads.
    foreach ($name in @('42Issue_v1.0_AGA.lha', 'Example_v1.0.lzx', 'ZipExample_v1.0.zip')) {
        [IO.File]::WriteAllBytes((Join-Path $pack $name), [byte[]]@())
    }
    & (Join-Path $repo 'user-packages/WHDLoad Packs/build_install_entries.ps1') $fixture
    $entries = @(Import-Csv (Join-Path $pack 'entries-all.csv') -Delimiter ';')
    if ($entries.Count -ne 3) { throw 'LHA, LZX and ZIP must all be discovered.' }
    if (($entries | Where-Object Name -match '\.(lha|lzx|zip)$').Count) { throw 'Archive suffix leaked into display names.' }
    foreach ($set in @('All', 'Best-Version', 'Best-Version-Lowmem')) {
        $dir = Join-Path $pack ('Install/' + $set)
        $scripts = @(Get-ChildItem $dir -File)
        $combined = ($scripts | Get-Content) -join "`n"
        foreach ($name in @('42Issue_v1.0_AGA.lha', 'Example_v1.0.lzx', 'ZipExample_v1.0.zip')) {
            if (!$combined.Contains($name)) { throw ('Missing archive in generated set: ' + $set + '/' + $name) }
        }
        foreach ($script in $scripts) {
            if ([IO.File]::ReadAllBytes($script.FullName) -contains 13) { throw 'Guest scripts must use LF line endings.' }
        }
    }
    Write-Output 'WHDLoad pack builder: all archive formats and three generated sets passed.'
}
finally {
    if (Test-Path $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
