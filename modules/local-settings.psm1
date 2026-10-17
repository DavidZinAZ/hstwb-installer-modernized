function ImportLegacyInstallerSettings($destination, $source)
{
    $names = @('hstwb-installer-settings.ini', 'hstwb-installer-assigns.ini')
    foreach ($name in $names) {
        if (Test-Path -LiteralPath (Join-Path $destination $name)) { throw 'Local settings already exist; import was cancelled.' }
        if (!(Test-Path -LiteralPath (Join-Path $source $name) -PathType Leaf)) { throw 'Previous settings and assigns must both exist.' }
    }
    $null = New-Item -ItemType Directory -Path $destination -Force
    $stage = Join-Path $destination ('.import-' + [guid]::NewGuid().ToString('N'))
    $null = New-Item -ItemType Directory -Path $stage
    $created = New-Object 'System.Collections.Generic.List[string]'
    try {
        foreach ($name in $names) { Copy-Item -LiteralPath (Join-Path $source $name) -Destination (Join-Path $stage $name) -ErrorAction Stop }
        foreach ($name in $names) {
            $target = Join-Path $destination $name
            [IO.File]::Move((Join-Path $stage $name), $target)
            $created.Add($target)
        }
    } catch {
        foreach ($path in $created) { [IO.File]::Delete($path) }
        throw
    } finally {
        foreach ($name in $names) { $path=Join-Path $stage $name; if(Test-Path -LiteralPath $path){[IO.File]::Delete($path)} }
        [IO.Directory]::Delete($stage, $false)
    }
}
