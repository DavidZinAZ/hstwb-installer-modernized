$ErrorActionPreference='Stop'
$repo=Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $repo 'modules/user-package-updates.psm1') -Force
Import-Module (Join-Path $repo 'modules/config.psm1') -Force
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression
function Assert($ok,$message){if(!$ok){throw $message}}
Assert ((CompareSoftwareVersion '47.11.2' '47.1') -eq 1) 'Numeric versions compared as decimals'
Assert ((CompareSoftwareVersion '1.5n' '1.5k') -eq 1) 'Letter release ordering wrong'
Assert ((CompareSoftwareVersion '2.0rc2' '2.0') -eq -1) 'Prerelease ordered after stable'
Assert ((CompareSoftwareVersion '1.0.0-rc1' '1.0.0') -eq -1) 'Hyphenated prerelease ordering wrong'
Assert ((CompareSoftwareVersion ('1.04'+[char]0xdf) '1.04beta1') -eq 0) 'Author beta notation not recognized'
$rejected=$false;try{CompareSoftwareVersion '1.38 / 39.15' '1.38'}catch{$rejected=$true}
Assert $rejected 'Ambiguous upstream version silently normalized'
$root=Join-Path $repo ('.output/user-updates-test-'+[guid]::NewGuid().ToString('N'))
$package=Join-Path $root 'Synthetic';New-Item -ItemType Directory $package -Force | Out-Null
foreach($name in @('_install','_installdir','custom.prefs')){[IO.File]::WriteAllText((Join-Path $package $name),'preserve me')}
function MakeLha($path,$member,$payload) {
 [byte[]]$name=[Text.Encoding]::ASCII.GetBytes($member);[byte[]]$body=[Text.Encoding]::ASCII.GetBytes($payload)
 [byte[]]$header=New-Object byte[] (24+$name.Length)
 $header[0]=$header.Length-2;[Array]::Copy([Text.Encoding]::ASCII.GetBytes('-lh0-'),0,$header,2,5)
 [Array]::Copy([BitConverter]::GetBytes([uint32]$body.Length),0,$header,7,4)
 [Array]::Copy([BitConverter]::GetBytes([uint32]$body.Length),0,$header,11,4)
 $header[19]=32;$header[21]=$name.Length;[Array]::Copy($name,0,$header,22,$name.Length)
 $sum=0;for($i=2;$i -lt $header.Length;$i++){$sum+=$header[$i]};$header[1]=$sum -band 255
 [IO.File]::WriteAllBytes($path,($header+$body+[byte]0))
}
$old=Join-Path $package 'app.lha';$new=Join-Path $root 'new.lha'
MakeLha $old 'App/Tool' 'version1';MakeLha $new 'App/Tool' 'version2'
$component=[pscustomobject]@{Id='app';Name='Synthetic app';LocalFile='app.lha';Version='1.0';BaselineSha256=(Get-FileHash $old).Hash;Provider='Aminet';AminetPath='test/synthetic';Extension='.lha';Mode='Archive';RequiredMembers=@('App/Tool')}
$catalog=@([pscustomobject]@{Id='synthetic';Directory='Synthetic';Name='Synthetic';PackageVersion='1.0.0';Components=@($component)})
$module=Get-Module user-package-updates
& $module {param($fixture) $script:Fixture=$fixture;$script:RemoteVersion='2.0';function script:GetUserPackageWebContent($url){return [pscustomobject]@{Content=('Version: '+$script:RemoteVersion+"`nArchitecture: m68k-amigaos`n")}};function script:SaveUserPackageDownload($url,$path){Copy-Item -LiteralPath $script:Fixture -Destination $path -ErrorAction Stop}} $new
$result=@(GetUserPackageUpdateResults $root $catalog)[0]
Assert ($result.Status -eq 'Update available' -and $result.Release.Version -eq '2.0') 'Source version not detected'
$backup=InstallUserPackageSourceUpdate $result
Assert (Test-Path -LiteralPath $backup) 'Previous package not preserved'
Assert ((Get-Content (Join-Path $package 'custom.prefs')) -eq 'preserve me') 'Custom package files lost'
Assert ((Get-Content (Join-Path $package '_install')) -eq 'preserve me') 'Installer unexpectedly rewritten'
$state=GetUserPackageLocalState $package
Assert ($state.Components[0].Version -eq '2.0' -and $state.PackageVersion -eq '1.0.1') 'Version metadata incorrect after update'
Assert ((@(GetUserPackageUpdateResults $root $catalog)[0]).Status -eq 'Current') 'Updated payload not recognized as current'
$current=@(GetUserPackageUpdateResults $root $catalog)[0]
$current.Status='Update available'
$rejected=$false;try{InstallUserPackageSourceUpdate $current}catch{$rejected=$true}
Assert $rejected 'Current version could be downloaded again from stale selection'
& $module {$script:RemoteVersion='1.0'}
Assert ((@(GetUserPackageUpdateResults $root $catalog)[0]).Status -eq 'Local version is newer') 'Locally newer payload offered a downgrade'
& $module {$script:RemoteVersion='3.0'}
$component | Add-Member AutoUpdate $false
Assert ((@(GetUserPackageUpdateResults $root $catalog)[0]).Status -eq 'Update available') 'Legacy review flag still blocks library update'
$hash=(Get-FileHash (Join-Path $package 'app.lha')).Hash
& $module {$script:RemoteVersion='3.0'}
$next=@(GetUserPackageUpdateResults $root $catalog)[0]
MakeLha $new 'Different/Tool' 'badlayout'
$rejected=$false;try{InstallUserPackageSourceUpdate $next}catch{$rejected=$true}
Assert $rejected 'Incompatible archive replaced package'
Assert ((Get-FileHash (Join-Path $package 'app.lha')).Hash -eq $hash) 'Rejected update changed original files'
MakeLha $new '../outside' 'badpath'
$rejected=$false;try{GetLhaArchiveMembers $new}catch{$rejected=$true}
Assert $rejected 'Archive traversal accepted'
# Actual bundled archives exercise level-0/1/2 and self-extracting headers without execution.
foreach($path in @('MMU Libs v47.1/MMULib.lha','IconLib v46.4.555/IconLib_46.4.lha','Archivers and unarchivers/lha.run')) {
 Assert (@(GetLhaArchiveMembers (Join-Path $repo ('user-packages/'+$path))).Count -gt 0) ('Bundled archive not recognized: '+$path)
}
$entries=GetUserPackageCatalog (Join-Path $repo 'data/user-package-updates.json')
foreach($entry in $entries){Assert (@($entry.Components | Group-Object Id | Where-Object Count -gt 1).Count -eq 0) ('Component IDs collide: '+$entry.Name)}
$directories=@(Get-ChildItem (Join-Path $repo 'user-packages') -Directory | Where-Object {Test-Path (Join-Path $_.FullName '_installdir')})
Assert ($entries.Count -eq $directories.Count) 'A bundled user package is missing from the catalog'
foreach($entry in $entries){Assert ($entry.PackageVersion -match '^\d+\.\d+\.\d+$') 'Non-numeric package revision';foreach($c in $entry.Components){if($c.Provider -ne 'Manual' -and !$c.UserSupplied){Assert (Test-Path (Join-Path (Join-Path $repo 'user-packages') ($entry.Directory+'/'+$c.LocalFile))) ('Catalog payload missing: '+$c.LocalFile)}}}
Write-Host 'PASS: source version comparison, verified update/backup, metadata, preserved customization, incompatible/traversal archive rejection, and catalog coverage'
foreach($entry in $entries){foreach($component in $entry.Components){
 if($component.Provider -eq 'Manual' -or !$component.BaselineSha256){continue}
 $payload=Join-Path (Join-Path $repo 'user-packages') ($entry.Directory+'/'+$component.LocalFile)
 if($component.UserSupplied -and !(Test-Path -LiteralPath $payload)){continue}
 Assert ((Get-FileHash -LiteralPath $payload -Algorithm SHA256).Hash -eq $component.BaselineSha256) ('Bundled payload differs from published version metadata: '+$entry.Name)
 if($component.Mode -eq 'Archive' -and $entry.Directory -in @('IconLib v46.4.555','MMU Libs v47.1','WHDLoad v18.8','iGame v2.0')){
  $members=@(GetLhaArchiveMembers $payload)
  foreach($required in $component.RequiredMembers){$required=$required.Replace('{root}',[string]$component.InstalledRoot);Assert ($required -in $members) ('Required bundled archive member missing: '+$entry.Name+' / '+$required)}
 }
}}
Write-Host 'PASS: committed bundle baselines match payload hashes and required archive members.'

