# User-package source updates. Archive payloads remain local; no downloaded code runs on the host.
function GetUserPackageCatalog($path) {
    $catalog = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json -ErrorAction Stop
    if ($catalog.FormatVersion -ne 1) { throw 'Unsupported user-package catalog format.' }
    return $catalog.Packages
}

function GetUserPackageWebContent($url) {
    if (([uri]$url).Scheme -ne 'https') { throw 'Update sources must use HTTPS.' }
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    return Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30 -Headers @{'User-Agent'='hstwb-updated'} -ErrorAction Stop
}

function CompareSoftwareVersion($left, $right) {
    # Preserve upstream labels; compare numeric segments and documented suffixes.
    $pattern = '^v?(\d+(?:\.\d+)*)(?:(pre|beta|rc)(\d+)|([a-z]))?$'
    $a = [regex]::Match([string]$left,$pattern,'IgnoreCase'); $b = [regex]::Match([string]$right,$pattern,'IgnoreCase')
    if (!$a.Success -or !$b.Success) { throw 'Upstream version needs manual comparison.' }
    $av=@($a.Groups[1].Value.Split('.') | ForEach-Object {[int]$_}); $bv=@($b.Groups[1].Value.Split('.') | ForEach-Object {[int]$_})
    for($i=0;$i -lt [Math]::Max($av.Count,$bv.Count);$i++) {
        $x=if($i -lt $av.Count){$av[$i]}else{0}; $y=if($i -lt $bv.Count){$bv[$i]}else{0}
        if($x -ne $y){return [Math]::Sign($x-$y)}
    }
    $ar=if($a.Groups[2].Success){@{pre=1;beta=2;rc=3}[$a.Groups[2].Value.ToLower()]}else{4}
    $br=if($b.Groups[2].Success){@{pre=1;beta=2;rc=3}[$b.Groups[2].Value.ToLower()]}else{4}
    if($ar -ne $br){return [Math]::Sign($ar-$br)}
    if($ar -lt 4){return [Math]::Sign(([int]$a.Groups[3].Value)-([int]$b.Groups[3].Value))}
    return [Math]::Sign([string]::Compare($a.Groups[4].Value,$b.Groups[4].Value,$true))
}

function GetAvailableUserPackageRelease($component) {
    if($component.Provider -eq 'Manual'){throw $component.Reason}
    if($component.Provider -eq 'GitHub') {
        $releases=(GetUserPackageWebContent ('https://api.github.com/repos/'+$component.Repository+'/releases')).Content | ConvertFrom-Json
        $release=$releases | Where-Object {!$_.draft -and !$_.prerelease -and $_.tag_name -match $component.TagPattern} | Select-Object -First 1
        if(!$release){throw 'No compatible stable release found.'}
        $version=[regex]::Match($release.tag_name,$component.TagPattern).Groups[1].Value
        $assets=@($release.assets | Where-Object {$_.name -match $component.AssetPattern})
        if($assets.Count -ne 1){throw 'A unique compatible release asset was not found.'}
        $sha=if($assets[0].digest -match '^sha256:([a-fA-F0-9]{64})$'){$Matches[1]}else{$null}
        return @{Version=$version;ReleaseDate=$release.published_at;Url=$assets[0].browser_download_url;Sha256=$sha;MetadataUrl=$release.html_url}
    }
    if($component.Provider -eq 'Aminet') {
        $response=$null;$usedUrl=$null
        foreach($base in @('https://aminet.net/','https://de.aminet.net/aminet/')) {
            try {$usedUrl=$base+$component.AminetPath+'.readme';$response=GetUserPackageWebContent $usedUrl;break}catch{}
        }
        if(!$response){throw 'Aminet metadata is unavailable; no local files were changed.'}
        $match=[regex]::Match($response.Content,'(?im)^Version:\s*([^\r\n]+)')
        if(!$match.Success){throw 'The author supplies no software version; manual review is required.'}
        if($response.Content -match '(?im)^Architecture:' -and $response.Content -notmatch '(?im)^Architecture:.*m68k-amigaos'){throw 'Source does not advertise an Amiga 68k build.'}
        return @{Version=$match.Groups[1].Value.Trim();ReleaseDate=$null;Url=($usedUrl -replace '\.readme$',$component.Extension);Sha256=$null;MetadataUrl=$usedUrl}
    }
    if($component.Provider -eq 'Web') {
        $response=GetUserPackageWebContent $component.MetadataUrl
        $match=[regex]::Match($response.Content,$component.VersionPattern,'IgnoreCase')
        if(!$match.Success){throw 'The official source version could not be verified.'}
        return @{Version=$match.Groups[1].Value;ReleaseDate=$null;Url=$component.DownloadUrl;Sha256=$null;MetadataUrl=$component.MetadataUrl}
    }
    throw 'No supported source adapter.'
}

