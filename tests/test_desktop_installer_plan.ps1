$ErrorActionPreference='Stop'
$repo=Split-Path $PSScriptRoot -Parent
$fixture=Join-Path $repo ('.output/desktop-apply-test-'+[guid]::NewGuid().ToString('N'))
foreach($folder in @('settings','media/nested','image','packages','user-packages/Demo tools','data')){$null=New-Item -ItemType Directory (Join-Path $fixture $folder) -Force}
Import-Module (Join-Path $repo 'desktop/installer-plan.psm1') -Force
Import-Module (Join-Path $repo 'desktop/runtime-validation.psm1') -Force
Import-Module (Join-Path $repo 'modules/config.psm1') -Force
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Assert($ok,$message){if(!$ok){throw $message}}
$os=Join-Path $fixture 'media/nested/os.adf';$rom=Join-Path $fixture 'media/nested/rom.bin'
[IO.File]::WriteAllBytes($os,[byte[]](1,2,3,4));[IO.File]::WriteAllBytes($rom,[byte[]](5,6,7,8))
@([pscustomobject]@{Name='Synthetic OS';Required='True';Set='Amiga OS 3.1';AmigaOsVersion='3.1';Filename='os.adf';VolumeName='';Md5Hash=(Get-FileHash $os -Algorithm MD5).Hash}) | Export-Csv (Join-Path $fixture 'data/amiga-os-entries.csv') -Delimiter ';' -NoTypeInformation
@([pscustomobject]@{Name='Synthetic ROM';Required='True';Set='Test Kickstart';RunSupported='True';Model='A1200';AmigaOsVersionsSupported='3.1';Filename='rom.bin';Md5Hash=(Get-FileHash $rom -Algorithm MD5).Hash;Encrypted='No'}) | Export-Csv (Join-Path $fixture 'data/kickstart-entries.csv') -Delimiter ';' -NoTypeInformation
'{"harddrives":[{"type":"hdf","path":"disk.hdf","size":512}]}' | Set-Content (Join-Path $fixture 'image/hstwb-image.json')
[IO.File]::WriteAllBytes((Join-Path $fixture 'image/disk.hdf'),(New-Object byte[] 512))
[IO.File]::WriteAllBytes((Join-Path $fixture 'winuae.exe'),[byte[]](1,2))
@{Packages=@(@{Name='demo-package'},@{Name='helper-package'})} | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $fixture 'data/hstwb-packages.json')
@{Packages=@(@{Id='tools';Name='Demo tools';Directory='Demo tools';Components=@(@{Id='one'},@{Id='two'})})} | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $fixture 'data/user-package-updates.json')
'SYS:Tools' | Set-Content (Join-Path $fixture 'user-packages/Demo tools/_installdir')
'; synthetic installer, never executed' | Set-Content (Join-Path $fixture 'user-packages/Demo tools/_install')
function AddPackage($name,$dependencies,$content=@()){$path=Join-Path $fixture ('packages/'+$name+'.zip');$zip=[IO.Compression.ZipFile]::Open($path,'Create');try{$entry=$zip.CreateEntry('hstwb-package.json');$writer=New-Object IO.StreamWriter($entry.Open());try{$writer.Write((@{Name=$name;Version='1.0';AmigaOsVersions=@('3.1');ContentIds=@($content);Dependencies=@($dependencies);Assigns=@(@{Name='Work';Path='DH1:Apps'})} | ConvertTo-Json -Depth 6))}finally{$writer.Dispose()}}finally{$zip.Dispose()}}
AddPackage Demo @(@{Name='Helper'});AddPackage Helper @()
# Broken archives outside the selection must not block installation.
[IO.File]::WriteAllText((Join-Path $fixture 'packages/Unselected.zip'),'not a package')
$settingsFile=Join-Path $fixture 'settings/hstwb-installer-settings.ini'
$assignsFile=Join-Path $fixture 'settings/hstwb-installer-assigns.ini'
WriteIniFile $settingsFile @{Installer=@{Mode='Test'};Custom=@{Keep='Preserved'}}
WriteIniFile $assignsFile @{Global=@{SystemDir='DH0:';HstWBInstallerDir='DH1:Installer'}}
$before=(Get-FileHash $settingsFile).Hash;$assignsBefore=(Get-FileHash $assignsFile).Hash
$draft=[pscustomobject]@{OsSet='Amiga OS 3.1';TargetVersion='';KickstartSet='Test Kickstart';MediaFolder=(Join-Path $fixture 'media');ImageMode=1;ImageFolder=(Join-Path $fixture 'image');EmulatorFile=(Join-Path $fixture 'winuae.exe');Selected=@('package/demo-package','tools/one')}
$plan=NewDesktopInstallerPlan $fixture $draft
Assert (!$plan.Valid -and @($plan.Issues | Where-Object Message -like '*required by Demo*').Count) 'Missing dependency was not reported.'
Assert ((Get-FileHash $settingsFile).Hash -eq $before) 'Validation changed native settings.'
$draft.Selected=@('package/demo-package','package/helper-package','tools/one')
$plan=NewDesktopInstallerPlan $fixture $draft
if(!$plan.Valid){throw ('Valid fixture failed: '+($plan.Issues | ConvertTo-Json -Compress))}
Assert ($plan.Runtime.Packages.Count -eq 2) 'Unselected packages entered the runtime snapshot.'
AssertDesktopRuntimeValidation $plan.Runtime
# Public wrapper-only bundles must be supplied and verified before installation.
$userCatalogPath=Join-Path $fixture 'data/user-package-updates.json'
$userCatalogText=[IO.File]::ReadAllText($userCatalogPath)
$userCatalog=$userCatalogText | ConvertFrom-Json
$one=$userCatalog.Packages[0].Components[0]
$one | Add-Member NoteProperty UserSupplied $true
$one | Add-Member NoteProperty LocalFile 'app.lha'
$one | Add-Member NoteProperty Repository 'example/app'
$payloadPath=Join-Path $fixture 'user-packages/Demo tools/app.lha'
[IO.File]::WriteAllText($payloadPath,'supported archive fixture')
$one | Add-Member NoteProperty BaselineSha256 (Get-FileHash $payloadPath).Hash
$userCatalog | ConvertTo-Json -Depth 8 | Set-Content $userCatalogPath
Assert ((NewDesktopInstallerPlan $fixture $draft).Valid) 'Verified user-supplied archive rejected.'
[IO.File]::AppendAllText($payloadPath,'modified')
Assert (!(NewDesktopInstallerPlan $fixture $draft).Valid) 'Modified user-supplied archive accepted.'
[IO.File]::Delete($payloadPath)
$missing=NewDesktopInstallerPlan $fixture $draft
Assert (!$missing.Valid -and @($missing.Issues | Where-Object Message -like '*Download app.lha*').Count) 'Missing user-supplied archive not reported.'
[IO.File]::WriteAllText($userCatalogPath,$userCatalogText)
# Public wrapper-only bundles must be supplied and verified before installation.
$userCatalogPath=Join-Path $fixture 'data/user-package-updates.json'
$userCatalogText=[IO.File]::ReadAllText($userCatalogPath)
$userCatalog=$userCatalogText | ConvertFrom-Json
$one=$userCatalog.Packages[0].Components[0]
$one | Add-Member NoteProperty UserSupplied $true
$one | Add-Member NoteProperty LocalFile 'app.lha'
$one | Add-Member NoteProperty Repository 'example/app'
$payloadPath=Join-Path $fixture 'user-packages/Demo tools/app.lha'
[IO.File]::WriteAllText($payloadPath,'supported archive fixture')
$one | Add-Member NoteProperty BaselineSha256 (Get-FileHash $payloadPath).Hash
$userCatalog | ConvertTo-Json -Depth 8 | Set-Content $userCatalogPath
Assert ((NewDesktopInstallerPlan $fixture $draft).Valid) 'Verified user-supplied archive rejected.'
[IO.File]::AppendAllText($payloadPath,'modified')
Assert (!(NewDesktopInstallerPlan $fixture $draft).Valid) 'Modified user-supplied archive accepted.'
[IO.File]::Delete($payloadPath)
$missing=NewDesktopInstallerPlan $fixture $draft
Assert (!$missing.Valid -and @($missing.Issues | Where-Object Message -like '*Download app.lha*').Count) 'Missing user-supplied archive not reported.'
[IO.File]::WriteAllText($userCatalogPath,$userCatalogText)
$stampFile=Get-Item -LiteralPath $os;$originalTime=$stampFile.LastWriteTimeUtc
$stampFile.LastWriteTimeUtc=$originalTime.AddSeconds(5)
$changedRejected=$false;try{AssertDesktopRuntimeValidation $plan.Runtime}catch{$changedRejected=$true}
$stampFile.LastWriteTimeUtc=$originalTime
Assert $changedRejected 'Changed validated media was accepted by the runtime handoff.'
Assert ($plan.UserPackageNames.Count -eq 1 -and $plan.UserPackageNames[0] -eq 'Demo tools') 'Component did not map to complete user package.'
Assert ($plan.Notes -match 'complete') 'Bundle scope was not explained.'
$helperFile=Join-Path $fixture 'packages/Helper.zip'
[IO.File]::Delete($helperFile);AddPackage Helper @(@{Name='Demo'})
$cycle=NewDesktopInstallerPlan $fixture $draft
Assert (!$cycle.Valid -and @($cycle.Issues | Where-Object Message -like '*Circular*').Count) 'Circular dependency not detected.'
[IO.File]::Delete($helperFile);AddPackage Helper @() @('shared-desktop')
$demoFile=Join-Path $fixture 'packages/Demo.zip'
[IO.File]::Delete($demoFile);AddPackage Demo @(@{Name='Helper'}) @('shared-desktop')
$conflict=NewDesktopInstallerPlan $fixture $draft
Assert (!$conflict.Valid -and @($conflict.Issues | Where-Object Message -like '*Conflicting content*').Count) 'Conflicting desktop content not detected.'
[IO.File]::Delete($helperFile);AddPackage Helper @()
[IO.File]::Delete($demoFile);AddPackage Demo @(@{Name='Helper'})
$plan=NewDesktopInstallerPlan $fixture $draft
$stale=$plan.Token
Add-Content $settingsFile "`r`n[Other]`r`nChanged=Yes"
$blocked=$false;try{SaveDesktopInstallerPlan $plan $stale | Out-Null}catch{$blocked=$true}
Assert $blocked 'Concurrent native settings change was overwritten.'
$plan=NewDesktopInstallerPlan $fixture $draft
$beforeApply=[IO.File]::ReadAllBytes($settingsFile)
$backup=SaveDesktopInstallerPlan $plan $plan.Token
$written=ReadIniFile $settingsFile;$assigns=ReadIniFile $assignsFile
Assert ($written.Installer.Mode -eq 'Install' -and $written.Custom.Keep -eq 'Preserved' -and $written.Other.Changed -eq 'Yes') 'Apply lost unrelated settings.'
Assert ($written.Packages.InstallPackage1 -eq 'Demo' -and $written.Packages.InstallPackage2 -eq 'Helper') 'Native package selections incorrect.'
Assert ($written.UserPackages.InstallUserPackage1 -eq 'Demo tools') 'Native user-package selection incorrect.'
Assert ($assigns.Demo.Work -eq 'DH1:Apps') 'Default package assigns not generated.'
Assert ([Convert]::ToBase64String([IO.File]::ReadAllBytes((Join-Path $backup 'hstwb-installer-settings.ini'))) -eq [Convert]::ToBase64String($beforeApply)) 'Backup did not preserve original settings.'
Assert ((Get-FileHash (Join-Path $backup 'hstwb-installer-assigns.ini')).Hash -eq $assignsBefore) 'Backup did not preserve assigns.'
# If the second file cannot be replaced, the first file must be restored.
$plan=NewDesktopInstallerPlan $fixture $draft
$originalSettings=(Get-FileHash $settingsFile).Hash;$originalAssigns=(Get-FileHash $assignsFile).Hash
$lock=[IO.File]::Open($assignsFile,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::Read)
$blocked=$false
try{try{SaveDesktopInstallerPlan $plan $plan.Token | Out-Null}catch{$blocked=$true}}finally{$lock.Dispose()}
Assert ($blocked -and (Get-FileHash $settingsFile).Hash -eq $originalSettings -and (Get-FileHash $assignsFile).Hash -eq $originalAssigns) 'Two-file apply did not roll back after a locked assigns file.'
$after=(Get-FileHash $settingsFile).Hash
$draft.MediaFolder=Join-Path $fixture 'absent'
$bad=NewDesktopInstallerPlan $fixture $draft
Assert (!$bad.Valid) 'Absent media accepted.'
$blocked=$false;try{SaveDesktopInstallerPlan $bad $bad.Token | Out-Null}catch{$blocked=$true}
Assert ($blocked -and (Get-FileHash $settingsFile).Hash -eq $after) 'Failed validation changed settings.'
Write-Host 'PASS: native plan validates dependencies/media, maps complete bundles, preserves unrelated settings and assigns, backs up originals, and rejects stale or invalid applies.'