# The legacy iGame selection must migrate too, preserving its local preferences.
$legacy=$entries | Where-Object Id -eq 'igame-v1-6a'
$modern=$entries | Where-Object Id -eq 'igame-v2-0'
$migrationRoot=Join-Path $root 'legacy-migration'
$null=New-Item -ItemType Directory -Path $migrationRoot
$legacyDir=Join-Path $migrationRoot $legacy.Directory
Copy-Item -LiteralPath (Join-Path (Join-Path $repo 'user-packages') $legacy.Directory) -Destination $legacyDir -Recurse
$prefs=(Get-FileHash (Join-Path $legacyDir 'IGAM.1.prefs')).Hash
Import-Module (Join-Path $repo 'modules/user-package-updates.psm1') -Force
& (Get-Module user-package-updates) {
 param($version,$download)
 $script:MigrationVersion=$version;$script:MigrationDownload=$download
 function script:GetAvailableUserPackageRelease($component){return @{Version=$script:MigrationVersion;Url='https://example.invalid/igame.lha'}}
 function script:SaveUserPackageDownload($url,$path){Copy-Item -LiteralPath $script:MigrationDownload -Destination $path}
} $modern.Components[0].Version (Join-Path (Join-Path (Join-Path $repo 'user-packages') $modern.Directory) $modern.Components[0].LocalFile)
$migration=@(GetUserPackageUpdateResults $migrationRoot @($legacy))[0]
Assert ($migration.Status -eq 'Update available') 'Legacy iGame remains pinned'
$backup=InstallUserPackageSourceUpdate $migration
Assert (Test-Path (Join-Path $backup '_install')) 'Legacy installer was not backed up'
$script=[IO.File]::ReadAllText((Join-Path $legacyDir '_install'))
Assert ($script.Contains('USERPACKAGEDIR:iGame-1.5.lha') -and !$script.Contains('USERPACKAGEDIR:iGame v1.6a')) 'Legacy patch would overwrite the upgraded iGame'
Assert ((Get-FileHash (Join-Path $legacyDir 'IGAM.1.prefs')).Hash -eq $prefs) 'Legacy preferences changed'
Assert ((@(GetUserPackageUpdateResults $migrationRoot @($legacy))[0]).Status -eq 'Current') 'Migrated iGame was offered again'
Write-Host 'PASS: legacy iGame migrates to current releases with preferences and installer backup preserved.'

