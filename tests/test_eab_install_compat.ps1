param([string]$PackagesDir=(Join-Path (Split-Path $PSScriptRoot -Parent) 'packages'),[string]$PackageVersion='3.2.0')
$ErrorActionPreference='Stop'
$repo=Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $repo 'modules/package-install-compat.psm1') -Force
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root=Join-Path $repo ('.output/eab-compat-'+[guid]::NewGuid().ToString('N'))
$null=New-Item -ItemType Directory -Path $root
foreach($kind in @('Games','Demos')) {
 foreach($model in @('AGA','OCS')) {
  $zip=[IO.Compression.ZipFile]::OpenRead((Join-Path $PackagesDir "EAB.WHDLoad.$kind.$model.Menu.$PackageVersion.zip"))
  try {
   $reader=New-Object IO.StreamReader(($zip.GetEntry('Install')).Open())
   try{$original=$reader.ReadToEnd()}finally{$reader.Dispose()}
  }finally{$zip.Dispose()}
  foreach($fresh in @($false,$true)) {
   $file=Join-Path $root "$kind-$model-$fresh"
   [IO.File]::WriteAllText($file,$original)
   UpdateEabPackageInstallScript $file $fresh
   $text=[IO.File]::ReadAllText($file)
   $assignSection=$text.Substring($text.IndexOf('; Add or update A-'))
   if($text.Contains("`r")){throw 'Amiga script contains CR'}
   if(!$assignSection.Contains('search SYSTEMDIR:S/Assign-Startup "Assign >NIL: A-')){throw 'Missing identical-path guard'}
   if($fresh -and $assignSection.Contains('RequestChoice "Update assign"')){throw 'Fresh install still prompts'}
   if(!$fresh -and !$assignSection.Contains('RequestChoice "Update assign"')){throw 'Existing install lost conflict confirmation'}
  }
 }
}
if(([IO.File]::ReadAllBytes((Join-Path $repo 'user-packages/WHDLoad v18.8/_install'))) -contains 13){throw 'Bundled WHDLoad script contains CR'}
Write-Host 'PASS: actual Games/Demos AGA/OCS scripts, fresh/existing assign handling and WHDLoad LF format'
