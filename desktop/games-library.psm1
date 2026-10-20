function GetDesktopLibraryPaths($root,$gameFolder='',[switch]$IgnoreDesktop){
 $userRoot=Join-Path $root 'user-packages'
 $native=Join-Path $root 'settings/hstwb-installer-settings.ini'
 $nativeGameFolder=''
 if($IgnoreDesktop -and (Test-Path -LiteralPath $native)){$section='';foreach($line in Get-Content -LiteralPath $native){if($line -match '^\s*\[([^\]]+)\]'){$section=$Matches[1]}elseif($section -eq 'UserPackages' -and $line -match '^\s*UserPackagesDir\s*=(.+)$'){$nativeGameFolder=Join-Path $Matches[1].Trim() 'WHDLoad Packs'}}}
 $saved=$null;$state=Join-Path $root 'settings/desktop.json'
 if(!$IgnoreDesktop -and (Test-Path -LiteralPath $state)){try{$saved=Get-Content -LiteralPath $state -Raw | ConvertFrom-Json}catch{}}

 if(!$gameFolder -and $saved.GamePacksFolder){$gameFolder=[string]$saved.GamePacksFolder}
 if(!$gameFolder){$gameFolder=if($nativeGameFolder){$nativeGameFolder}else{Join-Path $userRoot 'WHDLoad Packs'}}
 if(![IO.Path]::IsPathRooted($gameFolder)){$gameFolder=Join-Path $root $gameFolder}
 return [pscustomobject]@{UserPackagesFolder=$userRoot;GamePacksFolder=$gameFolder}
}
function GetDesktopGamePacks($root,$folder=''){
  $packRoot=(GetDesktopLibraryPaths $root $folder).GamePacksFolder
 if(!(Test-Path -LiteralPath $packRoot -PathType Container)){return}
 $packIndex=0; $scanFolders=@(Get-ChildItem -LiteralPath $packRoot -Directory | Where-Object {$_.Name -match 'whdload' -and (Test-Path -LiteralPath (Join-Path $_.FullName '_installdir'))} | Sort-Object Name);foreach($folder in $scanFolders){
  $packIndex++;Write-Progress -Activity "Scanning WHDLoad packs" -Status ("{0} of {1}: {2}" -f $packIndex,$scanFolders.Count,$folder.Name) -PercentComplete (100*($packIndex-1)/[Math]::Max(1,$scanFolders.Count))
  $files=@(Get-ChildItem -LiteralPath $folder.FullName -Recurse -File | Where-Object {$_.Extension -in @('.lha','.lzx','.zip')})
  $list=Join-Path $folder.FullName 'entries-all.csv';$status='Empty';$listed=0
  if($files.Count){
   $status='Build lists first'
   if((Test-Path -LiteralPath (Join-Path $folder.FullName '_install')) -and (Test-Path -LiteralPath $list)){
    try{
     $entries=@(Import-Csv -LiteralPath $list -Delimiter ';');$listed=$entries.Count
     $expected=@($files | ForEach-Object {$_.FullName.Substring($folder.FullName.Length+1).Replace('\','/')} | Sort-Object)
     $actual=@($entries | ForEach-Object {([string]$_.UserPackageFile).Replace('\','/')} | Sort-Object)
     $changed=@(Compare-Object $expected $actual).Count -gt 0
     foreach($set in @('All','Best-Version','Best-Version-Lowmem')){if(!(Test-Path -LiteralPath (Join-Path $folder.FullName ('Install/'+$set+'/Install-Entries')))-or !(Test-Path -LiteralPath (Join-Path $folder.FullName ('entries-'+$set.ToLower()+'.csv')))){$changed=$true}}
     $newest=($files | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1).LastWriteTimeUtc
     $status=if(!$changed -and $listed -eq $files.Count -and (Get-Item -LiteralPath $list).LastWriteTimeUtc -ge $newest){'Ready'}else{'Lists need rebuilding'}
    }catch{$status='Lists need rebuilding'}
   }
  }
  [pscustomobject]@{Name=$folder.Name;Archives=$files.Count;Listed=$listed;Destination=([IO.File]::ReadAllText((Join-Path $folder.FullName '_installdir'))).Trim();Status=$status;Directory=$folder.FullName}
 }
}
function BuildDesktopGameLists($root,$folder=''){
  $packRoot=(GetDesktopLibraryPaths $root $folder).GamePacksFolder
 $packs=@(GetDesktopGamePacks $root $packRoot)
 if(!@($packs | Where-Object {$_.Archives -gt 0}).Count){throw 'Add local LHA, LZX or ZIP archives to a pack folder first.'}
 $builder=Join-Path $root 'user-packages/WHDLoad Packs/build_install_entries.ps1'
 if(!(Test-Path -LiteralPath $builder)){throw 'The WHDLoad installation-list builder is missing.'}
 $backup=Join-Path $root ('user-packages/.updates/games-list-backups/'+(Get-Date -Format 'yyyyMMdd-HHmmss')+'-'+[guid]::NewGuid().ToString('N'))
 $null=New-Item -ItemType Directory -Path $backup -Force
 [IO.File]::WriteAllText((Join-Path $backup 'source.json'),(@{GamePacksFolder=$packRoot;CreatedAt=(Get-Date).ToUniversalTime().ToString('o')} | ConvertTo-Json))
 foreach($pack in $packs){foreach($file in @(Get-ChildItem -LiteralPath $pack.Directory -File | Where-Object {$_.Name -eq '_install' -or $_.Name -like 'entries-*.csv'})){
  $destination=Join-Path $backup $pack.Name;$null=New-Item -ItemType Directory -Path $destination -Force;Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $destination $file.Name)
 };$generated=Join-Path $pack.Directory 'Install';if(Test-Path -LiteralPath $generated -PathType Container){$destination=Join-Path $backup $pack.Name;$null=New-Item -ItemType Directory -Path $destination -Force;Copy-Item -LiteralPath $generated -Destination (Join-Path $destination 'Install') -Recurse}}
 $null=& $builder $packRoot
 return $backup
}
Export-ModuleMember -Function GetDesktopGamePacks,BuildDesktopGameLists,GetDesktopLibraryPaths
