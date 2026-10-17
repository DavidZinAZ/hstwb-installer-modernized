using module ./modules/packages.psm1
param([Parameter(Mandatory=$true)][string]$UpstreamZip)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $repo 'modules/data.psm1') -Force
Import-Module (Join-Path $repo 'modules/config.psm1') -Force
Import-Module (Join-Path $repo 'modules/package-catalog.psm1') -Force
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Assert($condition, $message) { if (!$condition) { throw $message } }
$root = Join-Path ([IO.Path]::GetTempPath()) ('hstwb-bcwb-' + [guid]::NewGuid().ToString('N'))
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
        foreach ($name in @('Install','Payload.zip','BCWB-User-Startup','Upstream-Startup-Sequence','Upstream-BCWB','SOURCE.txt','Adapter-ReadMe.txt')) {
            Assert ($null -ne $zip.GetEntry($name)) ('Missing adapter member: '+$name)
        }
        $reader = New-Object IO.StreamReader($zip.GetEntry('Install').Open())
        try { $script = $reader.ReadToEnd() } finally { $reader.Dispose() }
        Assert (!$script.Contains("`r")) 'Guest install script is not LF'
        $payloadFile = Join-Path $root 'payload-inspect.tmp'
        [IO.Compression.ZipFileExtensions]::ExtractToFile($zip.GetEntry('Payload.zip'), $payloadFile)
        $payload = [IO.Compression.ZipFile]::OpenRead($payloadFile)
        try {
            Assert (!$payload.GetEntry('S/Startup-sequence') -and !$payload.GetEntry('S/User-Startup')) 'Payload would replace selected OS startup'
            Assert ($payload.GetEntry('C/FBlit') -and $payload.GetEntry('C/FPPrefs')) 'Required desktop enhancements missing'
            Assert ($payload.Entries.Count -gt 3000) 'Incomplete desktop payload'
        } finally { $payload.Dispose() }
    } finally { $zip.Dispose() }
    Remove-Item -LiteralPath $payloadFile
    $manager.DownloadPackages(@($package), $false)
    Assert ($manager.DownloadedCount -eq 0 -and $manager.SkippedCount -eq 1) 'Current adapted package was downloaded again'
    $before = (Get-FileHash $result).Hash
    $bad = Join-Path $root 'wrong.tmp'; [IO.File]::WriteAllText($bad, 'wrong release')
    $client = [WebClient]::new()
    $rejected = $false
    try { $client.DownloadPackageFile('Bad upstream', ([uri]$bad).AbsoluteUri, $result, 'BestClassicWB-2.1.12', '2.1.12') } catch { $rejected=$true }
    Assert ($rejected -and (Get-FileHash $result).Hash -eq $before) 'Wrong upstream replaced the valid package'
    Write-Output 'PASS: real upstream conversion/download, catalog pin, package selection/filter/conflict metadata, preserved startup, repeat skip and invalid-upstream preservation.'
} finally {
    if (Test-Path $root) { Remove-Item -LiteralPath $root -Recurse -Force }
}
