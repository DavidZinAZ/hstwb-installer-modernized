
param([ValidateSet('Catalog','ScanLocal','Check','Update','CheckPackages','DownloadPackages','MediaCatalog','Emulators','ScanMedia','LoadSettings','ValidateInstaller','ApplyInstaller','RunInstaller','GamePacks','BuildGameLists','LibraryPaths')][string]$Action='Catalog',[string]$RequestFile)
$ErrorActionPreference='Stop'
[Console]::OutputEncoding=New-Object Text.UTF8Encoding($false)
$ProgressPreference='SilentlyContinue'
if($env:HSTWB_DESKTOP_PROGRESS){
 function global:Write-Progress {
  param([string]$Activity,[string]$Status,[int]$PercentComplete=0,[switch]$Completed,[int]$Id=0,[int]$ParentId=-1,[string]$CurrentOperation,[int]$SecondsRemaining=-1)
  try{[IO.File]::WriteAllText($env:HSTWB_DESKTOP_PROGRESS,(@{Percent=$PercentComplete;Message=($Activity+': '+$Status)} | ConvertTo-Json -Compress))}catch{}
 }
}
$root=Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $PSScriptRoot 'games-library.psm1')
$libraryPaths=GetDesktopLibraryPaths $root
$userRoot=$libraryPaths.UserPackagesFolder
$ids=@();if($RequestFile){$ids=Get-Content -LiteralPath $RequestFile -Raw | ConvertFrom-Json}
if($Action -eq 'LibraryPaths'){$paths=if($ids.Count -and $ids[0] -eq 'InstallerDefault'){GetDesktopLibraryPaths $root -IgnoreDesktop}else{$libraryPaths};ConvertTo-Json -InputObject @($paths) -Compress;return}
if($Action -eq 'ScanMedia') { & (Join-Path $PSScriptRoot 'media.ps1') -Folder $ids[0];return }
if($Action -eq 'MediaCatalog') {
 $rows=@();foreach($kind in @('AmigaOs','Kickstart')){
  $name=if($kind -eq 'AmigaOs'){'amiga-os-entries.csv'}else{'kickstart-entries.csv'}
  $rows+=@(Import-Csv -Delimiter ';' (Join-Path $root ('data/'+$name)) | Where-Object Name | ForEach-Object {[pscustomobject]@{Kind=$(if($kind -eq 'AmigaOs'){'AmigaOS'}else{'Kickstart'});Name=$_.Name;Set=$_.Set;Required=$_.Required;Status='Not scanned';File='';Match=''}})
 }
 ConvertTo-Json -InputObject @($rows | Sort-Object Kind,Set,Name -Unique) -Compress;return
}
if($Action -eq 'Emulators') {
 Import-Module (Join-Path $root 'modules/config.psm1') -Force
 $paths=@(FindEmulators | ForEach-Object {$_.File})
 foreach($folder in @((Join-Path $root 'emulators'),(Join-Path $root 'winuae'),(Join-Path $root 'fs-uae'))){if(!(Test-Path -LiteralPath $folder -PathType Container)){continue};$paths+=@(Get-ChildItem -LiteralPath $folder -Filter *.exe -Recurse -File | Where-Object {$_.Name -in @('winuae.exe','winuae64.exe','fs-uae.exe')} | ForEach-Object FullName)}
 $paths+=@($ids | Where-Object {Test-Path -LiteralPath $_ -PathType Leaf})
 $rows=@($paths | Sort-Object -Unique | ForEach-Object {$info=[Diagnostics.FileVersionInfo]::GetVersionInfo($_);[pscustomobject]@{Name=([IO.Path]::GetFileName($_)+' '+$(if($info.ProductVersion){$info.ProductVersion}else{'(version not reported)'})+' - '+$_);Path=$_}})
 ConvertTo-Json -InputObject @($rows) -Compress;return
}
if($Action -in @('ValidateInstaller','ApplyInstaller','RunInstaller')){
 Import-Module (Join-Path $PSScriptRoot 'installer-plan.psm1') -Force
 $draft=ConvertFrom-Json ([string]$ids[0])
 $plan=NewDesktopInstallerPlan $root $draft
 $backup=''
 if($Action -eq 'ApplyInstaller'){$backup=SaveDesktopInstallerPlan $plan ([string]$ids[1])}
 if($Action -eq 'RunInstaller'){
  $runLock=[IO.File]::Open((Join-Path $root 'settings/.desktop-run.lock'),[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
  try{
   if(!$draft.CreateNewImage){throw 'Run installation requires a fresh image from a template.'}
   if(!$plan.Valid -or $plan.Token -ne [string]$ids[1]){throw 'Choices changed. Validate again before creating an image.'}
   Import-Module (Join-Path $PSScriptRoot 'image-builder.psm1')
   $newImage=NewDesktopImage $root ([string]$draft.ImageTemplate) ([string]$draft.NewImageFolder)
   $backup=SaveDesktopInstallerPlan $plan ([string]$ids[1])
   $log=Join-Path $root ('.output/desktop/installation-'+(Get-Date -Format 'yyyyMMdd-HHmmss')+'-'+[guid]::NewGuid().ToString('N')+'.log')
   $null=New-Item -ItemType Directory -Path (Split-Path $log) -Force
   try{& (Join-Path $root 'run.ps1') -settingsDir (Join-Path $root 'settings') -Desktop *> $log}catch{throw ('Installation failed. Log: '+$log+'. '+$_.Exception.Message)}
   ConvertTo-Json -InputObject @(@{Status='Completed';Log=$log;Backup=$backup;ImageFolder=$newImage}) -Compress;return
  }finally{$runLock.Dispose()}
 }
 $row=@{Valid=$plan.Valid;Issues=@($plan.Issues);Token=$plan.Token;PackageNames=@($plan.PackageNames);UserPackageNames=@($plan.UserPackageNames);Notes=@($plan.Notes);SettingsPath=$plan.SettingsPath;Backup=$backup}
 ConvertTo-Json -InputObject @($row) -Depth 8 -Compress;return
}
if($Action -in @('GamePacks','BuildGameLists')){
 Import-Module (Join-Path $PSScriptRoot 'games-library.psm1') -Force
 $backup='';if($Action -eq 'BuildGameLists'){$backup=BuildDesktopGameLists $root $(if($ids.Count){[string]$ids[0]}else{''})}
 $rows=@(GetDesktopGamePacks $root $(if($ids.Count){[string]$ids[0]}else{''}) | ForEach-Object {$_ | Add-Member NoteProperty Backup $backup -PassThru})
 ConvertTo-Json -InputObject @($rows) -Compress;return
}
function GetDesktopFailureMessage($failure){
 $message=[string]$failure.Exception.Message
 $rateLimited=(($message+' '+$failure.ErrorDetails.Message) -match '(?i)rate.?limit|too many requests|\b429\b')
 try{if($failure.Exception.Response.Headers['X-RateLimit-Remaining'] -eq '0'){$rateLimited=$true}}catch{}
 if($rateLimited){return 'GitHub request limit reached. Saved releases can still be downloaded. Try checking again later.'}
 if($message -match '(?i)\b404\b|not found'){return 'The requested download or release was not found at its source.'}
 if($message -match '(?i)timed? out|timeout'){return 'The source did not respond in time. Try again later.'}
 $line=($message -split '[\r\n]')[0]
 $line=($line -replace '\s+',' ').Trim()
 if($line.Length -gt 220){$line=$line.Substring(0,217)+'...'}
 return $line
}
function ReadAmigaDestination($directory){
 $file=Join-Path $directory '_installdir'
 if(Test-Path -LiteralPath $file -PathType Leaf){return ([IO.File]::ReadAllText($file)).Trim()}
 return 'Defined by package installer'
}
if($Action -eq 'LoadSettings'){
 Import-Module (Join-Path $root 'modules/config.psm1') -Force
 Import-Module (Join-Path $root 'modules/settings-profiles.psm1') -Force
 $file=[IO.Path]::GetFullPath([string]$ids[0])
 if([IO.Path]::GetExtension($file) -eq '.ini'){$settings=ReadIniFile $file}else{$profile=ReadSettingsProfile $file;$settings=$profile.Settings}
 foreach($section in @('Installer','AmigaOs','Kickstart','Image','Emulator','Packages','UserPackages')){if(!$settings.ContainsKey($section)){throw ('Choose an installer settings file. Missing section: '+$section)}}
 if($settings.Installer.Mode -notin @('Install','BuildSelfInstall','BuildPackageInstallation','BuildUserPackageInstallation','Test')){throw 'Unsupported installer mode in settings file.'}
 $selected=@()
 $official=Get-Content (Join-Path $root 'data/hstwb-packages.json') -Raw | ConvertFrom-Json
 $names=@($settings.Packages.Keys | Where-Object {$_ -match '^InstallPackage\d+$'} | ForEach-Object {$settings.Packages[$_]})
 foreach($p in $official.Packages){$normalized=($p.Name -replace '-package$','') -replace '[^a-zA-Z0-9]','';if(@($names | Where-Object {($_ -replace '[^a-zA-Z0-9]','') -eq $normalized}).Count){$selected+='package/'+$p.Name}}
 $users=Get-Content (Join-Path $root 'data/user-package-updates.json') -Raw | ConvertFrom-Json
 $names=@($settings.UserPackages.Keys | Where-Object {$_ -match '^InstallUserPackage\d+$'} | ForEach-Object {$settings.UserPackages[$_]})
 foreach($p in $users.Packages){if($p.Directory -in $names -or $p.Name -in $names){foreach($c in $p.Components){$selected+=$p.Id+'/'+$c.Id}}}
 if('WHDLoad Packs' -in $names){$selected+='gamepack/whdload-packs'}
 $row=@{UserPackagesFolder=[string]$settings.UserPackages.UserPackagesDir;GamePacksFolder=$(if($settings.UserPackages.UserPackagesDir){Join-Path $settings.UserPackages.UserPackagesDir 'WHDLoad Packs'}else{''});OsSet=[string]$settings.AmigaOs.AmigaOsSet;TargetVersion=[string]$settings.AmigaOs.TargetVersion;KickstartSet=[string]$settings.Kickstart.KickstartSet;MediaFolder=$(if($settings.Media.Dir){$settings.Media.Dir}else{[string]$settings.AmigaOs.AmigaOsDir});ImageFolder=[string]$settings.Image.ImageDir;ImageMode=1;EmulatorFile=[string]$settings.Emulator.EmulatorFile;Selected=@($selected);ImportNote='Imported into the desktop draft; original installer settings were not changed.'}
 ConvertTo-Json -InputObject @($row) -Depth 6 -Compress;return
}
Import-Module (Join-Path $root 'modules/user-package-updates.psm1') -Force
$catalog=@(GetUserPackageCatalog (Join-Path $root 'data/user-package-updates.json'))
$rows=@()
if($Action -in @('Catalog','ScanLocal','CheckPackages','DownloadPackages')) {
 $cache=Join-Path $root 'settings/desktop-package-catalog.json'
 $official=Get-Content -LiteralPath (Join-Path $root 'data/hstwb-packages.json') -Raw | ConvertFrom-Json
 if(Test-Path -LiteralPath $cache){try{$official=Get-Content -LiteralPath $cache -Raw | ConvertFrom-Json -ErrorAction Stop}catch{}}
 if($ids.Count){$chosen=@($official.Packages | Where-Object {('package/'+$_.Name) -in $ids})}else{$chosen=@($official.Packages)}
 $checkError=''
 if($Action -eq 'CheckPackages'){
  try{
  Import-Module (Join-Path $root 'modules/package-catalog.psm1') -Force
  $checked=UpdateOfficialPackageCatalog ([pscustomobject]@{Packages=$chosen}) 6>$null
  $names=@($checked.Packages | ForEach-Object Name)
  $official.Packages=@($official.Packages | Where-Object {$_.Name -notin $names})+@($checked.Packages)
  $null=New-Item -ItemType Directory -Path (Split-Path $cache -Parent) -Force
  $temp=$cache+'.'+[guid]::NewGuid().ToString('N')+'.tmp'
  try{[IO.File]::WriteAllText($temp,($official | ConvertTo-Json -Depth 16),(New-Object Text.UTF8Encoding($false)));if(Test-Path -LiteralPath $cache){[IO.File]::Replace($temp,$cache,($temp+'.previous'));Remove-Item -LiteralPath ($temp+'.previous')}else{[IO.File]::Move($temp,$cache)}}finally{if(Test-Path -LiteralPath $temp){Remove-Item -LiteralPath $temp}}
  $chosen=@($checked.Packages)
  }catch{$checkError=GetDesktopFailureMessage $_}
 }
 Import-Module (Join-Path $root 'modules/packages.psm1') -Force
 $manager=& (Get-Module packages) {param($folder) [PackageManager]::new($folder)} (Join-Path $root 'packages')
 foreach($p in $chosen){
  $errorText='';$downloadNote='';if($Action -eq 'DownloadPackages'){try{$manager.DownloadPackages(@($p),$false) 6>$null;$downloadNote=if($manager.DownloadedCount){'Downloaded and verified.'}else{'Already downloaded and verified.'}}catch{$errorText=GetDesktopFailureMessage $_}}
  $stable=@($p.Releases | Where-Object {$_.Prerelease -ne 'True'} | Sort-Object {[version]$_.Version} -Descending)
  $local=@($stable | Where-Object {$manager.HasPackageVersion((Join-Path (Join-Path $root 'packages') $_.FileName),$_.Version,$p.Name)})
  if($Action -eq 'DownloadPackages' -and !$errorText -and (!$stable.Count -or !$manager.HasPackageVersion((Join-Path (Join-Path $root 'packages') $stable[0].FileName),$stable[0].Version,$p.Name))){$errorText='The downloaded archive does not match the expected package and version. It cannot be used.'}
  $status=if($errorText){'Download failed'}elseif($checkError){'Check unavailable'}elseif($Action -eq 'DownloadPackages' -and $manager.SkippedCount -gt 0){'Already downloaded'}elseif($Action -eq 'DownloadPackages' -and $manager.DownloadedCount -gt 0){'Downloaded'}elseif(!$local.Count){'Not downloaded'}elseif($stable.Count -and [version]$stable[0].Version -gt [version]$local[0].Version){'Update available'}else{'Current'}
  $rows += [pscustomobject]@{Category='Packages';Id=('package/'+$p.Name);Name=$p.Name;Package=$p.Name;Version=$(if($local.Count){$local[0].Version}else{'Not downloaded'});Available=$(if($stable.Count){$stable[0].Version}else{'Not available'});Status=$status;Url=('https://github.com/'+$p.Repository);Details=$(if($errorText){$errorText}elseif($checkError){$checkError}elseif($downloadNote){$downloadNote}elseif($Action -in @('Catalog','ScanLocal')){'Compared with saved release information. Use Check for updates to refresh.'}else{''})}
 }
}
if($Action -eq 'Catalog') {
 $gameRoot=$libraryPaths.GamePacksFolder
 $rows += [pscustomobject]@{Category='Games & Demos';Id='gamepack/whdload-packs';Name='WHDLoad Packs';Package='WHDLoad Packs';Destination='See pack folders';Directory=$gameRoot;Version='Local archives';Available='Local archives';Status=$(if(Test-Path -LiteralPath (Join-Path $gameRoot '_install')){'Local bundle'}else{'Missing'});Url='';Details='Installs the complete WHDLoad Packs bundle. Prepare installation lists in Games & Demos.'}
 foreach($p in $catalog){
  $directory=Join-Path $userRoot $p.Directory
  $state=$null;try{$state=GetUserPackageLocalState $directory}catch{}
  foreach($c in $p.Components){
   $url=if($c.Repository){'https://github.com/'+$c.Repository}elseif($c.AminetPath){'https://aminet.net/package/'+$c.AminetPath}elseif($c.MetadataUrl){$c.MetadataUrl}else{''}
   $saved=$state.Components | Where-Object {$_.Id -eq $c.Id} | Select-Object -First 1
   $version=if($saved.Version){$saved.Version}elseif($c.Version){$c.Version}else{'Not versioned'}
   $rows += [pscustomobject]@{Category='User Packages';Id=($p.Id+'/'+$c.Id);Name=$c.Name;Package=$p.Name;Destination=(ReadAmigaDestination $directory);Directory=$directory;Version=$version;Available='Not checked';Status=$(if(Test-Path -LiteralPath $directory){'In local library'}else{'Missing'});Url=$url;Details=[string]$c.Reason}
  }
 }
} elseif($Action -in @('ScanLocal','Check','Update')) {
 $chosen=if($ids.Count){@($catalog | Where-Object {$p=$_;@($p.Components | Where-Object {($p.Id+'/'+$_.Id) -in $ids}).Count})}else{$catalog}
 # Restrict components before querying sources, so each requested component is checked once.
 $filtered=@(foreach($p in $chosen){$copy=$p.PSObject.Copy();if($ids.Count){$copy.Components=@($p.Components | Where-Object {($p.Id+'/'+$_.Id) -in $ids})};$copy})
 foreach($r in @(GetUserPackageUpdateResults $userRoot $filtered -LocalOnly:($Action -eq 'ScanLocal'))){
  $id=$r.Package.Id+'/'+$r.Component.Id
  if(!$r.Package.Id -or ($ids.Count -and $id -notin $ids)){continue}
  if($Action -eq 'Update' -and $r.Status -eq 'Update available') {
   try{$backup=InstallUserPackageSourceUpdate $r;$r.Status='Updated';$r.Message='Backup: '+$backup;$r.LocalVersion=$r.Release.Version}catch{$r.Status='Update failed';$r.Message=$_.Exception.Message}
  }
  if($r.Component.Provider -eq 'Manual'){$r.Status='Manual updates only'}elseif($r.Status -eq 'Review required' -and !$r.Release){$r.Status='Source check failed'};$rows += [pscustomobject]@{Category='User Packages';Id=$id;Name=$r.Component.Name;Version=$(if($r.LocalVersion){$r.LocalVersion}else{'Not versioned'});Available=$(if($r.Release.Version){$r.Release.Version}else{'Not verified'});Destination=(ReadAmigaDestination $r.Directory);Directory=$r.Directory;Status=$r.Status;Details=$r.Message}
 }
}
ConvertTo-Json -InputObject @($rows) -Depth 6 -Compress
