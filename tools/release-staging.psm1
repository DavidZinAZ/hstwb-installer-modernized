# Stage tracked source files only; ignored settings, backups and local payloads
# must never enter a release just because they live under a component directory.
function CopyTrackedReleaseTree($root, $component, $destination)
{
    $files = @(& git -C $root ls-files -- (':(icase)' + $component))
    if ($LASTEXITCODE -ne 0) { throw 'Git tracked-file listing failed; release staging stopped.' }
    foreach ($file in $files) {
        $source = Join-Path $root $file
        if (!(Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing tracked release file: $file" }
        $target = Join-Path $destination $file
        $null = New-Item -ItemType Directory -Path (Split-Path $target -Parent) -Force -ErrorAction Stop
        Copy-Item -LiteralPath $source -Destination $target -ErrorAction Stop
    }
}

Export-ModuleMember -Function CopyTrackedReleaseTree
