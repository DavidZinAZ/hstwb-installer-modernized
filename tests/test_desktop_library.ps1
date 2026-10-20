$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$repo=Split-Path $PSScriptRoot -Parent
$fixture=Join-Path $repo ('.output/desktop-library-test-'+[guid]::NewGuid().ToString('N'))
foreach($folder in @('desktop','modules','data','packages','settings','sources','user-packages/Demo')){$null=New-Item -ItemType Directory -Path (Join-Path $fixture $folder) -Force}
Copy-Item (Join-Path $repo 'desktop/bridge.ps1') (Join-Path $fixture 'desktop/bridge.ps1')
Copy-Item (Join-Path $repo 'desktop/games-library.psm1') (Join-Path $fixture 'desktop/games-library.psm1')
foreach($module in @('packages.psm1','bestclassicwb.psm1','user-package-updates.psm1')){Copy-Item (Join-Path $repo ('modules/'+$module)) (Join-Path $fixture ('modules/'+$module))}
# Local release provider avoids network access while exercising the real downloader.
'function UpdateOfficialPackageCatalog($catalog){return $catalog}' | Set-Content (Join-Path $fixture 'modules/package-catalog.psm1')
$sourceDir=Join-Path $fixture 'sources/payload';$null=New-Item -ItemType Directory $sourceDir
'{"Name":"Demo","Version":"2.0"}' | Set-Content (Join-Path $sourceDir 'hstwb-package.json')
$sourceZip=Join-Path $fixture 'sources/Demo.2.0.zip'
[IO.Compression.ZipFile]::CreateFromDirectory($sourceDir,$sourceZip)
$packages=@{Packages=@(@{Name='demo-package';Repository='example/demo';Releases=@(@{Version='2.0';Prerelease='False';FileName='Demo.2.0.zip';Url=([uri]$sourceZip).AbsoluteUri})},@{Name='other-package';Repository='example/other';Releases=@()})}
$packages | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $fixture 'data/hstwb-packages.json')
@{FormatVersion=1;Packages=@(@{Id='demo';Directory='Demo';Name='Demo';Components=@(@{Id='app';Name='Demo';Version='1.0';Provider='Manual';Reason='Manual test'})})} | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $fixture 'data/user-package-updates.json')
'SYS:Utilities/Demo' | Set-Content (Join-Path $fixture 'user-packages/Demo/_installdir')
@{Components=@(@{Id='app';Version='3.0'})} | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $fixture 'user-packages/Demo/_update-state.json')
$request=Join-Path $fixture 'request.json';'["package/demo-package"]' | Set-Content $request
function InvokeBridge($action){
 $output=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $fixture 'desktop/bridge.ps1') -Action $action -RequestFile $request
 if($LASTEXITCODE -ne 0){throw "Bridge failed: $action"}
 return ConvertFrom-Json ($output -join "`n")
}
$result=InvokeBridge DownloadPackages
if(@($result).Count -ne 1 -or $result.Id -ne 'package/demo-package' -or $result.Version -ne '2.0' -or $result.Status -ne 'Downloaded'){throw 'Download did not preserve scope or report installed version.'}
$result=InvokeBridge CheckPackages
if($result.Version -ne '2.0'){throw 'Cached refresh lost downloaded version.'}
# An existing valid version must be reused even if the source and GitHub API are unavailable.
$archive=Join-Path $fixture 'packages/Demo.2.0.zip'
$hash=(Get-FileHash $archive).Hash;$modified=(Get-Item $archive).LastWriteTimeUtc
[IO.File]::Delete($sourceZip)
[IO.File]::WriteAllText((Join-Path $fixture 'modules/package-catalog.psm1'),'function UpdateOfficialPackageCatalog($catalog){throw "API rate limit exceeded`nAt fake.ps1:99`nCategoryInfo: diagnostic"}')
$result=InvokeBridge CheckPackages
if($result.Status -ne 'Check unavailable' -or $result.Version -ne '2.0' -or $result.Details -notmatch '^GitHub request limit' -or $result.Details -match '[\r\n]|CategoryInfo'){throw 'Rate limit lost local version or leaked diagnostics.'}
$result=InvokeBridge DownloadPackages
if($result.Status -ne 'Already downloaded' -or $result.Version -ne '2.0'){throw 'Existing archive was not reused while source was unavailable.'}
if((Get-FileHash $archive).Hash -ne $hash -or (Get-Item $archive).LastWriteTimeUtc -ne $modified){throw 'Existing package was rewritten.'}
[IO.File]::WriteAllText((Join-Path $fixture 'modules/package-catalog.psm1'),'function UpdateOfficialPackageCatalog($catalog){return $catalog}')
Write-Host 'PASS: repeated downloads reuse the existing archive without source/API access; rate limits preserve local versions and readable errors.'
# Catalog reload should prefer the locally saved application version.
$output=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $fixture 'desktop/bridge.ps1') -Action Catalog
if($LASTEXITCODE -ne 0){throw 'Catalog reload failed.'}
$rows=ConvertFrom-Json ($output -join "`n")
if(($rows | Where-Object Id -eq 'demo/app').Destination -ne 'SYS:Utilities/Demo'){throw 'Amiga destination not loaded.'}
if(($rows | Where-Object Id -eq 'demo/app').Version -ne '3.0'){throw 'Catalog reverted to baseline application version.'}
# A broken newer download must retain the old valid archive and version.
$cache=Join-Path $fixture 'settings/desktop-package-catalog.json'
$catalog=Get-Content $cache -Raw | ConvertFrom-Json
$p=$catalog.Packages | Where-Object Name -eq 'demo-package'
$p.Releases=@([pscustomobject]@{Version='4.0';Prerelease='False';FileName='Demo.4.0.zip';Url=([uri](Join-Path $fixture 'absent.zip')).AbsoluteUri})+@($p.Releases)
$catalog | ConvertTo-Json -Depth 10 | Set-Content $cache
$result=InvokeBridge DownloadPackages
if($result.Status -ne 'Download failed' -or $result.Version -ne '2.0' -or !$result.Details){throw 'Failed download lost existing version or error details.'}
Write-Host 'PASS: scoped in-app downloads, refreshed versions, saved application versions, catalog cache replacement, and failed-download recovery.'

