$ErrorActionPreference='Stop'
$repo=Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $repo 'desktop/image-builder.psm1') -Force
$fixture=Join-Path $repo ('.output/image-builder-'+[guid]::NewGuid().ToString('N'))
$null=New-Item -ItemType Directory (Join-Path $fixture 'images') -Force
$payload=Join-Path $fixture 'payload';$null=New-Item -ItemType Directory $payload
[IO.File]::WriteAllBytes((Join-Path $payload 'disk.hdf'),[byte[]](1,2,3,4,5))
$nested=Join-Path $fixture 'disk.zip';[IO.Compression.ZipFile]::CreateFromDirectory($payload,$nested)
$template=Join-Path $fixture 'images/nested.zip';$zip=[IO.Compression.ZipFile]::Open($template,'Create')
try{
 $entry=$zip.CreateEntry('hstwb-image.json');$writer=New-Object IO.StreamWriter($entry.Open());try{$writer.Write('{"harddrives":[{"type":"hdf","path":"disk.hdf","size":5},{"type":"dir","path":"Work"}]}')}finally{$writer.Dispose()}
 [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip,$nested,'disk.zip') | Out-Null
}finally{$zip.Dispose()}
$first=Join-Path $fixture 'Install-first';$second=Join-Path $fixture 'Install-second'
$null=NewDesktopImage $fixture $template $first
$hash=(Get-FileHash (Join-Path $first 'disk.hdf')).Hash
$null=NewDesktopImage $fixture $template $second
if((Get-FileHash (Join-Path $second 'disk.hdf')).Hash -ne $hash -or !(Test-Path (Join-Path $second 'Work'))){throw 'Nested image or directory extraction failed'}
if((Get-FileHash (Join-Path $first 'disk.hdf')).Hash -ne $hash){throw 'Previous image changed'}
$rejected=$false;try{$null=NewDesktopImage $fixture $template $first}catch{$rejected=$true}
if(!$rejected){throw 'Existing output was overwritten'}
$rejected=$false;try{$null=GetDesktopImagePath $first '../escape.hdf'}catch{$rejected=$true}
if(!$rejected){throw 'Unsafe drive path accepted'}
Write-Host 'PASS: nested template extraction, directory drives, separate images, preservation of existing disks, and path containment.'
