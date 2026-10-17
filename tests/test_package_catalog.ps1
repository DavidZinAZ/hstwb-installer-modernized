$ErrorActionPreference='Stop'
Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'modules/package-catalog.psm1') -Force
$module=Get-Module package-catalog
& $module {
 function script:Invoke-WebRequest {
  param($Uri,[switch]$UseBasicParsing,$TimeoutSec,$Headers,$ErrorAction)
  return @{Content='[{"tag_name":"2.0","draft":false,"prerelease":false,"assets":[{"name":"App.2.0.zip","browser_download_url":"https://github.com/example/app/releases/download/2.0/App.2.0.zip"}]},{"tag_name":"3.0-beta","draft":false,"prerelease":true,"assets":[{"name":"App.3.0.zip","browser_download_url":"https://github.com/example/app/releases/download/3.0-beta/App.3.0.zip"}]}]'}
 }
}
$old=[pscustomobject]@{Url='https://obsolete.invalid/catalog';Packages=@([pscustomobject]@{Name='app';Releases=@([pscustomobject]@{Version='1.0';Prerelease='False';FileName='App.1.0.zip';Url='https://github.com/example/app/releases/download/1.0/App.1.0.zip'})})}
$new=UpdateOfficialPackageCatalog $old
if($new.Source -ne 'GitHubReleases' -or $new.Packages[0].Repository -ne 'example/app'){throw 'Incorrect catalog source'}
if(@($new.Packages[0].Releases | Where-Object {$_.Version -eq '2.0' -and $_.Prerelease -eq 'False'}).Count -ne 1){throw 'New stable release not found'}
if(@($new.Packages[0].Releases | Where-Object {$_.Version -eq '3.0' -and $_.Prerelease -eq 'True'}).Count -ne 1){throw 'Prerelease classification lost'}
if(@($new.Packages[0].Releases | Where-Object Version -eq '1.0').Count -ne 1){throw 'Cached historical release lost'}
& $module {function script:Invoke-WebRequest {throw 'Offline'}}
$failed=$false;try{UpdateOfficialPackageCatalog $old}catch{$failed=$true}
if(!$failed -or $old.Packages[0].Releases.Count -ne 1){throw 'Failed refresh altered original catalog'}
Write-Host 'PASS: GitHub refresh finds new stable/prerelease assets, preserves history and leaves cache unchanged on failure'