$dependencies=$entries | Where-Object Id -eq 'mui-v3-8-igame-dependencies'
$dependencies=$dependencies.PSObject.Copy()
$dependencies.Components=@($dependencies.Components | Where-Object Id -eq renderlib)
$depRoot=Join-Path $root 'dependency-migration';$null=New-Item -ItemType Directory -Path $depRoot
$depDir=Join-Path $depRoot $dependencies.Directory
Copy-Item -LiteralPath (Join-Path (Join-Path $repo 'user-packages') $dependencies.Directory) -Destination $depDir -Recurse
$combinedHash=(Get-FileHash (Join-Path $depDir 'guigfx_render_nofpu.lha')).Hash
$newRender=Join-Path $root 'render-update.lha';MakeLha $newRender 'renderlib/libs/render.library' 'new-render-library'
& (Get-Module user-package-updates) {param($download) $script:MigrationVersion='40.9';$script:MigrationDownload=$download} $newRender
foreach($version in @('40.9','40.10')){
 & (Get-Module user-package-updates) {param($v) $script:MigrationVersion=$v} $version
 $update=@(GetUserPackageUpdateResults $depRoot @($dependencies))[0]
 Assert ($update.Status -eq 'Update available') 'Render library is not updateable'
 $null=InstallUserPackageSourceUpdate $update
 Assert ((Get-FileHash (Join-Path $depDir 'guigfx-baseline.lha')).Hash -eq $combinedHash) 'Original guigfx library was lost during render update'
 Assert (([IO.File]::ReadAllText((Join-Path $depDir '_install'))).Contains('renderlib/libs/render.library')) 'Updated render payload is not installed'
 Assert ((@(GetUserPackageUpdateResults $depRoot @($dependencies))[0]).Status -eq 'Current') 'Updated render library offered again'
}
Write-Host 'PASS: consecutive render updates retain the combined bundle guigfx dependency.'
