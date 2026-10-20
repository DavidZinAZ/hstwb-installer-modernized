$ErrorActionPreference='Stop'
$repo=Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $repo 'desktop/games-library.psm1') -Force
$root=Join-Path $repo ('.output/desktop-games-test-'+[guid]::NewGuid().ToString('N'))
$packRoot=Join-Path $root 'user-packages/WHDLoad Packs'
$pack=Join-Path $packRoot 'EAB WHDLoad Games'
$null=New-Item -ItemType Directory -Path (Join-Path $pack 'nested') -Force
'SYS:Games' | Set-Content (Join-Path $pack '_installdir')
Copy-Item (Join-Path $repo 'user-packages/WHDLoad Packs/build_install_entries.ps1') (Join-Path $packRoot 'build_install_entries.ps1')
function Assert($ok,$message){if(!$ok){throw $message}}
$rows=@(GetDesktopGamePacks $root)
Assert ($rows.Count -eq 1 -and $rows[0].Archives -eq 0 -and $rows[0].Status -eq 'Empty') 'Empty packs not reported.'
$blocked=$false;try{BuildDesktopGameLists $root | Out-Null}catch{$blocked=$true};Assert $blocked 'Empty build should be rejected.'
foreach($name in @('Example_v1.0.lha','ExampleDemo_v2.0.zip','Magazine_v1.0.lzx')){[IO.File]::WriteAllBytes((Join-Path $pack ('nested/'+$name)),[byte[]](1,2,3))}
$before=@{};Get-ChildItem (Join-Path $pack 'nested') -File | ForEach-Object {$before[$_.Name]=(Get-FileHash $_.FullName).Hash}
$rows=@(GetDesktopGamePacks $root)
Assert ($rows[0].Archives -eq 3 -and $rows[0].Status -eq 'Build lists first') 'Nested archives not detected.'
$backup=BuildDesktopGameLists $root
$rows=@(GetDesktopGamePacks $root)
Assert ($rows[0].Status -eq 'Ready' -and $rows[0].Listed -eq 3) 'Builder did not produce ready installation lists.'
$backup=BuildDesktopGameLists $root
Assert (Test-Path -LiteralPath (Join-Path $backup 'EAB WHDLoad Games/_install')) 'Previous generated lists were not backed up.'
Get-ChildItem (Join-Path $pack 'nested') -File | ForEach-Object {Assert ((Get-FileHash $_.FullName).Hash -eq $before[$_.Name]) 'Builder changed an archive.'}
[IO.File]::WriteAllBytes((Join-Path $pack 'nested/Added_v1.0.lha'),[byte[]](1,2))
$rows=@(GetDesktopGamePacks $root)
Assert ($rows[0].Status -eq 'Lists need rebuilding') 'Changed archive inventory was not detected.'
Write-Host 'PASS: game pack inventory, nested archive counts, empty-build protection, real list generation, backups, unchanged archives and stale-list detection.'

# The library can live outside the checkout, and defaults must respect saved settings.
$external=Join-Path $root 'external/user-packages/WHDLoad Packs';$externalPack=Join-Path $external 'EAB WHDLoad Games'
$null=New-Item -ItemType Directory $externalPack -Force
'DH1:ExternalGames' | Set-Content (Join-Path $externalPack '_installdir')
[IO.File]::WriteAllBytes((Join-Path $externalPack 'ExternalGame_v1.0.lha'),[byte[]](9,8,7))
# Never execute a builder supplied by the selected content library.
' throw "External builder must not run" ' | Set-Content (Join-Path $external 'build_install_entries.ps1')
$rows=@(GetDesktopGamePacks $root $external)
Assert ($rows.Count -eq 1 -and $rows[0].Archives -eq 1 -and $rows[0].Destination -eq 'DH1:ExternalGames') 'Explicit external folder ignored.'
$localHash=(Get-FileHash (Join-Path $pack 'entries-all.csv')).Hash
$null=BuildDesktopGameLists $root $external
$rows=@(GetDesktopGamePacks $root $external)
Assert ($rows[0].Status -eq 'Ready') 'External folder did not build using maintained builder.'
Assert ((Get-FileHash (Join-Path $pack 'entries-all.csv')).Hash -eq $localHash) 'External build changed checkout-local lists.'
$settings=Join-Path $root 'settings';$null=New-Item -ItemType Directory $settings -Force
[IO.File]::WriteAllText((Join-Path $settings 'hstwb-installer-settings.ini'),("[UserPackages]`r`nUserPackagesDir="+(Split-Path $external -Parent)))
$paths=GetDesktopLibraryPaths $root
Assert ($paths.UserPackagesFolder -eq (Join-Path $root 'user-packages') -and $paths.GamePacksFolder -eq $packRoot) 'Native settings overrode the installation-local default.'
$rows=@(GetDesktopGamePacks $root)
Assert ($rows.Count -gt 0) 'Local game default could not be scanned.'
@{UserPackagesFolder=(Split-Path $packRoot -Parent);GamePacksFolder=$packRoot} | ConvertTo-Json | Set-Content (Join-Path $settings 'desktop.json')
Assert ((GetDesktopLibraryPaths $root).GamePacksFolder -eq $packRoot) 'Saved desktop folder not restored.'
Assert ((GetDesktopLibraryPaths $root -IgnoreDesktop).GamePacksFolder -eq $external) 'Reset to installer settings ignored native folder.'
Write-Host 'PASS: explicit external folders, trusted builder selection, source isolation, native defaults, saved overrides and restoring installer defaults.'
Assert ((GetDesktopLibraryPaths $root $external).UserPackagesFolder -eq (Join-Path $root 'user-packages')) 'An external games folder changed the application library.'
@{UserPackagesFolder=(Split-Path $external -Parent);GamePacksFolder=$external} | ConvertTo-Json | Set-Content (Join-Path $settings 'desktop.json')
Assert ((GetDesktopLibraryPaths $root).UserPackagesFolder -eq (Join-Path $root 'user-packages')) 'An old desktop profile redirected the application library.'
$moved=Join-Path $root 'moved-installation';$null=New-Item -ItemType Directory (Join-Path $moved 'settings') -Force
Copy-Item (Join-Path $settings 'desktop.json') (Join-Path $moved 'settings/desktop.json')
Assert ((GetDesktopLibraryPaths $moved).UserPackagesFolder -eq (Join-Path $moved 'user-packages')) 'Moved installation reused the old user-package root.'
Write-Host 'PASS: stale native/profile roots and moved installations always use their own local user-packages.'