function GetUserPackageLocalState($directory) {
    $path=Join-Path $directory '_update-state.json'
    if(Test-Path -LiteralPath $path){return Get-Content -LiteralPath $path -Raw | ConvertFrom-Json -ErrorAction Stop}
    return $null
}

function GetUserPackageUpdateResults($packagesRoot, $catalog) {
    if(!$packagesRoot -or !(Test-Path -LiteralPath $packagesRoot -PathType Container)){return}
    foreach($package in $catalog) {
        $directory=Join-Path $packagesRoot $package.Directory
        if(!(Test-Path -LiteralPath (Join-Path $directory '_installdir'))){continue}
        $state=$null;$stateError=$null
        try{$state=GetUserPackageLocalState $directory}catch{$stateError=$_.Exception.Message}
        foreach($component in $package.Components) {
            $result=@{Package=$package;Component=$component;Directory=$directory;LocalVersion=$component.Version;Release=$null;Status='Review required';Message=''}
            if($stateError){$result.Message='Unreadable local update metadata: '+$stateError;[pscustomobject]$result;continue}
            if($component.Provider -eq 'Manual') {
                $result.Message=$component.Reason
                [pscustomobject]$result
                continue
            }
            try {
                $saved=$state.Components | Where-Object {$_.Id -eq $component.Id} | Select-Object -First 1
                $file=Join-Path $directory $component.LocalFile
                $expectedHash=if($saved){$saved.Sha256}else{$component.BaselineSha256}
                if($saved){$result.LocalVersion=$saved.Version}
                $localKnown=$expectedHash -and (Test-Path -LiteralPath $file) -and ((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash -eq $expectedHash)
                $result.Release=GetAvailableUserPackageRelease $component
                if($component.AutoUpdate -eq $false){$result.Status='Compatibility review required';$result.Message=$component.Reason}
                elseif(!$localKnown){$result.Status='Local version unverified';$result.Message='Local payload differs from known metadata; review before replacing.'}
                elseif(!$result.LocalVersion){$result.Status='Date-only release';$result.Message='No author version is available; package revision is tracked separately.'}
                else {
                    $comparison=CompareSoftwareVersion $result.Release.Version $result.LocalVersion
                    $result.Status=if($comparison -gt 0){'Update available'}elseif($comparison -eq 0){'Current'}else{'Local version is newer'}
                }
            } catch {$result.Message=$_.Exception.Message}
            [pscustomobject]$result
        }
    }
    if(Test-Path -LiteralPath $packagesRoot -PathType Container) {
        foreach($directory in Get-ChildItem -LiteralPath $packagesRoot -Directory) {
            if((Test-Path -LiteralPath (Join-Path $directory.FullName '_installdir')) -and !@($catalog | Where-Object {$_.Directory -eq $directory.Name}).Count) {
                [pscustomobject]@{Package=@{Directory=$directory.Name};Component=@{Name=$directory.Name};Directory=$directory.FullName;LocalVersion=$null;Release=$null;Status='Unmanaged package';Message='No source catalog entry is configured. Add verified metadata before automatic updates.'}
            }
        }
    }
}

function AssertUserPackageRelativePath($path) {
    if(!$path -or [IO.Path]::IsPathRooted($path) -or $path -match '(^|[/\\])\.\.([/\\]|$)|[:\x00]'){throw 'Unsafe package path.'}
}

function GetLhaArchiveMembers($path) {
    [byte[]]$bytes=[IO.File]::ReadAllBytes($path);$offset=0;$found=$false
    # Some original packages are Amiga self-extracting LhA archives.
    while($offset -le [Math]::Min(65536,$bytes.Length-26)) {
        if([Text.Encoding]::ASCII.GetString($bytes,$offset+2,5) -match '^-(lh[0-7d]|lz[45s])-\z' -and $bytes[$offset+20] -le 2){$found=$true;break}
        $offset++
    }
    if(!$found){throw 'Download is not a supported LhA archive.'}
    $members=New-Object 'System.Collections.Generic.List[string]'
    while($offset+26 -le $bytes.Length -and [Text.Encoding]::ASCII.GetString($bytes,$offset+2,5) -match '^-(lh[0-7d]|lz[45s])-\z') {
        $level=$bytes[$offset+20];$packed=[BitConverter]::ToUInt32($bytes,$offset+7)
        $header=if($level -eq 2){[BitConverter]::ToUInt16($bytes,$offset)}else{[int]$bytes[$offset]+2}
        if($header -lt 24 -or [long]$offset+$header+$packed -gt $bytes.Length){throw 'Truncated LhA archive.'}
        $name='';$dir=''
        if($level -lt 2) {
            $length=$bytes[$offset+21]
            if(22+$length -gt $header){throw 'Invalid LhA filename.'}
            $name=[Text.Encoding]::GetEncoding(28591).GetString($bytes,$offset+22,$length)
        }
        if($level -gt 0) {
            $size=if($level -eq 2){[BitConverter]::ToUInt16($bytes,$offset+24)}else{[BitConverter]::ToUInt16($bytes,$offset+$header-2)}
            $cursor=if($level -eq 2){$offset+26}else{$offset+$header}
            $limit=if($level -eq 2){$offset+$header}else{$offset+$header+$packed}
            $extensions=0
            while($size -gt 0) {
                if($size -lt 3 -or $cursor+$size -gt $limit -or ++$extensions -gt 256){throw 'Invalid LhA extended header.'}
                $kind=$bytes[$cursor]
                if($kind -eq 1){$name=[Text.Encoding]::GetEncoding(28591).GetString($bytes,$cursor+1,$size-3)}
                if($kind -eq 2){$dir=[Text.Encoding]::GetEncoding(28591).GetString($bytes,$cursor+1,$size-3).Replace([char]255,'/')}
                $next=[BitConverter]::ToUInt16($bytes,$cursor+$size-2);$cursor+=$size;$size=$next
            }
        }
        $member=($dir+$name).Replace('\','/'); AssertUserPackageRelativePath $member
        if([Text.Encoding]::ASCII.GetString($bytes,$offset+2,5) -ne '-lhd-' -and [BitConverter]::ToUInt32($bytes,$offset+11) -gt 0){$members.Add($member)}
        $offset+=$header+$packed
    }
    if(!$members.Count){throw 'Archive contains no compatible members.'}
    return $members.ToArray()
}

function SaveUserPackageDownload($url,$path) {
    if(([uri]$url).Scheme -ne 'https'){throw 'Update downloads must use HTTPS.'}
    Invoke-WebRequest -Uri $url -OutFile $path -UseBasicParsing -TimeoutSec 120 -Headers @{'User-Agent'='hstwb-updated'} -ErrorAction Stop
}

function InstallUserPackageSourceUpdate($result) {
    if($result.Status -ne 'Update available'){throw 'This item is not a verified newer release.'}
    $component=$result.Component;$release=$result.Release;$original=[IO.Path]::GetFullPath($result.Directory)
    $root=Split-Path $original -Parent
    AssertUserPackageRelativePath $result.Package.Directory
    AssertUserPackageRelativePath $component.LocalFile
    if((Get-Item -LiteralPath $original).Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Updating linked package directories is not supported.'}
    # Recheck after selection, including source version and local file identity.
    $fresh=GetAvailableUserPackageRelease $component
    if($fresh.Version -ne $release.Version -or $fresh.Url -ne $release.Url){throw 'Source changed since the check. Check for updates again.'}
    $currentState=GetUserPackageLocalState $original
    $saved=$currentState.Components | Where-Object {$_.Id -eq $component.Id} | Select-Object -First 1
    $expected=if($saved){$saved.Sha256}else{$component.BaselineSha256}
    if((Get-FileHash -LiteralPath (Join-Path $original $component.LocalFile) -Algorithm SHA256).Hash -ne $expected){throw 'Local package changed since the check.'}
    $id=[guid]::NewGuid().ToString('N')
    $work=Join-Path $root ('.updates/staging/'+$id)
    $null=New-Item -ItemType Directory -Path $work -Force
    $stage=Join-Path $work 'package'
    Copy-Item -LiteralPath $original -Destination $stage -Recurse -ErrorAction Stop
    $download=Join-Path $work 'download'
    SaveUserPackageDownload $release.Url $download
    if((Get-Item -LiteralPath $download).Length -eq 0){throw 'Downloaded payload is empty.'}
    $hash=(Get-FileHash -LiteralPath $download -Algorithm SHA256).Hash
    if($release.Sha256 -and $hash -ne $release.Sha256){throw 'Upstream SHA256 verification failed.'}
    $newRoot=if($component.RootTemplate){$component.RootTemplate.Replace('{version}',$release.Version)}else{''}
    if($component.Mode -eq 'ZipFiles') {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $archive=[IO.Compression.ZipFile]::OpenRead($download)
        try {
            foreach($map in $component.Files) {
                AssertUserPackageRelativePath $map.Target
                $matches=@($archive.Entries | Where-Object {$_.Name -eq $map.MemberName -and $_.Length -gt 0})
                if($matches.Count -ne 1){throw ('Missing or ambiguous ZIP member: '+$map.MemberName)}
                $inputStream=$matches[0].Open();$output=[IO.File]::Create((Join-Path $stage $map.Target))
                try{$inputStream.CopyTo($output)}finally{$inputStream.Dispose();$output.Dispose()}
            }
        } finally {$archive.Dispose()}
    } elseif ($component.Mode -eq 'RawFile') {
        $bytes=[IO.File]::ReadAllBytes($download)
        if ($bytes.Length -lt 32) { throw 'Downloaded binary is too small.' }
        if ($component.MagicHex) {
            $magic=([BitConverter]::ToString($bytes,0,4)).Replace('-','')
            if ($magic -ne $component.MagicHex) { throw 'Downloaded binary has an unexpected format.' }
        }
        Copy-Item -LiteralPath $download -Destination (Join-Path $stage $component.LocalFile) -Force
    } else {
        if ($component.Mode -eq 'ZipArchive') {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $archive=[IO.Compression.ZipFile]::OpenRead($download)
            try {
                $members=@($archive.Entries | ForEach-Object {
                    AssertUserPackageRelativePath ($_.FullName.TrimEnd('/'))
                    if ($_.Name -and $_.Length -gt 0) { $_.FullName }
                })
            } finally { $archive.Dispose() }
        } else { $members=@(GetLhaArchiveMembers $download) }
        foreach($required in $component.RequiredMembers) {
            $pattern=$required.Replace('{root}',$newRoot)
            if(!@($members | Where-Object {$_ -like $pattern}).Count){throw ('New archive is incompatible with the installer: missing '+$pattern)}
        }
        Copy-Item -LiteralPath $download -Destination (Join-Path $stage $component.LocalFile) -Force
        foreach($replacement in $component.InstallerReplacements) {
            $script=Join-Path $stage '_install';$text=[IO.File]::ReadAllText($script)
            if($text.Contains($replacement.Old)){$text=$text.Replace($replacement.Old,$replacement.New)}
            elseif(!$text.Contains($replacement.New)){throw 'Installer layout was modified; manual review is required.'}
            [IO.File]::WriteAllText($script,$text,(New-Object Text.UTF8Encoding($false)))
        }
        if($newRoot) {
            $oldRoot=if($saved.ArchiveRoot){$saved.ArchiveRoot}else{$component.InstalledRoot}
            $script=Join-Path $stage '_install';$text=[IO.File]::ReadAllText($script)
            if(!$text.Contains($oldRoot+'/')){throw 'Installer root layout was modified; manual review is required.'}
            $text=$text.Replace($oldRoot+'/',$newRoot+'/').Replace($oldRoot+'.info',$newRoot+'.info')
            [IO.File]::WriteAllText($script,$text,(New-Object Text.UTF8Encoding($false)))
        }
    }
    $records=@($currentState.Components | Where-Object {$_ -and $_.Id -ne $component.Id})
    $payloadHash=(Get-FileHash -LiteralPath (Join-Path $stage $component.LocalFile) -Algorithm SHA256).Hash
    $records+=@{Id=$component.Id;Version=$release.Version;ReleaseDate=$release.ReleaseDate;Sha256=$payloadHash;SourceUrl=$release.Url;ArchiveRoot=$newRoot;CheckedAt=(Get-Date).ToUniversalTime().ToString('o')}
    $revision=if($currentState.PackageVersion){[version]$currentState.PackageVersion}else{[version]$result.Package.PackageVersion}
    $nextVersion='{0}.{1}.{2}' -f $revision.Major,$revision.Minor,([Math]::Max(0,$revision.Build)+1)
    $newState=@{FormatVersion=1;PackageVersion=$nextVersion;Components=$records}
    [IO.File]::WriteAllText((Join-Path $stage '_update-state.json'),($newState|ConvertTo-Json -Depth 8),(New-Object Text.UTF8Encoding($false)))
    $backup=Join-Path $root ('.updates/backups/'+[IO.Path]::GetFileName($original)+'-'+(Get-Date -Format 'yyyyMMddHHmmss')+'-'+$id)
    $null=New-Item -ItemType Directory -Path (Split-Path $backup -Parent) -Force
    if(!$backup.StartsWith($root+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Invalid backup destination.'}
    Move-Item -LiteralPath $original -Destination $backup -ErrorAction Stop
    try{Move-Item -LiteralPath $stage -Destination $original -ErrorAction Stop}
    catch{Move-Item -LiteralPath $backup -Destination $original -ErrorAction Stop;throw}
    return $backup
}
