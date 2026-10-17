Import-Module (Join-Path $PSScriptRoot 'bestclassicwb.psm1')

Class WebClient
{
    [System.Net.WebClient]$webClient
    WebClient() { $this.webClient = New-Object System.Net.WebClient }

    [void]DownloadFile($activity, $url, $path)
    {
        $this.DownloadPackageFile($activity, $url, $path, '', '')
    }

    [void]DownloadPackageFile($activity, $url, $path, $adapter, $version)
    {
        $parent = Split-Path $path -Parent
        if (!(Test-Path -LiteralPath $parent)) { $null = New-Item -ItemType Directory -Path $parent -Force -ErrorAction Stop }
        $temporary = $path + '.' + [guid]::NewGuid().ToString('N') + '.download'
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
            Write-Progress -Activity $activity -Status $url
            $request=[Net.WebRequest]::Create($url)
            $request.Timeout=30000
            if($request -is [Net.HttpWebRequest]) { $request.ReadWriteTimeout=30000; $request.UserAgent='hstwb-updated' }
            $response=$request.GetResponse()
            try {
                $inputStream=$response.GetResponseStream()
                $outputStream=[IO.File]::Open($temporary,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
                try {
                    $buffer=New-Object byte[] 65536
                    $total=[long]0;$nextProgress=[datetime]::MinValue
                    while(($read=$inputStream.Read($buffer,0,$buffer.Length)) -gt 0) {
                        $outputStream.Write($buffer,0,$read);$total+=$read
                        if((Get-Date) -ge $nextProgress) {
                            $status=('{0:N1} MB received' -f ($total/1MB))
                            $percent=0
                            if($response.ContentLength -gt 0) {
                                $status=('{0:N1} / {1:N1} MB' -f ($total/1MB),($response.ContentLength/1MB))
                                $percent=[Math]::Min(100,[int](100*$total/$response.ContentLength))
                            }
                            Write-Progress -Activity $activity -Status $status -PercentComplete $percent
                            $nextProgress=(Get-Date).AddMilliseconds(500)
                        }
                    }
                    if($response.ContentLength -ge 0 -and $total -ne $response.ContentLength){throw 'Download ended before all bytes arrived.'}
                } finally {$inputStream.Dispose();$outputStream.Dispose()}
            } finally {$response.Dispose()}
            if ((Get-Item -LiteralPath $temporary).Length -eq 0) { throw 'Download was empty.' }
            if ($adapter) {
                if ($adapter -ne 'BestClassicWB-2.1.12') { throw 'Unknown standard package adapter.' }
                ConvertBestClassicWbArchive $temporary $version
            }
            if ([IO.Path]::GetExtension($path) -eq '.zip') {
                Add-Type -AssemblyName System.IO.Compression.FileSystem
                Add-Type -AssemblyName System.IO.Compression
                $zipType = 'System.IO.Compression.ZipFile' -as [type]
                $archive = $zipType::OpenRead($temporary)
                try {
                    $manifest = $archive.Entries | Where-Object { $_.FullName -match '(^|/)hstwb-package\.json$' } | Select-Object -First 1
                    if (!$manifest) { throw 'Downloaded ZIP is not an HstWB package.' }
                    $reader = New-Object IO.StreamReader($manifest.Open())
                    $metadata = $null
                    try { $metadata = $reader.ReadToEnd() | ConvertFrom-Json -ErrorAction Stop }
                    finally { $reader.Dispose() }
                    if (!$metadata.Name -or !$metadata.Version) { throw 'Downloaded package metadata is incomplete.' }
                    try { $null = [version]$metadata.Version } catch { throw 'Downloaded package version is invalid.' }
                }
                finally { $archive.Dispose() }
            }
            if (Test-Path -LiteralPath $path) {
                $backup = $path + '.' + (Get-Date -Format 'yyyyMMddHHmmss') + '.' + [guid]::NewGuid().ToString('N').Substring(0,8) + '.previous'
                [IO.File]::Replace($temporary, $path, $backup)
            } else { [IO.File]::Move($temporary, $path) }
        }
        finally {
            if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force }
            Write-Progress -Activity $activity -Completed
        }
    }
}

