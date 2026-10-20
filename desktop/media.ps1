param([Parameter(Mandatory=$true)][string]$Folder)
$ErrorActionPreference='Stop'
if(!(Test-Path -LiteralPath $Folder -PathType Container)){throw 'Choose an existing media folder.'}
$root=Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $root 'modules/data.psm1') -Force
$hstwb=@{Settings=@{Installer=@{Mode='Install'};AmigaOs=@{AmigaOsDir=$Folder};Kickstart=@{KickstartDir=$Folder}};Paths=@{AmigaOsEntriesFile=(Join-Path $root 'data/amiga-os-entries.csv');KickstartEntriesFile=(Join-Path $root 'data/kickstart-entries.csv')}}
UpdateAmigaOsEntries $hstwb
UpdateKickstartEntries $hstwb
FindAmigaOsFiles $hstwb 6>$null
FindKickstartFiles $hstwb 6>$null
$availableTargets=@()
Import-Module (Join-Path $root 'modules/amigaos-release.psm1') -Force
foreach($set in @($hstwb.AmigaOsEntries | ForEach-Object Set | Sort-Object -Unique)){
 if($set -eq 'Amiga OS 3.2'){
  $manifest=Get-Content (Join-Path $root 'data/release-manifest.json') -Raw | ConvertFrom-Json
  foreach($release in $manifest.Releases){try{$null=GetAmigaOs32InstallPlan $hstwb.AmigaOsEntries $release.Version $manifest;$availableTargets+='Amiga OS '+$release.Version}catch{}}
 }else{
  $validation=ValidateSet $hstwb.AmigaOsEntries $set
  if($validation.FilesCount -and !@($validation.Entries | Where-Object {$_.Required -eq 'True' -and !$_.File}).Count){$availableTargets+=$set}
 }
}
$rows=@()
foreach($kind in @('AmigaOs','Kickstart')){
 foreach($group in @($hstwb[($kind+'Entries')] | Group-Object Set,Name)){
  $found=@($group.Group | Where-Object {$_.File} | Select-Object -First 1)
  $entry=if($found.Count){$found[0]}else{$group.Group[0]}
  $rows += [pscustomobject]@{Kind=$(if($kind -eq 'AmigaOs'){'AmigaOS'}else{'Kickstart'});Name=$entry.Name;Set=$entry.Set;Status=$(if($found.Count){'Detected'}else{'Not detected'});Match=[string]$entry.MatchType;File=[string]$entry.File;Required=[string]$entry.Required;AvailableTargets=@($availableTargets)}
 }
}
ConvertTo-Json -InputObject @($rows) -Depth 4 -Compress
