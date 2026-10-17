using module ./modules/packages.psm1
$ErrorActionPreference='Stop'
$repo=Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $repo 'modules/config.psm1') -Force
Import-Module (Join-Path $repo 'modules/data.psm1') -Force
Import-Module (Join-Path $repo 'modules/local-settings.psm1') -Force
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression
function Assert($ok,$message){if(!$ok){throw $message}}
$root=Join-Path $repo ('.output/settings-packages-test-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $root | Out-Null
$source=Join-Path $root 'previous';$local=Join-Path $root 'install-a/settings'
New-Item -ItemType Directory $source | Out-Null
foreach($name in @('hstwb-installer-settings.ini','hstwb-installer-assigns.ini')){[IO.File]::WriteAllText((Join-Path $source $name),'original')}
ImportLegacyInstallerSettings $local $source
[IO.File]::WriteAllText((Join-Path $local 'hstwb-installer-settings.ini'),'local')
Assert ((Get-Content (Join-Path $source 'hstwb-installer-settings.ini')) -eq 'original') 'Import still shares settings'
$other=Join-Path $root 'install-b/settings'
ImportLegacyInstallerSettings $other $source
Assert ((Get-Content (Join-Path $other 'hstwb-installer-settings.ini')) -eq 'original') 'Separate installation inherited another local edit'
$rejected=$false;try{ImportLegacyInstallerSettings $local $source}catch{$rejected=$true}
Assert $rejected 'Import overwrote local settings'
foreach($file in @('setup.ps1','run.ps1','launcher.ps1')){
 $text=Get-Content (Join-Path $repo $file) -Raw
 Assert ($text.Contains("Join-Path `$PSScriptRoot -ChildPath 'settings'")) "Not installation-local: $file"
}
function MakePackage($path,$version){
 $zip=[IO.Compression.ZipFile]::Open($path,[IO.Compression.ZipArchiveMode]::Create)
 try{$entry=$zip.CreateEntry('hstwb-package.json');$writer=New-Object IO.StreamWriter($entry.Open());try{$writer.Write((@{Name='Synthetic';Version=$version;AmigaOsVersions=@('3.2')}|ConvertTo-Json))}finally{$writer.Dispose()}}finally{$zip.Dispose()}
}
$one=Join-Path $root 'one.zip';$two=Join-Path $root 'two.zip'
MakePackage $one '1.0';MakePackage $two '2.0'
$dest=Join-Path $root 'packages'
Assert ((ReadPackages $dest).Count -eq 0) 'Missing packages folder not treated as empty'
$manager=[PackageManager]::new($dest)
$releases=@([pscustomobject]@{Prerelease='False';Version='1.0';Url=([uri]$one).AbsoluteUri;FileName='Synthetic.zip'},[pscustomobject]@{Prerelease='False';Version='2.0';Url=([uri]$two).AbsoluteUri;FileName='Synthetic.zip'})
$manager.DownloadPackages(@([pscustomobject]@{Name='Synthetic';Releases=$releases}),$false)
Assert ((ReadPackages $dest)['synthetic'].Version -eq '2.0') 'Latest release not downloaded into newly created folder'
$manager.DownloadPackages(@([pscustomobject]@{Name='Synthetic';Releases=$releases}),$false)
Assert ($manager.DownloadedCount -eq 0 -and $manager.SkippedCount -eq 1) 'Current package was downloaded again'
$hash=(Get-FileHash (Join-Path $dest 'Synthetic.zip')).Hash
$client=[WebClient]::new()
$rejected=$false;try{$client.DownloadFile('Missing file',([uri](Join-Path $root 'missing.zip')).AbsoluteUri,(Join-Path $dest 'Synthetic.zip'))}catch{$rejected=$true}
Assert $rejected 'Failed download reported success'
Assert ((Get-FileHash (Join-Path $dest 'Synthetic.zip')).Hash -eq $hash) 'Failed download destroyed old package'
$bad=Join-Path $root 'bad.zip';[IO.File]::WriteAllText($bad,'not a ZIP')
$rejected=$false;try{$client.DownloadFile('Invalid ZIP',([uri]$bad).AbsoluteUri,(Join-Path $dest 'Synthetic.zip'))}catch{$rejected=$true}
Assert $rejected 'Invalid archive accepted'
$client.DownloadFile('Replace valid package',([uri]$two).AbsoluteUri,(Join-Path $dest 'Synthetic.zip'))
Assert (@(Get-ChildItem $dest -Filter '*.previous').Count -eq 1) 'Previous package not retained'
Copy-Item $one (Join-Path $dest 'older.zip')
Assert ((ReadPackages $dest)['synthetic'].Version -eq '2.0') 'Older local archive replaced newest selection'
# Exercise the actual setup download screen: failures must not print Done.
$tokens=$null;$errors=$null
$ast=[Management.Automation.Language.Parser]::ParseFile((Join-Path $repo 'setup.ps1'),[ref]$tokens,[ref]$errors)
Assert ($errors.Count -eq 0) 'Setup contains parse errors'
$fn=$ast.Find({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'DownloadLatestPackages'},$true)
Invoke-Expression $fn.Extent.Text
function ConfirmDialog { return $true }
function Read-Host { return '' }
$list=Join-Path $root 'packages.json'
@{Source='GitHubReleases';CheckedAt=(Get-Date).ToUniversalTime().ToString('o');Packages=@(@{Name='Synthetic';Releases=@(@{Version='3.0';Prerelease='False';FileName='Synthetic.zip';Url=([uri](Join-Path $root 'missing.zip')).AbsoluteUri})})}|ConvertTo-Json -Depth 6|Set-Content $list
$hstwb=@{Paths=@{PackagesListFile=$list;PackagesPath=$dest};Packages=@{}}
$screen=(& {DownloadLatestPackages $hstwb $false} 6>&1 | Out-String)
Assert ($screen -match 'Package download failed:' -and $screen -notmatch '(?m)^Done\s*$') 'Download screen reported Done after failure'
Assert ($hstwb.Packages.Count -eq 1) 'Failed batch left existing downloads hidden from setup'
$fn=$ast.Find({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'SelectPackages'},$true)
Invoke-Expression $fn.Extent.Text
function Menu($hstwb,$title,$options) {
 Assert (@($options | Where-Object {$_.Value -eq 'synthetic'}).Count -eq 1) 'Downloaded package absent from selection menu'
 return @{Value='back'}
}
$hstwb.Settings=@{Packages=@{PackageFiltering='All'}}
$hstwb.Packages=@{}
SelectPackages $hstwb
Assert ($hstwb.Packages.Count -eq 1) 'Selection did not refresh packages from disk'
Import-Module (Join-Path $repo 'modules/dialog.psm1') -Force
$hstwb.Settings.Installer=@{Mode='Install'}
$hstwb.Settings.Image=@{}
$hstwb.Settings.AmigaOs=@{AmigaOsSet='Amiga OS 3.2';TargetVersion='3.2.3'}
$hstwb.Settings.Kickstart=@{}
$hstwb.Settings.UserPackages=@{}
$hstwb.Settings.Emulator=@{}
$hstwb.UI=@{AmigaOs=@{AmigaOsSetInfo=@{Text="'Amiga OS 3.2' (77/96)"}};Kickstart=@{}}
$screen=(& {PrintSettings $hstwb} 6>&1 | Out-String)
Assert ($screen -match "Target Amiga OS\s+: 'Amiga OS 3.2.3'" -and $screen -match 'Amiga OS media set') 'Selected OS target is not clearly distinguished from base media'
Write-Host 'PASS: local settings isolation/import, missing package directory, newest release selection, download failure/invalid ZIP preservation, and backup'
