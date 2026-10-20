$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $root 'tools/desktop-release-publishing.psm1') -Force
$fixture=Join-Path $root ('.output/publish-test-'+[guid]::NewGuid().ToString('N'));$null=New-Item -ItemType Directory $fixture -Force
$commit='1234567890abcdef1234567890abcdef12345678'
foreach($name in @('hstwb-desktop-win-x64-1234567890ab.zip','hstwb-cli-1234567890ab.zip')){$file=Join-Path $fixture $name;[IO.File]::WriteAllText($file,'synthetic verified package');[IO.File]::WriteAllText(($file+'.sha256'),((Get-FileHash $file).Hash+'  '+$name))}
$files=@(GetDesktopReleaseFiles $fixture $commit)
if($files.Count -ne 3 -or 'hstwb-gui-windows.zip' -notin $files.Name -or 'hstwb-cli.zip' -notin $files.Name){throw 'Canonical download manifest failed.'}
[IO.File]::AppendAllText($files[0].Path,'changed')
$rejected=$false;try{$null=GetDesktopReleaseFiles $fixture $commit}catch{$rejected=$true}
if(!$rejected){throw 'Modified package was accepted.'}
& (Get-Module desktop-release-publishing) {
 $script:assets=@{};$script:failOnce=$true
 foreach($pair in @(@(1,'hstwb-gui-windows.zip'),@(2,'hstwb-cli.zip'),@(3,'SHA256SUMS.txt'),@(11,'pending-gui'),@(12,'pending-cli'),@(13,'pending-sums'))){$script:assets[[int]$pair[0]]=[pscustomobject]@{id=[int]$pair[0];name=$pair[1];state='uploaded'}}
 function script:InvokePreviewRequest($Method,$Path,$Body=$null,$File=$null,[switch]$AllowMissing){
  $id=[int]($Path -replace '^.*/','')
  if($id -eq 12 -and $Body.name -eq 'hstwb-cli.zip' -and $script:failOnce){$script:failOnce=$false;throw 'Synthetic rename failure'}
  $script:assets[$id].name=$Body.name
  return $script:assets[$id]
 }
 $old=[pscustomobject]@{assets=@($script:assets[1],$script:assets[2],$script:assets[3])}
 $staged=@(@{Id=11;Name='hstwb-gui-windows.zip';StagingName='pending-gui'},@{Id=12;Name='hstwb-cli.zip';StagingName='pending-cli'},@{Id=13;Name='SHA256SUMS.txt';StagingName='pending-sums'})
 $failed=$false;try{$null=SetDesktopPreviewAssets '/repos/example/project' $old $staged}catch{$failed=$true}
 if(!$failed -or $script:assets[1].name -ne 'hstwb-gui-windows.zip' -or $script:assets[2].name -ne 'hstwb-cli.zip' -or $script:assets[3].name -ne 'SHA256SUMS.txt'){throw 'Failed publication did not restore previous download names.'}
 $changes=SetDesktopPreviewAssets '/repos/example/project' $old $staged
 if($script:assets[11].name -ne 'hstwb-gui-windows.zip' -or $script:assets[12].name -ne 'hstwb-cli.zip' -or $script:assets[13].name -ne 'SHA256SUMS.txt'){throw 'Successful publication did not promote every download.'}
 UndoDesktopPreviewAssets '/repos/example/project' $changes
 if($script:assets[1].name -ne 'hstwb-gui-windows.zip' -or $script:assets[2].name -ne 'hstwb-cli.zip'){throw 'Metadata-failure rollback did not restore previous downloads.'}
}
Write-Host 'PASS: release checksums, stable asset names, successful promotion, and failure rollback without network access.'
[IO.File]::WriteAllText($files[0].Path,'synthetic verified package')
& (Get-Module desktop-release-publishing) {
 param($fixture,$commit)
 $script:head=$commit;$script:tag=$null;$script:release=$null;$script:sequence=100
 function script:InvokePreviewRequest($Method,$Path,$Body=$null,$File=$null,[switch]$AllowMissing){
  if($Path -match '/git/ref/heads/master$'){return @{object=@{sha=$script:head}}}
  if($Path -match '/git/ref/tags/desktop-preview$'){return $script:tag}
  if($Method -eq 'POST' -and $Path -match '/git/refs$'){$script:tag=@{object=@{sha=$Body.sha}};return $script:tag}
  if($Method -eq 'PATCH' -and $Path -match '/git/refs/tags/desktop-preview$'){$script:tag.object.sha=$Body.sha;return $script:tag}
  if($Path -match '/releases/tags/desktop-preview$'){return $script:release}
  if($Path -match '/releases\?per_page=100$'){return @()}
  if($Method -eq 'POST' -and $Path -match '/releases$'){
   if(!$script:tag){throw 'Initial release tag was not created.'}
   $script:release=[pscustomobject]@{id=1;tag_name='desktop-preview';upload_url='https://uploads.github.com/repos/test/repo/releases/1/assets{?name,label}';assets=@();body=$Body.body;draft=$true;prerelease=$true;name=$Body.name};return $script:release
  }
  if($Method -eq 'POST' -and $Path -match '\?name='){
   $script:sequence++;$asset=[pscustomobject]@{id=$script:sequence;name=[uri]::UnescapeDataString(($Path -split '\?name=')[1]);size=(Get-Item $File).Length;state='uploaded';digest=('sha256:'+(Get-FileHash $File).Hash.ToLowerInvariant())};$script:release.assets+=@($asset);return $asset
  }
  if($Method -eq 'PATCH' -and $Path -match '/releases/assets/(\d+)$'){$asset=$script:release.assets | Where-Object id -eq ([int]$Matches[1]);$asset.name=$Body.name;return $asset}
  if($Method -eq 'PATCH' -and $Path -match '/releases/1$'){foreach($key in $Body.Keys){$script:release.$key=$Body[$key]};return $script:release}
  throw ('Unexpected synthetic API request: '+$Method+' '+$Path)
 }
 $null=PublishDesktopPreview 'test/repo' $commit $fixture 'synthetic'
 if($script:release.draft -or $script:release.assets.Count -ne 3 -or 'hstwb-gui-windows.zip' -notin $script:release.assets.name){throw 'First automatic publication failed.'}
 $script:head='0000000000000000000000000000000000000000';$before=$script:sequence
 $null=PublishDesktopPreview 'test/repo' $commit $fixture 'synthetic'
 if($script:sequence -ne $before){throw 'An outdated build published new files.'}
} $fixture $commit
Write-Host 'PASS: first rolling preview publication, uploaded digests, draft promotion, and outdated-build guard.'