# WHDLoad bundle choices must be validated and mapped to the native user-package name.
$draft.MediaFolder=Join-Path $fixture 'media'
$gameRoot=Join-Path $fixture 'user-packages/WHDLoad Packs';$gameFolder=Join-Path $gameRoot 'EAB WHDLoad Games'
$null=New-Item -ItemType Directory -Path $gameFolder -Force
foreach($file in @('_install','_installdir','build_install_entries.ps1')){Copy-Item (Join-Path $repo ('user-packages/WHDLoad Packs/'+$file)) (Join-Path $gameRoot $file)}
'WHDLoad:Games' | Set-Content (Join-Path $gameFolder '_installdir')
[IO.File]::WriteAllBytes((Join-Path $gameFolder 'Sample_v1.0.lha'),[byte[]](1,2,3))
Import-Module (Join-Path $repo 'desktop/games-library.psm1') -Force
$draft.Selected+=@('gamepack/whdload-packs')
$missingLists=NewDesktopInstallerPlan $fixture $draft
Assert (!$missingLists.Valid -and @($missingLists.Issues | Where-Object Area -eq 'Games & Demos').Count) 'Unprepared game pack was accepted.'
$null=BuildDesktopGameLists $fixture
$gamePlan=NewDesktopInstallerPlan $fixture $draft
Assert ($gamePlan.Valid -and 'WHDLoad Packs' -in $gamePlan.UserPackageNames) 'Prepared game bundle did not map to native configuration.'
$externalParent=Join-Path $fixture 'external';$null=New-Item -ItemType Directory $externalParent -Force
Copy-Item -LiteralPath (Join-Path $fixture 'user-packages') -Destination (Join-Path $externalParent 'user-packages') -Recurse
$draft | Add-Member NoteProperty UserPackagesFolder (Join-Path $externalParent 'user-packages') -Force
$draft | Add-Member NoteProperty GamePacksFolder (Join-Path $externalParent 'user-packages/WHDLoad Packs') -Force
$externalPlan=NewDesktopInstallerPlan $fixture $draft
Assert ($externalPlan.Valid -and $externalPlan.Settings.UserPackages.UserPackagesDir -eq (Join-Path $fixture 'user-packages')) 'External game selection changed the local application library.'
# Exercise the GUI bridge contract across separate validation and apply processes.
$draft.MediaFolder=Join-Path $fixture 'media'
foreach($folder in @('desktop','modules')){$null=New-Item -ItemType Directory (Join-Path $fixture $folder) -Force}
foreach($file in @('bridge.ps1','installer-plan.psm1','games-library.psm1','image-builder.psm1','runtime-validation.psm1')){Copy-Item (Join-Path $repo ('desktop/'+$file)) (Join-Path $fixture ('desktop/'+$file))}
foreach($file in @('config.psm1','data.psm1','amigaos-release.psm1','settings-profiles.psm1')){Copy-Item (Join-Path $repo ('modules/'+$file)) (Join-Path $fixture ('modules/'+$file))}
$request=Join-Path $fixture 'request.json'
$draftJson=$draft | ConvertTo-Json -Depth 8 -Compress
[IO.File]::WriteAllText($request,(ConvertTo-Json -InputObject @($draftJson)))
$output=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $fixture 'desktop/bridge.ps1') -Action ValidateInstaller -RequestFile $request
Assert ($LASTEXITCODE -eq 0) 'Native validation bridge failed.'
$response=ConvertFrom-Json ($output -join "`n")
Assert $response[0].Valid 'Native validation bridge rejected a valid draft.'
$request=Join-Path $fixture 'apply-request.json'
[IO.File]::WriteAllText($request,(ConvertTo-Json -InputObject @($draftJson,$response[0].Token)))
$output=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $fixture 'desktop/bridge.ps1') -Action ApplyInstaller -RequestFile $request
Assert ($LASTEXITCODE -eq 0) 'Native apply bridge rejected a validated token.'
$response=ConvertFrom-Json ($output -join "`n")
Assert (Test-Path -LiteralPath $response[0].Backup) 'Native apply bridge did not return its backup.'
Write-Host 'PASS: paired-file rollback and separate-process GUI validation/apply contract.'

