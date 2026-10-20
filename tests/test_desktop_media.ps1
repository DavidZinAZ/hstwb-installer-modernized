$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$fixture=Join-Path $root ('.output/desktop-media-test-'+[guid]::NewGuid().ToString('N'))
$nested=Join-Path $fixture 'media/nested'
$null=New-Item -ItemType Directory -Path $nested -Force
$entry=Import-Csv (Join-Path $root 'data/amiga-os-entries.csv') -Delimiter ';' | Where-Object {$_.VolumeName} | Select-Object -First 1
[byte[]]$bytes=New-Object byte[] 901120
$bytes[0]=68;$bytes[1]=79;$bytes[2]=83;$bytes[3]=1
$label=[Text.Encoding]::ASCII.GetBytes($entry.VolumeName)
$bytes[0x6e1b0]=$label.Length
[Array]::Copy($label,0,$bytes,0x6e1b1,$label.Length)
$file=Join-Path $nested 'renamed.adf'
[IO.File]::WriteAllBytes($file,$bytes)
$before=(Get-FileHash -LiteralPath $file).Hash
$request=Join-Path $fixture 'request.json'
ConvertTo-Json -InputObject @((Join-Path $fixture 'media')) | Set-Content $request
$rows=@(& (Join-Path $root 'desktop/bridge.ps1') -Action ScanMedia -RequestFile $request | ConvertFrom-Json)
if(!@($rows | Where-Object {$_.Status -eq 'Detected' -and $_.Match -eq 'VolumeName' -and $_.File -eq $file}).Count){throw 'Nested volume-name detection failed.'}
if(!@($rows | Where-Object {$_.Kind -eq 'Kickstart' -and $_.Status -eq 'Not detected'}).Count){throw 'Missing ROM rows absent.'}
if((Get-FileHash -LiteralPath $file).Hash -ne $before){throw 'Scan modified source media.'}
$empty=Join-Path $fixture 'empty';$null=New-Item -ItemType Directory $empty
ConvertTo-Json -InputObject @($empty) | Set-Content $request
$rows=@(& (Join-Path $root 'desktop/bridge.ps1') -Action ScanMedia -RequestFile $request | ConvertFrom-Json)
if(@($rows | Where-Object {$_.Status -eq 'Detected'}).Count){throw 'Empty folder retained detected entries.'}
$failed=$false
try{& (Join-Path $root 'desktop/media.ps1') -Folder (Join-Path $fixture 'absent') | Out-Null}catch{$failed=$true}
if(!$failed){throw 'Invalid folder accepted.'}
Write-Host 'PASS: desktop bridge detects nested media, reports missing ROMs, preserves files, clears stale matches, and rejects invalid folders.'