Class PackageManager
{
    [int]$DownloadedCount
    [int]$SkippedCount
    [int]$StableFallbackCount
    [WebClient]$webClient
    [string]$packagesDir
    PackageManager($packagesDir) { $this.webClient = [WebClient]::new(); $this.packagesDir = $packagesDir }

    [void]DownloadPackages($packages, $prerelease)
    {
        $this.StableFallbackCount=0
        if (!(Test-Path -LiteralPath $this.packagesDir)) { $null = New-Item -ItemType Directory -Path $this.packagesDir -Force -ErrorAction Stop }
        $downloads = New-Object System.Collections.Generic.List[System.Object]
        foreach ($package in $packages) {
            $releases = @($package.Releases | Where-Object { [string]$_.Prerelease -eq [string][bool]$prerelease })
            if (!$releases.Count -and $prerelease) {
                $releases = @($package.Releases | Where-Object { [string]$_.Prerelease -eq 'False' })
                $this.StableFallbackCount++
            }
            $release = $releases | Sort-Object { [version]$_.Version } -Descending | Select-Object -First 1
            if (!$release) { continue }
            if ([IO.Path]::GetFileName([string]$release.FileName) -ne $release.FileName -or $release.FileName -match '[/\\:]') { throw 'Invalid package filename in catalog.' }
            if (!([string]$release.FileName).EndsWith('.zip',[StringComparison]::OrdinalIgnoreCase)) { throw 'Standard packages must be ZIP archives.' }
            $downloads.Add(@{Name=$package.Name;Version=$release.Version;Url=$release.Url;FileName=$release.FileName;Adapter=$package.Adapter})
        }
        if (!$downloads.Count) { throw 'The package list contains no matching releases. Update the packages list first.' }
        if($this.StableFallbackCount -gt 0) { Write-Host ('{0} packages have no prerelease; using their latest stable releases.' -f $this.StableFallbackCount) }
        $index = 0
        $this.DownloadedCount=0;$this.SkippedCount=0
        foreach ($download in $downloads) {
            $index++
            $destination=Join-Path $this.packagesDir $download.FileName
            if($this.HasPackageVersion($destination,$download.Version,$download.Name)) {
                Write-Host ('Already current: {0} v{1}' -f $download.Name,$download.Version)
                $this.SkippedCount++;continue
            }
            Write-Host ('Downloading {0}/{1}: {2} v{3}' -f $index,$downloads.Count,$download.Name,$download.Version)
            $this.webClient.DownloadPackageFile(('Downloading package {0}/{1}: {2}' -f $index,$downloads.Count,$download.Name),$download.Url,$destination,$download.Adapter,$download.Version)
            $this.DownloadedCount++
        }
    }

    [bool]HasPackageVersion($path,$version,$name)
    {
        if(!(Test-Path -LiteralPath $path -PathType Leaf)){return $false}
        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $zipType='System.IO.Compression.ZipFile' -as [type]
            $archive=$zipType::OpenRead($path)
            try {
                $manifest=$archive.Entries | Where-Object {$_.FullName -match '(^|/)hstwb-package\.json$'} | Select-Object -First 1
                if(!$manifest){return $false}
                $reader=New-Object IO.StreamReader($manifest.Open())
                $metadata=$null
                try {$metadata=$reader.ReadToEnd() | ConvertFrom-Json -ErrorAction Stop} finally {$reader.Dispose()}
                $expected=($name.ToLower() -replace '-package$','') -replace '[^a-z0-9]',''
                $actual=([string]$metadata.Name).ToLower() -replace '[^a-z0-9]',''
                return ($actual -eq $expected -and [version]$metadata.Version -eq [version]$version)
            } finally {$archive.Dispose()}
        } catch {return $false}
    }
}