# The installer may boot a supported ROM from a different detected set.
$romCatalog=Join-Path $fixture 'data/kickstart-entries.csv'
$romEntries=@(Import-Csv $romCatalog -Delimiter ';')
$selectedRom=$romEntries[0].PSObject.Copy();$selectedRom.Set='New install ROM';$selectedRom.Name='New install ROM';$selectedRom.RunSupported='False'
@($romEntries+$selectedRom) | Export-Csv $romCatalog -Delimiter ';' -NoTypeInformation
$draft.KickstartSet='New install ROM';$draft.ImageMode=0
$fallback=NewDesktopInstallerPlan $fixture $draft
Assert $fallback.Valid 'Existing image or supported boot-ROM fallback was rejected.'
Assert (@($fallback.Notes | Where-Object {$_ -like 'Installer boot ROM:*'}).Count -eq 1) 'Boot-ROM choice was not explained.'
# Fake engine verifies the run contract without modifying an image.
Copy-Item (Join-Path $repo 'desktop/installer-plan.psm1') (Join-Path $fixture 'desktop/installer-plan.psm1') -Force
$templates=Join-Path $fixture 'images';$null=New-Item -ItemType Directory $templates -Force
$template=Join-Path $templates 'test.zip';$zip=[IO.Compression.ZipFile]::Open($template,'Create')
try{foreach($file in @('hstwb-image.json','disk.hdf')){[IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip,(Join-Path $fixture ('image/'+$file)),$file) | Out-Null}}finally{$zip.Dispose()}
$draft | Add-Member NoteProperty CreateNewImage $true
$draft | Add-Member NoteProperty ImageTemplate $template
$draft | Add-Member NoteProperty NewImageFolder (Join-Path $draft.ImageFolder 'Install-test-one')
@'
param([string]$settingsDir,[switch]$Desktop,[hashtable]$DesktopValidation)
if(!$Desktop){throw 'Desktop engine mode missing'}
if(!$DesktopValidation -or $DesktopValidation.Packages.Count -ne 2){throw 'Selected validation snapshot was not passed to the engine'}
[IO.File]::WriteAllText((Join-Path $settingsDir 'fake-run-marker'),'started')
Write-Host 'Synthetic installation completed'
'@ | Set-Content (Join-Path $fixture 'run.ps1')
$draftJson=$draft | ConvertTo-Json -Depth 8 -Compress
[IO.File]::WriteAllText($request,(ConvertTo-Json -InputObject @($draftJson)))
$output=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $fixture 'desktop/bridge.ps1') -Action ValidateInstaller -RequestFile $request
Assert ($LASTEXITCODE -eq 0) 'Run validation failed'
$response=ConvertFrom-Json ($output -join "`n")
[IO.File]::WriteAllText($request,(ConvertTo-Json -InputObject @($draftJson,$response[0].Token)))
$output=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $fixture 'desktop/bridge.ps1') -Action RunInstaller -RequestFile $request
Assert ($LASTEXITCODE -eq 0) 'In-app run bridge failed'
$response=ConvertFrom-Json ($output -join "`n")
Assert ($response[0].Status -eq 'Completed' -and (Test-Path $response[0].Log) -and (Test-Path (Join-Path $response[0].RunSettingsDirectory 'fake-run-marker'))) 'Run result, log or engine invocation missing'
$runConfig=ReadIniFile (Join-Path $response[0].RunSettingsDirectory 'hstwb-installer-settings.ini')
Assert ((Get-Item -LiteralPath (Join-Path $runConfig.UserPackages.UserPackagesDir 'Demo tools')).Target -eq [IO.Path]::GetFullPath((Join-Path $fixture 'user-packages/Demo tools'))) 'Run library did not use the local application bundle.'
Assert ((Get-Item -LiteralPath (Join-Path $runConfig.UserPackages.UserPackagesDir 'WHDLoad Packs')).Target -eq [IO.Path]::GetFullPath($draft.GamePacksFolder)) 'Run library lost the external game selection.'
Assert ((ReadIniFile $settingsFile).UserPackages.UserPackagesDir -eq (Join-Path $fixture 'user-packages')) 'Run changed the permanent application-library root.'
Assert ($response[0].ImageFolder -eq $draft.NewImageFolder -and (Test-Path (Join-Path $draft.NewImageFolder 'disk.hdf'))) 'Fresh image was not created.'
Assert ((Get-Item (Join-Path $fixture 'image/disk.hdf')).Length -eq 512) 'Existing image changed.'
Write-Host 'PASS: boot-ROM fallback, existing image detection, and in-app run contract with a fake engine.'
'param([string]$settingsDir,[switch]$Desktop,[hashtable]$DesktopValidation); throw "Synthetic engine failure"' | Set-Content (Join-Path $fixture 'run.ps1')
$draft.NewImageFolder=Join-Path $draft.ImageFolder 'Install-test-two'
$draftJson=$draft | ConvertTo-Json -Depth 8 -Compress
[IO.File]::WriteAllText($request,(ConvertTo-Json -InputObject @($draftJson)))
$output=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $fixture 'desktop/bridge.ps1') -Action ValidateInstaller -RequestFile $request
$response=ConvertFrom-Json ($output -join "`n")
[IO.File]::WriteAllText($request,(ConvertTo-Json -InputObject @($draftJson,$response[0].Token)))
$priorPreference=$ErrorActionPreference;$ErrorActionPreference='Continue'
$output=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $fixture 'desktop/bridge.ps1') -Action RunInstaller -RequestFile $request 2>&1
$failedExit=$LASTEXITCODE;$ErrorActionPreference=$priorPreference
Assert ($failedExit -ne 0 -and ($output -join "`n") -match 'Installation failed') 'Failed engine reported a successful installation.'
Write-Host 'PASS: engine failure returns a failed run result.'
