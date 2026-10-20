param([string]$Ref='HEAD')
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root=Split-Path $PSScriptRoot -Parent
$commit=(& git -C $root rev-parse --verify ($Ref+'^{commit}')).Trim()
if($LASTEXITCODE -ne 0){throw 'Release source must be a committed Git revision.'}
$short=$commit.Substring(0,12)
$output=Join-Path $root '.release/desktop'
$build=Join-Path $output ('build-'+[guid]::NewGuid().ToString('N'))
$stage=Join-Path $build 'HstwbDesktop'
$null=New-Item -ItemType Directory -Path $stage -Force
# Export committed files, so local settings, payload updates and downloads cannot leak in.
$sourceZip=Join-Path $build 'source.zip'
$components=@('desktop','desktop.cmd','amiga','data','docs','fonts','emulators','fs-uae','images','licenses','modules','scripts','support','winuae','user-packages','README.md','LICENSE.txt','THIRD_PARTY_NOTICES.md','CONTRIBUTING.md','SECURITY.md','CHANGELOG.md','ACKNOWLEDGMENTS.md','hstwb_installer.ico','run.ps1','run.cmd','setup.ps1','setup.cmd','launcher.ps1','launcher.cmd')
& git -C $root archive --format=zip ('--output='+$sourceZip) $commit -- $components
if($LASTEXITCODE -ne 0){throw 'Release source export failed.'}
[IO.Compression.ZipFile]::ExtractToDirectory($sourceZip,$stage)
if(!(Test-Path (Join-Path $stage 'desktop/start.ps1'))){throw 'This revision has no Windows desktop app.'}
foreach($document in @('docs/gui/README.md','docs/gui/user-guide.html','docs/cli/README.md','THIRD_PARTY_NOTICES.md')){if(!(Test-Path (Join-Path $stage $document))){throw ('Release documentation is missing: '+$document)}}
$buildOutput=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $stage 'desktop/start.ps1') -BuildOnly
if($LASTEXITCODE -ne 0){throw 'Release executable build failed.'}
$exe=(Get-Content -LiteralPath (Join-Path $stage '.output/desktop/latest.txt') -Raw).Trim()
Copy-Item -LiteralPath $exe -Destination (Join-Path $stage 'HstwbDesktop.exe')
$null=New-Item -ItemType Directory -Path (Join-Path $stage 'packages') -Force
[IO.File]::WriteAllText((Join-Path $stage 'START-HERE.txt'),@"
HstWB Windows Desktop Preview
Source commit: $commit

Extract the entire ZIP to a writable folder, then double-click HstwbDesktop.exe.
Keep the supporting folders beside the EXE. Windows with .NET Framework 4.8 is required.
Select your own AmigaOS/Kickstart media folder and installed WinUAE or FS-UAE executable.
Download packages in the app and select your local WHDLoad packs folder as needed.
Each installation creates a fresh image in a separate Install- subfolder.
Settings, cached scans and downloaded packages are stored in this extracted folder.
To upgrade, extract a new copy and use Settings > Load settings to import your saved profile.
Commercial OS/ROM media, emulators and personal collections are supplied separately.
The executable is unsigned. This is a preview release; retain your original media and images.
Open docs/gui/user-guide.html for the complete offline GUI manual, or use Settings > Open GUI user guide.
The original CLI/setup documentation is separate in docs/cli/README.md.
See desktop/README.md for build notes and LICENSE.txt for licensing.
"@)
$artifact=Join-Path $output ('hstwb-desktop-win-x64-'+$short+'.zip')
Add-Type -AssemblyName System.IO.Compression.FileSystem
$temporary=$artifact+'.'+[guid]::NewGuid().ToString('N')+'.tmp.zip'
$zip=[IO.Compression.ZipFile]::Open($temporary,'Create')
try{
 foreach($file in Get-ChildItem -LiteralPath $stage -Recurse -File){
  $relative=$file.FullName.Substring($stage.Length+1).Replace('\','/')
  if($relative -match '^(\.output|settings|packages)/'){continue}
  [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip,$file.FullName,('HstwbDesktop/'+$relative),[IO.Compression.CompressionLevel]::Optimal) | Out-Null
 }
}finally{$zip.Dispose()}
# Test the packaged layout without adding generated screenshots/settings to the ZIP.
$verification=Join-Path $build 'verification';[IO.Compression.ZipFile]::ExtractToDirectory($temporary,$verification)
$app=Join-Path $verification 'HstwbDesktop'
$process=Start-Process -FilePath (Join-Path $app 'HstwbDesktop.exe') -ArgumentList ('"'+$app+'" --smoke') -WorkingDirectory $app -WindowStyle Hidden -PassThru
if(!$process.WaitForExit(60000)){throw 'Packaged application verification timed out.'}
if($process.ExitCode -ne 0){throw ('Packaged application verification failed: '+(Get-Content (Join-Path $app '.output/desktop/smoke-error.txt') -Raw))}
$entries=[IO.Compression.ZipFile]::OpenRead($temporary)
try{if(@($entries.Entries | Where-Object {$_.FullName -match '/(settings|\.git|\.output|\.updates)/|_update-state\.json$'}).Count){throw 'Runtime state unexpectedly entered the release archive.'}}finally{$entries.Dispose()}
Move-Item -LiteralPath $temporary -Destination $artifact -Force
$hash=(Get-FileHash -LiteralPath $artifact -Algorithm SHA256).Hash.ToLowerInvariant()
[IO.File]::WriteAllText(($artifact+'.sha256'),($hash+'  '+[IO.Path]::GetFileName($artifact)+"`n"))
Write-Output ('Release ready: '+$artifact)
Write-Output ('SHA256: '+$hash)
