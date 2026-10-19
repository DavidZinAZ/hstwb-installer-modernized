using module ./modules/packages.psm1
param([Parameter(Mandatory=$true)][string]$UpstreamZip)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $repo 'modules/data.psm1') -Force
Import-Module (Join-Path $repo 'modules/config.psm1') -Force
Import-Module (Join-Path $repo 'modules/package-catalog.psm1') -Force
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Assert($condition, $message) { if (!$condition) { throw $message } }
$outputRoot = Join-Path $repo '.output'
$null = New-Item -ItemType Directory -Path $outputRoot -Force
$root = Join-Path $outputRoot ('hstwb-bcwb-' + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path $root | Out-Null
    $catalog = Get-Content (Join-Path $repo 'data/hstwb-packages.json') -Raw | ConvertFrom-Json
    $package = $catalog.Packages | Where-Object Name -eq 'best-classic-wb'
    $refreshed = UpdateOfficialPackageCatalog ([pscustomobject]@{Packages=@($package)})
    Assert ($refreshed.Packages[0].Adapter -eq 'BestClassicWB-2.1.12') 'Catalog refresh lost adapter metadata'
    Assert ($refreshed.Packages[0].Releases.Count -eq 1) 'Unreviewed releases offered'
    $package.Releases[0].Url = ([uri](Resolve-Path $UpstreamZip).Path).AbsoluteUri
    $manager = [PackageManager]::new($root)
    $manager.DownloadPackages(@($package), $false)
    $detected = (ReadPackages $root)['bestclassicwb']
    Assert ($detected.Version -eq '2.1.12') 'Converted package not detected by normal selection flow'
    Assert ($detected.ContentIds -contains 'amigaos') 'Desktop conflict group missing'
    Assert ($detected.AmigaOsVersions -contains '3.2') 'OS filtering missing'
    # Exercise the same extraction and PACKAGEDIR execution wrapper used by Run.
    $tokens=$null; $errors=$null
    $ast=[Management.Automation.Language.Parser]::ParseFile((Join-Path $repo 'run.ps1'),[ref]$tokens,[ref]$errors)
    Assert ($errors.Count -eq 0) 'Run contains parse errors'
    foreach ($name in @('ExtractPackages','BuildInstallPackageScriptLines')) {
        $fn=$ast.Find({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $name},$true)
        if ($fn) { Invoke-Expression $fn.Extent.Text }
    }
    $stage=Join-Path $root 'stage'; New-Item -ItemType Directory $stage | Out-Null
    $hstwb=@{Packages=@{'bestclassicwb'=$detected};Settings=@{Installer=@{Mode='Install'};AmigaOs=@{InstallAmigaOs='Yes'}};Assigns=@{Global=@{SYSTEMDIR='DH0:'}}}
    ExtractPackages $hstwb @('bestclassicwb') $stage
    Assert (Test-Path (Join-Path $stage ($detected.Id+'/Install'))) 'Normal run did not stage the adapter'
    $wrapper=@(BuildInstallPackageScriptLines $hstwb @('bestclassicwb'))[0].Lines -join "`n"
    Assert ($wrapper.Contains('execute "PACKAGEDIR:Install"')) 'Normal package execution wrapper missing'
    $result = Join-Path $root 'BestClassicWB.2.1.12.zip'
    $zip = [IO.Compression.ZipFile]::OpenRead($result)
    try {
        foreach ($name in @('Install','Payload.zip','BCWB-User-Startup','Upstream-Startup-Sequence','Upstream-BCWB','SOURCE.txt','Adapter-ReadMe.txt','Repair-Executable-Protection')) {
            Assert ($null -ne $zip.GetEntry($name)) ('Missing adapter member: '+$name)
        }
        $reader = New-Object IO.StreamReader($zip.GetEntry('Install').Open())
        try { $script = $reader.ReadToEnd() } finally { $reader.Dispose() }
        Assert (!$script.Contains("`r")) 'Guest install script is not LF'
        Assert ($script.Contains('Execute PACKAGEDIR:Repair-Executable-Protection SYSTEMDIR:')) 'Installer does not restore executable permissions'
        $reader = New-Object IO.StreamReader($zip.GetEntry('Repair-Executable-Protection').Open())
        try { $protection = $reader.ReadToEnd() } finally { $reader.Dispose() }
        Assert (!$protection.Contains("`r")) 'Repair script is not LF'
        $payloadFile = Join-Path $root 'payload-inspect.tmp'
        [IO.Compression.ZipFileExtensions]::ExtractToFile($zip.GetEntry('Payload.zip'), $payloadFile)
        $payload = [IO.Compression.ZipFile]::OpenRead($payloadFile)
        try {
            Assert (!$payload.GetEntry('S/Startup-sequence') -and !$payload.GetEntry('S/User-Startup')) 'Payload would replace selected OS startup'
            Assert ($payload.GetEntry('C/FBlit') -and $payload.GetEntry('C/FPPrefs')) 'Required desktop enhancements missing'
            $hunkCount = 0
            foreach ($entry in $payload.Entries) {
                if ($entry.Length -lt 4) { continue }
                $stream = $entry.Open()
                try { $magic = New-Object byte[] 4; $read = $stream.Read($magic, 0, 4) } finally { $stream.Dispose() }
                if ($read -eq 4 -and [BitConverter]::ToString($magic) -eq '00-00-03-F3') {
                    $hunkCount++
                    Assert ($protection.Contains(('Protect "{TARGET}' + $entry.FullName + '" +e'))) ('Missing executable permission repair: ' + $entry.FullName)
                }
            }
            Assert ($hunkCount -gt 100) 'Executable coverage unexpectedly incomplete'
            Assert (!$protection.Contains('WBDock.config" +e')) 'Configuration files should not be marked executable'
            Assert ($payload.Entries.Count -gt 3000) 'Incomplete desktop payload'
            $original = [IO.Compression.ZipFile]::OpenRead((Resolve-Path $UpstreamZip).Path)
            try {
                $prefix = 'src/BestClassicWB/BCWB_Files/'
                $retained = 0
                foreach ($entry in $original.Entries) {
                    if (!$entry.FullName.StartsWith($prefix) -or $entry.FullName.EndsWith('/')) { continue }
                    $relative = $entry.FullName.Substring($prefix.Length)
                    if ($relative -ieq 'S/Startup-Sequence' -or $relative -ieq 'S/User-Startup') { continue }
                    $copy = $payload.GetEntry($relative)
                    Assert ($null -ne $copy) ('Payload file removed: ' + $relative)
                    $hash = [Security.Cryptography.SHA256]::Create()
                    $sourceStream = $entry.Open(); $copyStream = $copy.Open()
                    try {
                        Assert ([BitConverter]::ToString($hash.ComputeHash($sourceStream)) -eq [BitConverter]::ToString($hash.ComputeHash($copyStream))) ('Payload bytes changed: ' + $relative)
                    } finally { $sourceStream.Dispose(); $copyStream.Dispose(); $hash.Dispose() }
                    $retained++
                }
                Assert ($retained -eq $payload.Entries.Count) 'Unexpected payload additions'
            } finally { $original.Dispose() }
        } finally { $payload.Dispose() }
    } finally { $zip.Dispose() }
    Remove-Item -LiteralPath $payloadFile
    $manager.DownloadPackages(@($package), $false)
    Assert ($manager.DownloadedCount -eq 0 -and $manager.SkippedCount -eq 1) 'Current adapted package was downloaded again'
    # The upstream version is unchanged, so an older adapter must still refresh.
    $legacyRoot = Join-Path $root 'legacy'
    $null = New-Item -ItemType Directory -Path $legacyRoot
    $legacyPath = Join-Path $legacyRoot 'BestClassicWB.2.1.12.zip'
    $legacy = [IO.Compression.ZipFile]::Open($legacyPath, 'Create')
    try {
        $metadata = @{ Name='BestClassicWB'; Version='2.1.12'; AdapterRevision=1 }
        $writer = New-Object IO.StreamWriter($legacy.CreateEntry('hstwb-package.json').Open())
        try { $writer.Write(($metadata | ConvertTo-Json -Depth 6)) } finally { $writer.Dispose() }
    } finally { $legacy.Dispose() }
    $legacyManager = [PackageManager]::new($legacyRoot)
    $legacyManager.DownloadPackages(@($package), $false)
    Assert ($legacyManager.DownloadedCount -eq 1) 'Old adapter revision was incorrectly skipped'
    $before = (Get-FileHash $result).Hash
    $bad = Join-Path $root 'wrong.tmp'; [IO.File]::WriteAllText($bad, 'wrong release')
    $client = [WebClient]::new()
    $rejected = $false
    try { $client.DownloadPackageFile('Bad upstream', ([uri]$bad).AbsoluteUri, $result, 'BestClassicWB-2.1.12', '2.1.12') } catch { $rejected=$true }
    Assert ($rejected -and (Get-FileHash $result).Hash -eq $before) 'Wrong upstream replaced the valid package'
    Write-Output 'PASS: real upstream conversion, full payload byte preservation, HUNK permission coverage, old adapter refresh, catalog/filter/conflict metadata, preserved startup, repeat skip and invalid-upstream preservation.'
} finally {
    if (Test-Path $root) {
        if (![IO.Path]::GetFullPath($root).StartsWith(([IO.Path]::GetFullPath($outputRoot) + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe test cleanup path.' }
        Remove-Item -LiteralPath $root -Recurse -Force
    }
}
