function InvokePreviewRequest($Method,$Path,$Body=$null,$File=$null,[switch]$AllowMissing){
 $uri=if($Path -like 'https://*'){$Path}else{'https://api.github.com'+$Path}
 if(([uri]$uri).Host -notin @('api.github.com','uploads.github.com')){throw 'Unexpected release API host.'}
 $params=@{Uri=$uri;Method=$Method;Headers=$script:PreviewHeaders;TimeoutSec=300}
 if($File){$params.InFile=$File;$params.ContentType='application/octet-stream'}elseif($null -ne $Body){$params.Body=($Body | ConvertTo-Json -Depth 8 -Compress);$params.ContentType='application/json'}
 try{Invoke-RestMethod @params}catch{if($AllowMissing -and [int]$_.Exception.Response.StatusCode -eq 404){return $null};throw}
}
function GetDesktopReleaseFiles($Directory,$Commit){
 if($Commit -notmatch '^[a-f0-9]{40}$'){throw 'A full source commit is required.'}
 $short=$Commit.Substring(0,12);$files=@();$lines=@()
 foreach($pair in @(@(('hstwb-desktop-win-x64-'+$short+'.zip'),'hstwb-gui-windows.zip'),@(('hstwb-cli-'+$short+'.zip'),'hstwb-cli.zip'))){
  $path=Join-Path $Directory $pair[0]
  if(!(Test-Path -LiteralPath $path) -or !(Test-Path -LiteralPath ($path+'.sha256'))){throw ('Verified release package missing: '+$pair[0])}
  $hash=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
  $expected=((Get-Content -LiteralPath ($path+'.sha256') -Raw).Trim() -split '\s+')[0]
  if($hash -ne $expected){throw ('Release checksum mismatch: '+$pair[0])}
  $files+=@{Path=$path;Name=$pair[1];Hash=$hash};$lines+=$hash+'  '+$pair[1]
 }
 $sums=Join-Path $Directory 'SHA256SUMS.txt';[IO.File]::WriteAllText($sums,(($lines -join "`n")+"`n"))
 $files+=@{Path=$sums;Name='SHA256SUMS.txt';Hash=(Get-FileHash -LiteralPath $sums -Algorithm SHA256).Hash.ToLowerInvariant()}
 return $files
}
function UndoDesktopPreviewAssets($Base,$Changes){
 foreach($item in $Changes.Staged){$null=InvokePreviewRequest PATCH ($Base+'/releases/assets/'+$item.Id) @{name=$item.StagingName}}
 foreach($item in $Changes.Previous){$null=InvokePreviewRequest PATCH ($Base+'/releases/assets/'+$item.Id) @{name=$item.Name}}
}
function SetDesktopPreviewAssets($Base,$Release,$Staged){
 $changes=@{Staged=@($Staged);Previous=@()}
 try{
  foreach($item in $Staged){
   $old=$Release.assets | Where-Object name -eq $item.Name | Select-Object -First 1
   if($old){$record=@{Id=$old.id;Name=$item.Name};$changes.Previous+=@($record);$null=InvokePreviewRequest PATCH ($Base+'/releases/assets/'+$old.id) @{name=('previous-'+$old.id+'-'+$item.Name)}}
   $null=InvokePreviewRequest PATCH ($Base+'/releases/assets/'+$item.Id) @{name=$item.Name}
  }
  return $changes
 }catch{try{UndoDesktopPreviewAssets $Base $changes}catch{Write-Warning 'Release rollback needs attention; the previous assets are retained in the release.'};throw}
}
function PublishDesktopPreview($Repository,$Commit,$Directory,$Token){
 if($Repository -notmatch '^[\w.-]+/[\w.-]+$' -or !$Token){throw 'Repository and release token are required.'}
 $files=@(GetDesktopReleaseFiles $Directory $Commit)
 $script:PreviewHeaders=@{Authorization=('Bearer '+$Token);Accept='application/vnd.github+json';'User-Agent'='HstwbDesktop-AutomaticRelease'}
 $base='/repos/'+$Repository;$tag='desktop-preview';$changes=$null;$tagMoved=$false
 try{
  $head=InvokePreviewRequest GET ($base+'/git/ref/heads/master')
  if($head.object.sha -ne $Commit){Write-Output 'Skipping an older build: master has advanced.';return}
  $oldRef=InvokePreviewRequest GET ($base+'/git/ref/tags/'+$tag) -AllowMissing
  if(!$oldRef){$oldRef=InvokePreviewRequest POST ($base+'/git/refs') @{ref=('refs/tags/'+$tag);sha=$Commit}}
  $release=InvokePreviewRequest GET ($base+'/releases/tags/'+$tag) -AllowMissing
  if(!$release){$release=@(InvokePreviewRequest GET ($base+'/releases?per_page=100')) | Where-Object tag_name -eq $tag | Select-Object -First 1}
  if(!$release){$release=InvokePreviewRequest POST ($base+'/releases') @{tag_name=$tag;target_commitish=$Commit;name='Latest Windows GUI and CLI preview';draft=$true;prerelease=$true;body='Automatic preview publication in progress.'}}
  $oldBody=$release.body;$oldDraft=$release.draft
  $oldRef=InvokePreviewRequest GET ($base+'/git/ref/tags/'+$tag)
  $staged=@();$upload=$release.upload_url -replace '\{.*$',''
  foreach($file in $files){
   $name='pending-'+$Commit.Substring(0,12)+'-'+$file.Name
   $asset=$release.assets | Where-Object name -eq $name | Select-Object -First 1
   if(!$asset){Write-Output ('Uploading '+$file.Name);$asset=InvokePreviewRequest POST ($upload+'?name='+[uri]::EscapeDataString($name)) -File $file.Path}
   if($asset.state -ne 'uploaded' -or $asset.size -ne (Get-Item -LiteralPath $file.Path).Length){throw 'Release upload verification failed.'}
   if($asset.digest -and $asset.digest -ne ('sha256:'+$file.Hash)){throw 'GitHub release digest differs from the verified package.'}
   $staged+=@(@{Id=$asset.id;Name=$file.Name;StagingName=$name})
  }
  $head=InvokePreviewRequest GET ($base+'/git/ref/heads/master')
  if($head.object.sha -ne $Commit){Write-Output 'A newer source commit arrived; existing download links were left unchanged.';return}
  $changes=SetDesktopPreviewAssets $base $release $staged
  $null=InvokePreviewRequest PATCH ($base+'/git/refs/tags/'+$tag) @{sha=$Commit;force=$true};$tagMoved=$true
  $body="Automatically updated after a successful master build.`n`nSource commit: $Commit`n`nGUI: download hstwb-gui-windows.zip, extract everything, then open HstwbDesktop/HstwbDesktop.exe.`n`nCLI: download hstwb-cli.zip, extract everything, then use HstwbCli/setup.cmd and run.cmd on Windows.`n`nThe GUI manual is available offline from Settings. Supply licensed OS/ROM media, an installed emulator, and personal game collections separately. This is an unsigned preview. See SHA256SUMS.txt to verify the downloads.`n`nThe download addresses are permanent; their files are replaced only after a successful build. Private repository downloads require sign-in."
  $null=InvokePreviewRequest PATCH ($base+'/releases/'+$release.id) @{body=$body;draft=$false;prerelease=$true;name='Latest Windows GUI and CLI preview'}
  $current=InvokePreviewRequest GET ($base+'/releases/tags/'+$tag)
  foreach($item in $staged){if(!@($current.assets | Where-Object {$_.id -eq $item.Id -and $_.name -eq $item.Name -and $_.state -eq 'uploaded'}).Count){throw 'Final preview download verification failed.'}}
  # Remove previous or abandoned uploads only after the new release is verified.
  foreach($asset in $current.assets){if($asset.id -notin @($staged | ForEach-Object Id)){try{$null=InvokePreviewRequest DELETE ($base+'/releases/assets/'+$asset.id)}catch{Write-Warning 'An older preview asset was retained.'}}}
  $changes=$null
  Write-Output ('Published: https://github.com/'+$Repository+'/releases/tag/'+$tag)
 }catch{
  if($changes){try{UndoDesktopPreviewAssets $base $changes;if($tagMoved){$null=InvokePreviewRequest PATCH ($base+'/git/refs/tags/'+$tag) @{sha=$oldRef.object.sha;force=$true}};$null=InvokePreviewRequest PATCH ($base+'/releases/'+$release.id) @{body=$oldBody;draft=$oldDraft;prerelease=$true}}catch{Write-Warning 'Preview rollback needs manual review; previous assets have not been deleted.'}}
  throw
 }finally{$script:PreviewHeaders=$null}
}
Export-ModuleMember -Function GetDesktopReleaseFiles,SetDesktopPreviewAssets,UndoDesktopPreviewAssets,PublishDesktopPreview
