# Build and apply native installer configuration without running installation.
Import-Module (Join-Path $PSScriptRoot '../modules/config.psm1')
Import-Module (Join-Path $PSScriptRoot 'image-builder.psm1')
Import-Module (Join-Path $PSScriptRoot 'runtime-validation.psm1')
Import-Module (Join-Path $PSScriptRoot '../modules/data.psm1')
Import-Module (Join-Path $PSScriptRoot '../modules/amigaos-release.psm1')
Import-Module (Join-Path $PSScriptRoot '../modules/settings-profiles.psm1')

function GetDesktopSettingsHash($path){
 if(!(Test-Path -LiteralPath $path -PathType Leaf)){return 'absent'}
 $stream=[IO.File]::OpenRead($path);$sha=[Security.Cryptography.SHA256]::Create()
 try{return ([BitConverter]::ToString($sha.ComputeHash($stream))).Replace('-','')}finally{$stream.Dispose();$sha.Dispose()}
}
function GetDesktopPlanToken($plan){
 $lines=@($plan.SettingsHash,$plan.AssignsHash)
 foreach($kind in @('Settings','Assigns')){foreach($section in @($plan[$kind].Keys | Sort-Object)){foreach($key in @($plan[$kind][$section].Keys | Sort-Object)){$lines+=$kind+'|'+$section+'|'+$key+'='+[string]$plan[$kind][$section][$key]}}}
 $lines+=@($plan.PackageVersions | Sort-Object)
 $sha=[Security.Cryptography.SHA256]::Create()
 try{return ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($lines -join "`n")))).Replace('-','')}finally{$sha.Dispose()}
}
function VisitDesktopDependency($name,$packages,$selected,$states){
 if($states[$name] -eq 'visiting'){throw ('Circular package dependency: '+$name)}
 if($states[$name] -eq 'done'){return}
 $states[$name]='visiting'
 foreach($dependency in $packages[$name].Dependencies){if($dependency.Name -in $selected){VisitDesktopDependency $dependency.Name $packages $selected $states}}
 $states[$name]='done'
}
# Resolve only selected catalog filenames and remembered renamed media. Hashing
# remains authoritative; remembered detection only narrows the candidate paths.
function GetDesktopMediaCandidates($root,$folder,$entries,$kind){
 $remembered=@()
 try{
  $cache=Get-Content -LiteralPath (Join-Path $root 'settings/desktop-scans.json') -Raw | ConvertFrom-Json
  $key='Media|'+[IO.Path]::GetFullPath($folder).TrimEnd([IO.Path]::DirectorySeparatorChar).ToUpperInvariant()
  if($cache.SchemaVersion -eq 1){$record=$cache.Scans.PSObject.Properties[$key].Value;$remembered=@($record.Rows | Where-Object {$_.Kind -eq $kind})}
 }catch{}
 $names=@($entries | ForEach-Object Filename | Where-Object {$_})
 $paths=@(foreach($row in $remembered){
  if(@($entries | Where-Object {$_.Set -eq $row.Set -and $_.Name -eq $row.Name}).Count -and $row.File -and (Test-Path -LiteralPath $row.File -PathType Leaf)){$row.File}
 })
 $paths+=@(Get-ChildItem -LiteralPath $folder -Recurse -File | Where-Object {$_.Name -in $names} | ForEach-Object FullName)
 return @($paths | Sort-Object -Unique)
}
function NewDesktopInstallerPlan($root,$draft){
 $root=[IO.Path]::GetFullPath($root)
 $settingsPath=Join-Path $root 'settings/hstwb-installer-settings.ini';$assignsPath=Join-Path $root 'settings/hstwb-installer-assigns.ini'
 $settings=if(Test-Path -LiteralPath $settingsPath){ReadIniFile $settingsPath}else{@{}}
 $assigns=if(Test-Path -LiteralPath $assignsPath){ReadIniFile $assignsPath}else{@{}}
 $issues=New-Object 'System.Collections.Generic.List[object]'
 foreach($section in @('Installer','AmigaOs','Kickstart','Image','Emulator','Packages','UserPackages','Media')){if(!$settings.ContainsKey($section)){$settings[$section]=@{}}}
 $settings.Installer.Mode='Install'
 $settings.AmigaOs.InstallAmigaOs='Yes';$settings.Kickstart.InstallKickstart='Yes'
 $settings.AmigaOs.AmigaOsSet=[string]$draft.OsSet;$settings.AmigaOs.TargetVersion=[string]$draft.TargetVersion
 $settings.Kickstart.KickstartSet=[string]$draft.KickstartSet
 $settings.Media.Dir=[string]$draft.MediaFolder;$settings.AmigaOs.AmigaOsDir=[string]$draft.MediaFolder;$settings.Kickstart.KickstartDir=[string]$draft.MediaFolder
 $settings.Image.ImageDir=[string]$draft.ImageFolder;$settings.Emulator.EmulatorFile=[string]$draft.EmulatorFile
 $userRoot=Join-Path $root 'user-packages';$settings.UserPackages.UserPackagesDir=$userRoot;$settings.Packages.PackageFiltering='All'
 foreach($section in @('Packages','UserPackages')){foreach($key in @($settings[$section].Keys | Where-Object {$_ -match '^Install(?:User)?Package\d+$|^Install(?:User)?Packages$'})){$settings[$section].Remove($key)}}
 if(!$assigns.ContainsKey('Global')){DefaultAssigns $assigns}
 $hstwb=@{Settings=$settings;Assigns=$assigns;Paths=@{AmigaOsEntriesFile=(Join-Path $root 'data/amiga-os-entries.csv');KickstartEntriesFile=(Join-Path $root 'data/kickstart-entries.csv')};Models=@('A1200','A500')}
 if(!$draft.OsSet){[void]$issues.Add(@{Area='AmigaOS';Message='Choose the OS to install in Media & ROMs.'})}
 if(!$draft.KickstartSet){[void]$issues.Add(@{Area='Kickstart';Message='Choose a Kickstart set in Media & ROMs.'})}
 if([string]::IsNullOrWhiteSpace([string]$draft.MediaFolder) -or !(Test-Path -LiteralPath ([string]$draft.MediaFolder) -PathType Container)){[void]$issues.Add(@{Area='Media';Message='Choose an existing media folder.'})}else{
  try{
   UpdateAmigaOsEntries $hstwb;UpdateKickstartEntries $hstwb
   $hstwb.AmigaOsEntries=@($hstwb.AmigaOsEntries | Where-Object {$_.Set -eq $draft.OsSet})
   if($draft.OsSet -eq 'Amiga OS 3.2'){
    $prefix='amiga-os-'+([string]$draft.TargetVersion).Replace('.','')+'-'
    $hstwb.AmigaOsEntries=@($hstwb.AmigaOsEntries | Where-Object {$_.Filename -match '^amiga-os-32-[^.]+\.adf$' -or ($draft.TargetVersion -and $_.Filename.StartsWith($prefix))})
   }
   $family=($hstwb.AmigaOsEntries | Select-Object -First 1).AmigaOsVersion
   $hstwb.KickstartEntries=@($hstwb.KickstartEntries | Where-Object {$_.Set -eq $draft.KickstartSet -or ($_.RunSupported -eq 'True' -and $_.Model -in $hstwb.Models -and ($_.AmigaOsVersionsSupported -split ',') -contains $family)})
   $osFiles=@(GetDesktopMediaCandidates $root $draft.MediaFolder $hstwb.AmigaOsEntries 'AmigaOS')
   $selectedRoms=@($hstwb.KickstartEntries | Where-Object {$_.Set -eq $draft.KickstartSet})
   $romFiles=@(GetDesktopMediaCandidates $root $draft.MediaFolder $selectedRoms 'Kickstart')
   FindAmigaOsFiles $hstwb $osFiles 6>$null;FindKickstartFiles $hstwb $romFiles 6>$null
   if(!@($hstwb.KickstartEntries | Where-Object {$_.File -and $_.RunSupported -eq 'True' -and $_.Model -in $hstwb.Models -and ($_.AmigaOsVersionsSupported -split ',') -contains $family}).Count){
    $bootCandidates=@($hstwb.KickstartEntries | Where-Object {$_.Set -ne $draft.KickstartSet})
    $bootFiles=@(GetDesktopMediaCandidates $root $draft.MediaFolder $bootCandidates 'Kickstart')
    if($bootFiles.Count){FindKickstartFiles $hstwb $bootFiles 6>$null}
   }
   $osEntries=@($hstwb.AmigaOsEntries | Where-Object {$_.Set -eq $draft.OsSet})
   if(!$osEntries.Count){[void]$issues.Add(@{Area='AmigaOS';Message='The selected OS media set is unknown.'})}
   elseif($draft.OsSet -eq 'Amiga OS 3.2'){
    $target=if($draft.TargetVersion){$draft.TargetVersion}else{'3.2'};$settings.AmigaOs.TargetVersion=$target
    try{$manifest=Get-Content (Join-Path $root 'data/release-manifest.json') -Raw | ConvertFrom-Json;$null=GetAmigaOs32InstallPlan $hstwb.AmigaOsEntries $target $manifest}catch{[void]$issues.Add(@{Area='AmigaOS';Message=$_.Exception.Message})}
   }else{
    $settings.AmigaOs.Remove('TargetVersion')
    $validation=ValidateSet $hstwb.AmigaOsEntries $draft.OsSet
    foreach($entry in @($validation.Entries | Where-Object {$_.Required -eq 'True' -and !$_.File})){[void]$issues.Add(@{Area='AmigaOS';Message=('Required media missing: '+$entry.Name)})}
    if(!$validation.FilesCount){[void]$issues.Add(@{Area='AmigaOS';Message='No files were detected for the selected OS set. Use Scan folders in Media & ROMs if your media files have been renamed.'})}
   }
   $roms=@($hstwb.KickstartEntries | Where-Object {$_.Set -eq $draft.KickstartSet})
   $required=@($roms | Group-Object Name | Where-Object {@($_.Group | Where-Object {$_.Required -eq 'True'}).Count -and !@($_.Group | Where-Object {$_.File}).Count})
   foreach($group in $required){[void]$issues.Add(@{Area='Kickstart';Message=('Required ROM missing: '+$group.Name)})}
   if(!@($roms | Where-Object {$_.File}).Count){[void]$issues.Add(@{Area='Kickstart';Message='No ROM was detected for the selected Kickstart set. Use Scan folders in Media & ROMs if your ROM files have been renamed.'})}
   if($osEntries.Count){$family=$osEntries[0].AmigaOsVersion;if(!@($hstwb.KickstartEntries | Where-Object {$_.File -and $_.RunSupported -eq 'True' -and $_.Model -in $hstwb.Models -and ($_.AmigaOsVersionsSupported -split ',') -contains $family}).Count){[void]$issues.Add(@{Area='Kickstart';Message='No supported A1200/A500 installer boot ROM was found in the media folder for this OS family.'})}}
  }catch{[void]$issues.Add(@{Area='Media';Message=$_.Exception.Message})}
 }
 try{
  if($draft.CreateNewImage){
   $template=GetDesktopImageTemplate $root ([string]$draft.ImageTemplate)
   if(!$draft.NewImageFolder){throw 'Choose a new image destination.'}
   $base=[IO.Path]::GetFullPath([string]$draft.ImageFolder).TrimEnd('\')
   $destination=[IO.Path]::GetFullPath([string]$draft.NewImageFolder)
   if([IO.Path]::GetDirectoryName($destination) -ne $base -or [IO.Path]::GetFileName($destination) -notmatch '^Install-'){throw 'The new image must be in a new Install- subfolder of the output folder.'}
   if(Test-Path -LiteralPath $destination){throw 'The new image destination already exists. Start a new run.'}
   $settings.Image.ImageDir=$destination
  }else{
  if([int]$draft.ImageMode -ne 1 -and !(Test-Path -LiteralPath (Join-Path ([string]$draft.ImageFolder) 'hstwb-image.json'))){throw 'Choose an existing image folder in Image & Emulator. The selected folder has no hstwb-image.json.'}
  $imageRoot=[IO.Path]::GetFullPath([string]$draft.ImageFolder).TrimEnd('\')+'\'
  $image=Get-Content -LiteralPath (Join-Path $imageRoot 'hstwb-image.json') -Raw | ConvertFrom-Json
  if(!@($image.harddrives).Count){throw 'Image has no harddrives.'}
  foreach($drive in $image.harddrives){
   if(!$drive.path){throw 'Image contains a drive with no path.'}
   $full=[IO.Path]::GetFullPath((Join-Path $imageRoot $drive.path))
   if([IO.Path]::IsPathRooted($drive.path)-or !$full.StartsWith($imageRoot,[StringComparison]::OrdinalIgnoreCase)){throw 'Image contains a drive outside its folder.'}
   if(!(Test-Path -LiteralPath $full)){throw ('Image drive missing: '+$drive.path)}
   if($drive.type -eq 'hdf' -and (!(Test-Path -LiteralPath $full -PathType Leaf)-or (Get-Item -LiteralPath $full).Length -eq 0)){throw ('Image disk is empty or invalid: '+$drive.path)}
   if($drive.type -eq 'dir' -and !(Test-Path -LiteralPath $full -PathType Container)){throw ('Image directory drive missing: '+$drive.path)}
  }
  }
 }catch{[void]$issues.Add(@{Area='Image';Message=$_.Exception.Message})}
 if([string]::IsNullOrWhiteSpace([string]$draft.EmulatorFile) -or !(Test-Path -LiteralPath ([string]$draft.EmulatorFile) -PathType Leaf)-or [IO.Path]::GetFileName([string]$draft.EmulatorFile) -notin @('winuae.exe','winuae64.exe','fs-uae.exe')){[void]$issues.Add(@{Area='Emulator';Message='Choose an existing WinUAE or FS-UAE executable.'})}
 $selected=@($draft.Selected | Select-Object -Unique);$versions=@();if($draft.CreateNewImage){$versions+=('ImageTemplate@'+(GetDesktopSettingsHash ([string]$draft.ImageTemplate)))};$packageNames=@();$userNames=@();$bundleNotes=@();if($osEntries.Count){$bootRom=$null;foreach($model in $hstwb.Models){$bootRom=$hstwb.KickstartEntries | Where-Object {$_.File -and $_.RunSupported -eq 'True' -and $_.Model -eq $model -and ($_.AmigaOsVersionsSupported -split ',') -contains $osEntries[0].AmigaOsVersion} | Select-Object -First 1;if($bootRom){break}};if($bootRom){$bundleNotes+=('Installer boot ROM: '+$bootRom.Name+'. Selected ROM set: '+$draft.KickstartSet+'.')}}
 try{
  $official=Get-Content (Join-Path $root 'data/hstwb-packages.json') -Raw | ConvertFrom-Json
  $cache=Join-Path $root 'settings/desktop-package-catalog.json'
  if(Test-Path -LiteralPath $cache){try{$official=Get-Content -LiteralPath $cache -Raw | ConvertFrom-Json -ErrorAction Stop}catch{}}
  $files=@(foreach($entry in @($official.Packages | Where-Object {('package/'+$_.Name) -in $selected})){
   foreach($release in $entry.Releases){[string]$release.FileName}
   # Legacy/local catalogs can omit release filenames.
   $normal=($entry.Name -replace '-package$','') -replace '[^a-zA-Z0-9]',''
   $normal+'.zip'
  })
  $hstwb.Packages=& (Get-Module config) {param($folder,$dependency,$files) Import-Module $dependency; ReadPackages $folder -AllowedFiles $files} (Join-Path $root 'packages') (Join-Path $PSScriptRoot '../modules/data.psm1') $files
  $users=Get-Content (Join-Path $root 'data/user-package-updates.json') -Raw | ConvertFrom-Json
  foreach($id in $selected){
   if($id -eq 'gamepack/whdload-packs'){
    Import-Module (Join-Path $PSScriptRoot 'games-library.psm1')
    $chosenGames=if($draft.GamePacksFolder){[string]$draft.GamePacksFolder}else{Join-Path $userRoot 'WHDLoad Packs'};$packs=@(GetDesktopGamePacks $root $chosenGames);$populated=@($packs | Where-Object {$_.Archives -gt 0})
    if(!$populated.Count){[void]$issues.Add(@{Area='Games & Demos';Message='Add local archives to a WHDLoad pack folder before selecting the bundle.'})}
    foreach($pack in $populated){if($pack.Status -ne 'Ready'){[void]$issues.Add(@{Area='Games & Demos';Message=('Build installation lists for '+$pack.Name)})};$versions+=$pack.Name+'@'+(GetDesktopSettingsHash (Join-Path $pack.Directory 'entries-all.csv'))}
    $bundle=$chosenGames
    if(!(Test-Path -LiteralPath (Join-Path $bundle '_install')) -or !(Test-Path -LiteralPath (Join-Path $bundle '_installdir'))){[void]$issues.Add(@{Area='Games & Demos';Message='WHDLoad Packs bundle installer is missing.'})}
    $userNames+='WHDLoad Packs';$bundleNotes+='The complete WHDLoad Packs bundle will be installed. WHDLoad runtime and required ROMs must be installed or already present in the image.'
   }elseif($id -like 'package/*'){
    $entry=$official.Packages | Where-Object {('package/'+$_.Name) -eq $id} | Select-Object -First 1
    if(!$entry){[void]$issues.Add(@{Area='Packages';Message=('Unknown package selection: '+$id)});continue}
    $normal=($entry.Name -replace '-package$','') -replace '[^a-zA-Z0-9]',''
    $local=$hstwb.Packages.Values | Where-Object {($_.Name -replace '[^a-zA-Z0-9]','') -eq $normal} | Select-Object -First 1
    if(!$local){[void]$issues.Add(@{Area='Packages';Message=('Download the selected package: '+$entry.Name)});continue}
    $packageNames+=$local.Name;$file=Get-Item -LiteralPath $local.PackageFile;$versions+=$local.Name+'@'+$local.Version+'|'+$file.Length+'|'+$file.LastWriteTimeUtc.Ticks
   }else{
    $entry=$users.Packages | Where-Object {$p=$_;@($p.Components | Where-Object {($p.Id+'/'+$_.Id) -eq $id}).Count} | Select-Object -First 1
    if(!$entry){[void]$issues.Add(@{Area='User Packages';Message=('Unknown user-package selection: '+$id)});continue}
    $directory=Join-Path $userRoot $entry.Directory
    if(!(Test-Path -LiteralPath (Join-Path $directory '_installdir'))-or !(Test-Path -LiteralPath (Join-Path $directory '_install'))){[void]$issues.Add(@{Area='User Packages';Message=('Package installer files missing: '+$entry.Name)});continue}
    foreach($component in @($entry.Components | Where-Object {$_.UserSupplied})){
     $payload=Join-Path $directory $component.LocalFile
     if(!(Test-Path -LiteralPath $payload -PathType Leaf)){[void]$issues.Add(@{Area='User Packages';Message=('Download '+$component.LocalFile+' from '+$component.Repository+' into '+$directory+' before installing '+$entry.Name)})}
     elseif($component.BaselineSha256 -and (Get-FileHash -LiteralPath $payload -Algorithm SHA256).Hash -ne $component.BaselineSha256){[void]$issues.Add(@{Area='User Packages';Message=('User-supplied archive hash differs from the supported release: '+$component.LocalFile)})}
     else{$versions+=$entry.Directory+'@'+(GetDesktopSettingsHash $payload)}
    }
    foreach($component in @($entry.Components | Where-Object {$_.UserSupplied})){
     $payload=Join-Path $directory $component.LocalFile
     if(!(Test-Path -LiteralPath $payload -PathType Leaf)){[void]$issues.Add(@{Area='User Packages';Message=('Download '+$component.LocalFile+' from '+$component.Repository+' into '+$directory+' before installing '+$entry.Name)})}
     elseif($component.BaselineSha256 -and (Get-FileHash -LiteralPath $payload -Algorithm SHA256).Hash -ne $component.BaselineSha256){[void]$issues.Add(@{Area='User Packages';Message=('User-supplied archive hash differs from the supported release: '+$component.LocalFile)})}
     else{$versions+=$entry.Directory+'@'+(GetDesktopSettingsHash $payload)}
    }
    $versions+=$entry.Directory+'@'+(GetDesktopSettingsHash (Join-Path $directory '_update-state.json'))+'@'+(GetDesktopSettingsHash (Join-Path $directory '_install'))+'@'+(GetDesktopSettingsHash (Join-Path $directory '_installdir'))
    $userNames+=$entry.Directory
    if(@($entry.Components).Count -gt 1){$bundleNotes+=('Selecting a component installs the complete '+$entry.Name+' bundle.')}
   }
  }
  $packageNames=@($packageNames | Sort-Object -Unique);$userNames=@($userNames | Sort-Object -Unique)
  $content=@{}
  foreach($name in $packageNames){
   $package=$hstwb.Packages[$name]
   $family=if($draft.OsSet -eq 'Amiga OS 3.2'){'3.2'}else{($hstwb.AmigaOsEntries | Where-Object {$_.Set -eq $draft.OsSet} | Select-Object -First 1).AmigaOsVersion}
   if($package.AmigaOsVersions -and $family -notin $package.AmigaOsVersions){[void]$issues.Add(@{Area='Packages';Message=($name+' does not advertise support for AmigaOS '+$family)})}
   foreach($dependency in $package.Dependencies){if($dependency.Name -notin $packageNames){[void]$issues.Add(@{Area='Packages';Message=('Select and download '+$dependency.Name+', required by '+$name)})}}
   foreach($id in $package.ContentIds){if($content.ContainsKey($id)){[void]$issues.Add(@{Area='Packages';Message=('Conflicting content: '+$name+' and '+$content[$id]+' both provide '+$id)})}else{$content[$id]=$name}}
  }
  try{$states=@{};foreach($name in $packageNames){VisitDesktopDependency $name $hstwb.Packages $packageNames $states}}catch{[void]$issues.Add(@{Area='Packages';Message=$_.Exception.Message})}
  for($i=0;$i -lt $packageNames.Count;$i++){$settings.Packages['InstallPackage'+($i+1)]=$packageNames[$i]}
  for($i=0;$i -lt $userNames.Count;$i++){$settings.UserPackages['InstallUserPackage'+($i+1)]=$userNames[$i]}
  UpdateAssigns $hstwb
  if(!(ValidateAssigns $assigns 6>$null)){[void]$issues.Add(@{Area='Assigns';Message='Installer assigns require correction in existing setup.'})}
 }catch{[void]$issues.Add(@{Area='Packages';Message=$_.Exception.Message})}
 $plan=@{Valid=($issues.Count -eq 0);Issues=@($issues.ToArray());Settings=$settings;Assigns=$assigns;SettingsPath=$settingsPath;AssignsPath=$assignsPath;SettingsHash=(GetDesktopSettingsHash $settingsPath);AssignsHash=(GetDesktopSettingsHash $assignsPath);PackageVersions=$versions;PackageNames=$packageNames;UserPackageNames=$userNames;Notes=@($bundleNotes | Sort-Object -Unique)}
 if($plan.Valid){$plan.Runtime=NewDesktopRuntimeValidation $hstwb $userNames}
 $plan.Token=GetDesktopPlanToken $plan
 return $plan
}
function SaveDesktopInstallerPlan($plan,$expectedToken){
 if(!$plan.Valid){throw 'Resolve validation issues before applying settings.'}
 if(!$expectedToken-or $expectedToken -ne $plan.Token){throw 'Settings or selections changed since validation. Validate again before applying.'}
 $directory=Split-Path $plan.SettingsPath -Parent
 $null=New-Item -ItemType Directory -Path $directory -Force
 $lock=[IO.File]::Open((Join-Path $directory '.desktop-apply.lock'),[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
 $backup=Join-Path $directory ('backups/desktop-'+(Get-Date -Format 'yyyyMMdd-HHmmss')+'-'+[guid]::NewGuid().ToString('N'))
 $stagedSettings=Join-Path $directory ([guid]::NewGuid().ToString('N')+'.settings.tmp');$stagedAssigns=Join-Path $directory ([guid]::NewGuid().ToString('N')+'.assigns.tmp')
 try{
  if((GetDesktopSettingsHash $plan.SettingsPath) -ne $plan.SettingsHash -or (GetDesktopSettingsHash $plan.AssignsPath) -ne $plan.AssignsHash){throw 'Installer settings changed. Validate again.'}
  $null=New-Item -ItemType Directory -Path $backup -Force
  foreach($path in @($plan.SettingsPath,$plan.AssignsPath)){if(Test-Path -LiteralPath $path){Copy-Item -LiteralPath $path -Destination (Join-Path $backup ([IO.Path]::GetFileName($path)))}}
  WriteSettingsProfile (Join-Path $backup 'applied.hstwb-profile.json') @{Version='Desktop';Settings=$plan.Settings;Assigns=$plan.Assigns}
  WriteIniFile $stagedSettings $plan.Settings;WriteIniFile $stagedAssigns $plan.Assigns
  $settingsWritten=$false;$assignsWritten=$false
  try{
   if(Test-Path -LiteralPath $plan.SettingsPath){[IO.File]::Replace($stagedSettings,$plan.SettingsPath,(Join-Path $backup 'settings-replaced.ini'))}else{[IO.File]::Move($stagedSettings,$plan.SettingsPath)};$settingsWritten=$true
   if(Test-Path -LiteralPath $plan.AssignsPath){[IO.File]::Replace($stagedAssigns,$plan.AssignsPath,(Join-Path $backup 'assigns-replaced.ini'))}else{[IO.File]::Move($stagedAssigns,$plan.AssignsPath)};$assignsWritten=$true
  }catch{
   foreach($item in @(@{Path=$plan.SettingsPath;Written=$settingsWritten;Hash=$plan.SettingsHash},@{Path=$plan.AssignsPath;Written=$assignsWritten;Hash=$plan.AssignsHash})){if($item.Written){$original=Join-Path $backup ([IO.Path]::GetFileName($item.Path));if($item.Hash -eq 'absent'){[IO.File]::Delete($item.Path)}else{[IO.File]::Copy($original,$item.Path,$true)}}}
   throw
  }
  return $backup
 }finally{foreach($path in @($stagedSettings,$stagedAssigns)){if(Test-Path -LiteralPath $path){[IO.File]::Delete($path)}};$lock.Dispose()}
}
function NewDesktopRunSettings($root,$plan,$draft){
 $nativeSettings=Split-Path $plan.SettingsPath -Parent
 if('WHDLoad Packs' -notin $plan.UserPackageNames){return $nativeSettings}
 $local=Join-Path $root 'user-packages';$games=[string]$draft.GamePacksFolder
 if(!$games -or [IO.Path]::GetFullPath($games).TrimEnd('\') -eq [IO.Path]::GetFullPath((Join-Path $local 'WHDLoad Packs')).TrimEnd('\')){return $nativeSettings}
 # The native engine has one root. A per-run view keeps application bundles local
 # while exposing the explicitly selected external games without copying archives.
 $run=Join-Path $root ('.output/desktop/runs/'+[guid]::NewGuid().ToString('N'))
 $library=Join-Path $run 'user-packages';$settings=Join-Path $run 'settings'
 $null=New-Item -ItemType Directory -Path $library -Force
 $null=New-Item -ItemType Directory -Path $settings -Force
 foreach($name in $plan.UserPackageNames){
  if([IO.Path]::GetFileName($name) -ne $name){throw 'Invalid user-package directory name.'}
  $target=if($name -eq 'WHDLoad Packs'){$games}else{Join-Path $local $name}
  if(!(Test-Path -LiteralPath $target -PathType Container)){throw ('User-package directory missing: '+$name)}
  $null=New-Item -ItemType Junction -Path (Join-Path $library $name) -Target ([IO.Path]::GetFullPath($target)) -ErrorAction Stop
 }
 $config=ReadIniFile $plan.SettingsPath;$config.UserPackages.UserPackagesDir=$library
 WriteIniFile (Join-Path $settings 'hstwb-installer-settings.ini') $config
 Copy-Item -LiteralPath $plan.AssignsPath -Destination (Join-Path $settings 'hstwb-installer-assigns.ini')
 return $settings
}
Export-ModuleMember -Function NewDesktopInstallerPlan,SaveDesktopInstallerPlan,NewDesktopRunSettings
