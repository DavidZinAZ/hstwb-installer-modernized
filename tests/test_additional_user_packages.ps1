$ErrorActionPreference='Stop'
$repo=Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $repo 'modules/user-package-updates.psm1') -Force
Import-Module (Join-Path $repo 'modules/config.psm1') -Force
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression
function Assert($value,$message){if(!$value){throw $message}}
$newNames=@('NetHarness','NilBBS','AmiFM','NilTerm','AmiDT','SCSIToolbox-Amiga','NoClick','AmiTime','AmiSSL-Tunnel','AmiNetXDuo','AmiNFSv3','TheWire13','CFD Modern','FAT95 Modern','ODFileSystem','Amelinium','XPKGuide','AmiSSL OS3','AmiSSL SDK','AmigaGPT','A1060Diag','VirusZ','SnoopDos','DiskFlush','AmiDock','ADF-Blitzer','ZZPlug','AmiPart')
$names=@('xSysInfo','KickSmash','DevTest','SDMAC','A4091 Tools','ZZ9000 Firmware','ZZ9000 Drivers','DOpus5','PrismRTG','PrismNet')+$newNames
$catalog=GetUserPackageCatalog (Join-Path $repo 'data/user-package-updates.json')
$detected=DetectUserPackages @{Settings=@{UserPackages=@{UserPackagesDir=(Join-Path $repo 'user-packages')}}}
foreach($name in $names) {
 $entry=$catalog | Where-Object Directory -eq $name
 Assert ($entry -and $detected.ContainsKey($name.ToLower())) ('Package not selectable: '+$name)
 $dir=Join-Path $repo ('user-packages/'+$name)
 $script=[IO.File]::ReadAllBytes((Join-Path $dir '_install'))
 Assert (!($script -contains 13)) ('Guest script has Windows line endings: '+$name)
 foreach($file in @('LICENSE.txt','SOURCE.txt','ReadMe.txt','_installdir')){Assert (Test-Path (Join-Path $dir $file)) ('Missing package documentation: '+$name+'/'+$file)}
 foreach($c in $entry.Components) {
  $file=Join-Path $dir $c.LocalFile
  if($c.UserSupplied -and !(Test-Path -LiteralPath $file)){continue}
  Assert ((Get-FileHash $file -Algorithm SHA256).Hash -eq $c.BaselineSha256) ('Payload hash mismatch: '+$file)
  if($c.Mode -eq 'Archive'){$members=@(GetLhaArchiveMembers $file)}
  elseif($c.Mode -eq 'ZipArchive') {
   $zip=[IO.Compression.ZipFile]::OpenRead($file)
   try{$members=@($zip.Entries | Where-Object Length -gt 0 | ForEach-Object FullName)}finally{$zip.Dispose()}
  }else{$members=@()}
  foreach($required in $c.RequiredMembers) {
   $pattern=$required.Replace('{root}',[string]$c.InstalledRoot)
   Assert (@($members | Where-Object {$_ -like $pattern}).Count -gt 0) ('Missing archive member: '+$name+'/'+$pattern)
  }
 }
}
foreach($name in @('PrismRTG','PrismNet')) {
 $entry=$catalog | Where-Object Directory -eq $name
 $script=[IO.File]::ReadAllText((Join-Path $repo ('user-packages/'+$name+'/_install')))
 Assert ($entry.Components[0].AutoUpdate -ne $false) ('Library updates must be enabled: '+$name)
 Assert (!$script.Contains('PrismInstaller') -and !$script.Contains('MINUSER')) ('Package must only extract files: '+$name)
 Assert ($script.Contains('Run Install_'+$name+' from its drawer')) ('Manual setup guidance missing: '+$name)
 Assert ($script.IndexOf('Ask "Press ENTER to continue"') -gt $script.IndexOf('files installed successfully.')) ('Results must pause for Enter: '+$name)
}
foreach($name in $newNames) {
 $entry=$catalog | Where-Object Directory -eq $name
 $script=[IO.File]::ReadAllText((Join-Path $repo ('user-packages/'+$name+'/_install')))
 Assert ($script.Contains('IF EXISTS "$INSTALLDIR/Upstream-README.txt"')) ('Existing package data must be retained: '+$name)
 Assert ($script.LastIndexOf('Ask "Press ENTER to continue"') -gt $script.IndexOf('files ready in:')) ('Package results must pause: '+$name)
 Assert (!$script.Contains('MINUSER') -and !$script.Contains('PrismInstaller') -and $script -notmatch '(?im)^\s*(Run |Execute |Mount |Installer |Copy.*"(?:LIBS|C|L|DEVS):)') ('Package must not activate components: '+$name)
 foreach($component in $entry.Components){Assert ($component.AutoUpdate -ne $false) ('Library updates must be enabled: '+$name)}
}
# The linked AmiDock upload is incomplete; do not imply it supplies a launcher.
$dock=$catalog | Where-Object Directory -eq 'AmiDock'
$dockMembers=@(GetLhaArchiveMembers (Join-Path $repo 'user-packages/AmiDock/AmiDock.lha'))
Assert (!($dockMembers | Where-Object {$_ -match '(^|/)AmiDock$'})) 'Review AmiDock completeness: upstream archive changed'
Assert ($dock.Description -match 'INCOMPLETE' -and $dock.Description -match 'no AmiDock executable') 'AmiDock missing-executable notice absent'
foreach($name in @('AmiSSL OS3','AmigaGPT','VirusZ','DiskFlush')) {
 $notes=[IO.File]::ReadAllText((Join-Path $repo ('user-packages/'+$name+'/ReadMe.txt')))
 Assert ($notes -match 'manual') ('Manual setup guidance missing: '+$name)
}
# Exercise complete RawFile and ZipArchive updates with network calls replaced by fixtures.
$root=Join-Path $repo ('.output/additional-updates-'+[guid]::NewGuid().ToString('N'))
$null=New-Item -ItemType Directory $root
# TheWire13 uses Amiga LhA filename comments after a NUL separator.
$wireMembers=@(GetLhaArchiveMembers (Join-Path $repo 'user-packages/TheWire13/TheWire13.lha'))
Assert ($wireMembers -contains 'TheWire13/c/TheWire13') 'LhA comment was treated as part of the filename'
Assert (!($wireMembers | Where-Object {$_ -match "`0"})) 'LhA comments leaked into member paths'
# Comments must not hide traversal in the actual filename.
$unsafeLha=Join-Path $root 'unsafe-comment.lha'
$unsafeName=[Text.Encoding]::ASCII.GetBytes("../outside`0comment")
$header=New-Object byte[] (24+$unsafeName.Length)
$header[0]=$header.Length-2
[Text.Encoding]::ASCII.GetBytes('-lh0-').CopyTo($header,2)
[BitConverter]::GetBytes([uint32]1).CopyTo($header,7)
[BitConverter]::GetBytes([uint32]1).CopyTo($header,11)
$header[21]=$unsafeName.Length
$unsafeName.CopyTo($header,22)
[IO.File]::WriteAllBytes($unsafeLha,($header+[byte[]](65,0)))
$unsafeRejected=$false;try{GetLhaArchiveMembers $unsafeLha | Out-Null}catch{$unsafeRejected=$true}
Assert $unsafeRejected 'LhA comment bypassed path traversal validation'
$module=Get-Module user-package-updates
& $module {
 function script:GetAvailableUserPackageRelease($component){return $script:FixtureRelease}
 function script:SaveUserPackageDownload($url,$path){Copy-Item -LiteralPath $script:FixtureDownload -Destination $path}
}
foreach($mode in @('RawFile','ZipArchive')) {
 $dir=Join-Path $root $mode;$null=New-Item -ItemType Directory $dir
 [IO.File]::WriteAllText((Join-Path $dir '_install'),'keep customization')
 $download=Join-Path $root ($mode+'.payload')
 if($mode -eq 'RawFile') {
  $original=[byte[]](0,0,3,243)+(New-Object byte[] 60);[IO.File]::WriteAllBytes($download,$original)
 }else{
  $z=[IO.Compression.ZipFile]::Open($download,[IO.Compression.ZipArchiveMode]::Create)
  try{$w=New-Object IO.StreamWriter(($z.CreateEntry('Bundle/Tool')).Open());$w.Write('tool');$w.Dispose()}finally{$z.Dispose()}
 }
 Copy-Item $download (Join-Path $dir 'payload')
 $c=[pscustomobject]@{Id='test';Version='1.0';Mode=$mode;LocalFile='payload';BaselineSha256=(Get-FileHash $download).Hash;RequiredMembers=@('Bundle/Tool');MagicHex=if($mode -eq 'RawFile'){'000003F3'}else{''};ExtractTo=if($mode -eq 'ZipArchive'){'Extracted'}else{''}}
 $release=@{Version='2.0';Url='https://example.invalid/payload';Sha256=(Get-FileHash $download).Hash}
 & $module {param($r,$p) $script:FixtureRelease=$r;$script:FixtureDownload=$p} $release $download
 $result=@{Status='Update available';Directory=$dir;Component=$c;Release=$release;Package=@{Directory=$mode;PackageVersion='1.0.0'}}
 $backup=InstallUserPackageSourceUpdate $result
 Assert (Test-Path $backup) 'Update backup missing'
 Assert ((GetUserPackageLocalState $dir).Components[0].Version -eq '2.0') 'Update state missing'
 if($mode -eq 'ZipArchive'){Assert ((Get-Content (Join-Path $dir 'Extracted/Tool')) -eq 'tool') 'Extracted installation payload was not refreshed'}
 $hash=(Get-FileHash (Join-Path $dir 'payload')).Hash
 # Bad file signatures and archive traversal must preserve the active package.
 $release.Version='3.0'
 if($mode -eq 'RawFile'){[IO.File]::WriteAllBytes($download,(New-Object byte[] 64))}
 else{
  [IO.File]::Delete($download)
  $z=[IO.Compression.ZipFile]::Open($download,[IO.Compression.ZipArchiveMode]::Create)
  try{$w=New-Object IO.StreamWriter(($z.CreateEntry('../outside')).Open());$w.Write('bad');$w.Dispose()}finally{$z.Dispose()}
 }
 $release.Sha256=(Get-FileHash $download).Hash
 $rejected=$false;try{InstallUserPackageSourceUpdate $result | Out-Null}catch{$rejected=$true}
 Assert $rejected 'Malformed payload accepted'
 Assert ((Get-FileHash (Join-Path $dir 'payload')).Hash -eq $hash) 'Rejected update damaged active payload'
}
Write-Host ('PASS: '+$names.Count+' selectable packages, payload hashes/layouts, explicit incomplete AmiDock notice, LhA comments and traversal rejection, LF scripts, extract-only behavior and pauses, retained package data, raw/ZIP updates and rejected payload preservation')
