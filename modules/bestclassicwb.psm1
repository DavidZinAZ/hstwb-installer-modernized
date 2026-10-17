# Convert the reviewed upstream release into the normal HstWB package format.
# The upstream archive is downloaded on demand; no upstream payload is redistributed here.
function ConvertBestClassicWbArchive($path, $version)
{
    if ($version -ne '2.1.12') { throw 'BestClassicWB adapter requires reviewed release 2.1.12.' }
    $expected = 'e6bc79df8caf0c1fe559d34bc05a626f29b833e9aaa7e710e65514b56352e5d9'
    if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $expected) {
        throw 'BestClassicWB upstream archive differs from the reviewed release. Existing package retained.'
    }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    Add-Type -AssemblyName System.IO.Compression
    $sourceDir = Join-Path (Split-Path $PSScriptRoot -Parent) 'data/package-adapters/BestClassicWB'
    $converted = $path + '.adapted'
    $payload = $path + '.payload'
    try {
        $upstream = [IO.Compression.ZipFile]::OpenRead($path)
        try {
            foreach ($required in @('src/BestClassicWB/BCWB', 'src/BestClassicWB/BCWB_Files/S/Startup-sequence', 'src/BestClassicWB/BCWB_Files/S/User-Startup', 'src/BestClassicWB/BCWB.readme.txt')) {
                if (!$upstream.GetEntry($required)) { throw ('Missing BestClassicWB member: ' + $required) }
            }
            $payloadZip = [IO.Compression.ZipFile]::Open($payload, 'Create')
            try {
                $prefix = 'src/BestClassicWB/BCWB_Files/'
                foreach ($entry in $upstream.Entries) {
                    if (!$entry.FullName.StartsWith($prefix, [StringComparison]::Ordinal)) { continue }
                    $relative = $entry.FullName.Substring($prefix.Length)
                    if (!$relative -or $relative.EndsWith('/')) { continue }
                    if ($relative -match '(^|/)[.][.](/|$)|[:\\]' -or $relative.StartsWith('/')) { throw 'Unsafe BestClassicWB member path.' }
                    if ($relative -ieq 'S/Startup-Sequence' -or $relative -ieq 'S/User-Startup') { continue }
                    $target = $payloadZip.CreateEntry($relative)
                    $target.ExternalAttributes = $entry.ExternalAttributes
                    $inputStream = $entry.Open(); $outputStream = $target.Open()
                    try { $inputStream.CopyTo($outputStream) } finally { $inputStream.Dispose(); $outputStream.Dispose() }
                }
            } finally { $payloadZip.Dispose() }
            $result = [IO.Compression.ZipFile]::Open($converted, 'Create')
            try {
                foreach ($file in @('hstwb-package.json', 'Install', 'Adapter-ReadMe.txt')) {
                    $null = [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($result, (Join-Path $sourceDir $file), $file)
                }
                $null = [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($result, $payload, 'Payload.zip')
                $members = @{
                    'BCWB-User-Startup' = 'src/BestClassicWB/BCWB_Files/S/User-Startup'
                    'Upstream-Startup-Sequence' = 'src/BestClassicWB/BCWB_Files/S/Startup-sequence'
                    'Upstream-BCWB' = 'src/BestClassicWB/BCWB'
                    'BCWB.readme.txt' = 'src/BestClassicWB/BCWB.readme.txt'
                }
                foreach ($name in $members.Keys) {
                    $target = $result.CreateEntry($name)
                    $inputStream = $upstream.GetEntry($members[$name]).Open(); $outputStream = $target.Open()
                    try { $inputStream.CopyTo($outputStream) } finally { $inputStream.Dispose(); $outputStream.Dispose() }
                }
                $target = $result.CreateEntry('SOURCE.txt')
                $writer = New-Object IO.StreamWriter($target.Open())
                try { $writer.WriteLine("BestClassicWB 2.1.12 by kouts/samplist`nhttps://github.com/kouts/best-classic-wb`nRelease: https://github.com/kouts/best-classic-wb/releases/tag/v2.1.12`nUpstream SHA256: $expected`nCredits: Bloodwych (ClassicWB), Gulliver (BestWB), KKR75 (icons). All bundled notices remain in Payload.zip.") } finally { $writer.Dispose() }
            } finally { $result.Dispose() }
        } finally { $upstream.Dispose() }
        # Replace only the temporary download; WebClient validates and publishes it atomically.
        [IO.File]::Copy($converted, $path, $true)
    }
    finally {
        foreach ($temporary in @($converted, $payload)) {
            if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force }
        }
    }
}
