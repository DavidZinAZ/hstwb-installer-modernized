$ErrorActionPreference='Stop'
$repo=Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $repo 'modules/user-package-updates.psm1') -Force
Import-Module (Join-Path $repo 'modules/config.psm1') -Force
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression
function Assert($value,$message){if(!$value){throw $message}}
$names=@('xSysInfo','KickSmash','DevTest','SDMAC','A4091 Tools','ZZ9000 Firmware','ZZ9000 Drivers','DOpus5')
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
# Exercise complete RawFile and ZipArchive updates with network calls replaced by fixtures.
$root=Join-Path $repo ('.output/additional-updates-'+[guid]::NewGuid().ToString('N'))
$null=New-Item -ItemType Directory $root
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
 $c=[pscustomobject]@{Id='test';Mode=$mode;LocalFile='payload';BaselineSha256=(Get-FileHash $download).Hash;RequiredMembers=@('Bundle/Tool');MagicHex=if($mode -eq 'RawFile'){'000003F3'}else{''}}
 $release=@{Version='2.0';Url='https://example.invalid/payload';Sha256=(Get-FileHash $download).Hash}
 & $module {param($r,$p) $script:FixtureRelease=$r;$script:FixtureDownload=$p} $release $download
 $result=@{Status='Update available';Directory=$dir;Component=$c;Release=$release;Package=@{Directory=$mode;PackageVersion='1.0.0'}}
 $backup=InstallUserPackageSourceUpdate $result
 Assert (Test-Path $backup) 'Update backup missing'
 Assert ((GetUserPackageLocalState $dir).Components[0].Version -eq '2.0') 'Update state missing'
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
Write-Host 'PASS: eight selectable packages, payload hashes/layouts, LF scripts, raw/ZIP updates and rejected payload preservation'
