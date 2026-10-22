param([string]$Python)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$fixture = Join-Path $repo ('.output/pack-assigns-' + [guid]::NewGuid().ToString('N'))
$packs = @{'Games'='Games'; 'Games Beta'='GamesBeta'; 'Demos'='Demos'; 'Demos Beta'='DemosBeta'; 'Magazines'='Magazines'}
try {
    foreach ($name in $packs.Keys) {
        $dir = Join-Path $fixture ('EAB WHDLoad ' + $name)
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        [IO.File]::WriteAllText((Join-Path $dir '_installdir'), "DH1:My Packs/$($packs[$name])`r`n")
        [IO.File]::WriteAllBytes((Join-Path $dir 'Example_v1.0.lha'), [byte[]]@())
    }
    $builders = @('powershell')
    if ($Python) { $builders += 'python' }
    foreach ($builder in $builders) {
        if ($builder -eq 'python') {
            & $Python (Join-Path $repo 'user-packages/WHDLoad Packs/build_install_entries.py') $fixture
            if ($LASTEXITCODE) { throw 'Python builder failed' }
        } else {
            & (Join-Path $repo 'user-packages/WHDLoad Packs/build_install_entries.ps1') $fixture
        }
        foreach ($name in $packs.Keys) {
            $kind = $packs[$name]
            $file = Join-Path $fixture ('EAB WHDLoad ' + $name + '/_install')
            $text = [IO.File]::ReadAllText($file)
            if ($text.Contains("`r")) { throw 'Guest script contains CR' }
            if (!$text.Contains(('set INSTALLDIR "DH1:My Packs/' + $kind + '"'))) { throw 'Destination was not trimmed' }
            $blocks = [regex]::Matches($text, '(?s)  IF "\$confirm" EQ "1"\n(.*?)    execute "USERPACKAGEDIR:[^\n]+/Install-Entries"')
            if ($blocks.Count -ne 3) { throw 'All three entry sets must configure assigns only after installation confirmation' }
            foreach ($block in $blocks) {
                foreach ($line in @(
                    'MakePath "$INSTALLDIR" >NIL:',
                    ('Echo "Assign >NIL: A-' + $kind + ': *"$INSTALLDIR*"" >SYSTEMDIR:S/WHDLoad-Packs-' + $kind),
                    'IF NOT EXISTS SYSTEMDIR:S/User-Startup',
                    ('Search >NIL: SYSTEMDIR:S/User-Startup "Execute S:WHDLoad-Packs-' + $kind + '" QUIET'),
                    ('IF WARN' + "`n" + '      Echo "" >>SYSTEMDIR:S/User-Startup' + "`n" + '      Echo "Execute S:WHDLoad-Packs-' + $kind + '" >>SYSTEMDIR:S/User-Startup'),
                    ('Execute SYSTEMDIR:S/WHDLoad-Packs-' + $kind)
                )) {
                    if (!$block.Value.Contains($line)) { throw "Missing $kind assign behavior: $line" }
                }
            }
        }
    }
    Write-Output 'PASS: pack assigns for Games, GamesBeta, Demos, DemosBeta and Magazines, all three entry sets.'
} finally {
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
