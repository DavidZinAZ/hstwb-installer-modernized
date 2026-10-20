Add-Type -AssemblyName System.IO.Compression.FileSystem
function GetDesktopImagePath($folder,$relative){
 if(!$relative -or [IO.Path]::IsPathRooted($relative) -or $relative -match '(^|[/\\])\.\.([/\\]|$)|:'){throw 'Invalid image template path.'}
 $root=[IO.Path]::GetFullPath($folder).TrimEnd('\')+'\';$path=[IO.Path]::GetFullPath((Join-Path $root $relative))
 if(!$path.StartsWith($root,[StringComparison]::OrdinalIgnoreCase)){throw 'Image path is outside its folder.'};return $path
}
function GetDesktopImageTemplate($root,$template){
 $images=[IO.Path]::GetFullPath((Join-Path $root 'images')).TrimEnd('\')+'\'
 if(!$template){throw 'Choose an image template in Image & Emulator.'}
 $template=[IO.Path]::GetFullPath($template)
 if(!$template.StartsWith($images,[StringComparison]::OrdinalIgnoreCase)){throw 'Choose a template from the installer images folder.'}
 $zip=[IO.Compression.ZipFile]::OpenRead($template)
 try{
  $entry=@($zip.Entries | Where-Object {$_.Name -eq 'hstwb-image.json'})
  if($entry.Count -ne 1){throw 'Template must contain one hstwb-image.json.'}
  $reader=New-Object IO.StreamReader($entry[0].Open());try{$text=$reader.ReadToEnd()}finally{$reader.Dispose()}
  $image=$text | ConvertFrom-Json
  if(!@($image.harddrives).Count){throw 'Template has no harddrives.'}
  foreach($drive in $image.harddrives){$null=GetDesktopImagePath $images $drive.path;if($drive.type -notin @('hdf','dir')){throw 'Unsupported image drive type.'};if($drive.fileSystem){$null=GetDesktopImagePath $images $drive.fileSystem}}
  return @{Image=$image;Text=$text;Template=$template}
 }finally{$zip.Dispose()}
}
function GetDesktopImageProgress([long]$copied,[long]$length){
 return [int][Math]::Min([double]99,100.0*$copied/[Math]::Max([double]1,[double]$length))
}
function CopyDesktopImageEntry($entry,$destination,$label){
 $null=New-Item -ItemType Directory -Path (Split-Path $destination) -Force
 $inputStream=$entry.Open();$outputStream=$null
 try{
  $outputStream=[IO.File]::Open($destination,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
  $buffer=New-Object byte[] 1048576;$total=[long]0;$next=[datetime]::MinValue
  while(($count=$inputStream.Read($buffer,0,$buffer.Length)) -gt 0){$outputStream.Write($buffer,0,$count);$total+=$count;if([datetime]::UtcNow -ge $next){Write-Progress -Activity 'Creating new image' -Status ('{0}: {1:N1} / {2:N1} MB' -f $label,($total/1MB),($entry.Length/1MB)) -PercentComplete (GetDesktopImageProgress $total $entry.Length);$next=[datetime]::UtcNow.AddMilliseconds(300)}}
  if($total -ne $entry.Length){throw 'Image extraction was incomplete.'}
 }finally{if($outputStream){$outputStream.Dispose()};$inputStream.Dispose()}
}
function NewDesktopImage($root,$template,$destination){
 if(Test-Path -LiteralPath $destination){throw 'The new image folder already exists. Choose a new run destination.'}
 $info=GetDesktopImageTemplate $root $template
 $needed=[long]0;foreach($drive in $info.Image.harddrives){if($drive.type -eq 'hdf'){$needed+=[long]$drive.size}}
 $disk=New-Object IO.DriveInfo ([IO.Path]::GetPathRoot([IO.Path]::GetFullPath($destination)))
 if($disk.AvailableFreeSpace -lt $needed){throw 'Not enough free space to create the selected image.'}
 $null=New-Item -ItemType Directory -Path $destination -ErrorAction Stop
 $zip=[IO.Compression.ZipFile]::OpenRead($info.Template)
 try{
  foreach($drive in $info.Image.harddrives){
   $path=GetDesktopImagePath $destination $drive.path
   if($drive.type -eq 'dir'){$null=New-Item -ItemType Directory -Path $path -Force;continue}
   if($drive.fileSystem){$fs=$zip.Entries | Where-Object {$_.Name -eq [IO.Path]::GetFileName($drive.fileSystem)} | Select-Object -First 1;if(!$fs){throw 'Template filesystem file is missing.'};$fsPath=GetDesktopImagePath $destination $drive.fileSystem;if(!(Test-Path -LiteralPath $fsPath)){CopyDesktopImageEntry $fs $fsPath $drive.fileSystem}}
   $entry=$zip.Entries | Where-Object {$_.Name -eq [IO.Path]::GetFileName($drive.path)} | Select-Object -First 1
   if($entry){CopyDesktopImageEntry $entry $path $drive.path;continue}
   $nested=$zip.Entries | Where-Object {$_.Name -eq ([IO.Path]::GetFileNameWithoutExtension($drive.path)+'.zip')} | Select-Object -First 1
   if(!$nested){throw ('Template disk is missing: '+$drive.path)}
   $nestedPath=Join-Path $destination ('.template-'+[guid]::NewGuid().ToString('N')+'.zip')
   try{CopyDesktopImageEntry $nested $nestedPath 'Unpacking template';$inner=[IO.Compression.ZipFile]::OpenRead($nestedPath);try{$entry=$inner.Entries | Where-Object {$_.Name -eq [IO.Path]::GetFileName($drive.path)} | Select-Object -First 1;if(!$entry){throw 'Nested template disk is missing.'};CopyDesktopImageEntry $entry $path $drive.path}finally{$inner.Dispose()}}finally{if(Test-Path -LiteralPath $nestedPath){[IO.File]::Delete($nestedPath)}}
  }
  [IO.File]::WriteAllText((Join-Path $destination 'hstwb-image.json'),$info.Text)
  return $destination
 }catch{[IO.File]::WriteAllText((Join-Path $destination 'creation-failed.txt'),$_.Exception.Message);throw}finally{$zip.Dispose()}
}
Export-ModuleMember -Function GetDesktopImagePath,GetDesktopImageTemplate,NewDesktopImage