foreach($module in @('config.psm1','settings-profiles.psm1')){Copy-Item (Join-Path $repo ('modules/'+$module)) (Join-Path $fixture ('modules/'+$module))}
$ini=Join-Path $fixture 'settings/existing.ini'
$settings=@{Installer=@{Mode='Install'};AmigaOs=@{AmigaOsSet='Amiga OS 3.2';TargetVersion='3.2.3';AmigaOsDir='Z:\OfflineMedia'};Kickstart=@{KickstartSet='Kickstart Original'};Image=@{ImageDir='Z:\MyAmiga'};Emulator=@{EmulatorFile='Z:\WinUAE\winuae64.exe'};Packages=@{InstallPackage1='Demo'};UserPackages=@{InstallUserPackage1='Demo'}}
$lines=@();foreach($section in $settings.Keys){$lines+='['+$section+']';foreach($key in $settings[$section].Keys){$lines+=$key+'='+$settings[$section][$key]}}
[IO.File]::WriteAllText($ini,($lines -join "`r`n"))
$before=(Get-FileHash $ini).Hash
$request=Join-Path $fixture 'request-ini.json';[IO.File]::WriteAllText($request,(ConvertTo-Json -InputObject @($ini)))
$loaded=InvokeBridge LoadSettings
if($loaded.TargetVersion -ne '3.2.3' -or $loaded.MediaFolder -ne 'Z:\OfflineMedia' -or 'package/demo-package' -notin $loaded.Selected -or 'demo/app' -notin $loaded.Selected){throw 'Existing INI import lost target, offline paths, or package selections.'}
if((Get-FileHash $ini).Hash -ne $before){throw 'Import changed existing settings.'}
$profile=Join-Path $fixture 'settings/existing.hstwb-profile.json'
@{Format='HstWB.SettingsProfile';SchemaVersion=1;Settings=$settings;Assigns=@{Global=@{}}} | ConvertTo-Json -Depth 8 | Set-Content $profile
$request=Join-Path $fixture 'request-profile.json';[IO.File]::WriteAllText($request,(ConvertTo-Json -InputObject @($profile)))
$loaded=InvokeBridge LoadSettings
if($loaded.TargetVersion -ne '3.2.3' -or 'demo/app' -notin $loaded.Selected){throw 'Existing installer profile import failed.'}
Write-Host 'PASS: Amiga destinations, existing INI and installer-profile import, offline paths, and preserved original settings.'
# Catalog versions and destinations must follow the selected external user-package library.
$externalUsers=Join-Path $fixture 'external/user-packages';$externalDemo=Join-Path $externalUsers 'Demo'
$null=New-Item -ItemType Directory $externalDemo -Force
'SYS:ExternalTools' | Set-Content (Join-Path $externalDemo '_installdir')
@{Components=@(@{Id='app';Version='8.0'})} | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $externalDemo '_update-state.json')
[IO.File]::WriteAllText((Join-Path $fixture 'settings/hstwb-installer-settings.ini'),("[UserPackages]`r`nUserPackagesDir="+$externalUsers))
$output=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $fixture 'desktop/bridge.ps1') -Action Catalog
if($LASTEXITCODE -ne 0){throw 'External user-library catalog failed.'}
$rows=ConvertFrom-Json ($output -join "`n")
$demo=$rows | Where-Object Id -eq 'demo/app'
if($demo.Version -ne '8.0' -or $demo.Destination -ne 'SYS:ExternalTools' -or $demo.Directory -ne $externalDemo){throw 'User-package catalog mixed libraries.'}
Write-Host 'PASS: user-package versions and destinations follow the configured external library.'# Offline scans must verify local bytes without calling release providers.
Import-Module (Join-Path $repo 'modules/user-package-updates.psm1') -Force
& (Get-Module user-package-updates) {
 param($fixture)
 function GetAvailableUserPackageRelease {throw 'Offline scan contacted a release provider'}
 $directory=Join-Path $fixture 'external/user-packages/Demo'
 $payload=Join-Path $directory 'app.lha';[IO.File]::WriteAllText($payload,'local archive')
 $hash=(Get-FileHash -LiteralPath $payload).Hash
 @{Components=@(@{Id='app';Version='8.0';Sha256=$hash})} | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $directory '_update-state.json')
 $catalog=@([pscustomobject]@{Id='demo';Directory='Demo';Components=@([pscustomobject]@{Id='app';LocalFile='app.lha';Provider='GitHub';Version='1.0'})})
 $result=@(GetUserPackageUpdateResults (Split-Path $directory) $catalog -LocalOnly)[0]
 if($result.Status -ne 'Local version verified' -or $result.LocalVersion -ne '8.0' -or $result.Release){throw 'Offline payload scan failed'}
 [IO.File]::WriteAllText($payload,'changed')
 $result=@(GetUserPackageUpdateResults (Split-Path $directory) $catalog -LocalOnly)[0]
 if($result.Status -ne 'Local version unverified'){throw 'Changed payload was accepted'}
} $fixture
Write-Host 'PASS: offline local scans verify payload hashes and never query release providers.'
# Optional emulator directories are absent in a clean installation.
$output=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $fixture 'desktop/bridge.ps1') -Action Emulators
if($LASTEXITCODE -ne 0){throw 'Emulator discovery failed when optional folders were absent.'}
Write-Host 'PASS: emulator discovery tolerates missing optional directories.'
