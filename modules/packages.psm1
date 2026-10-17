Class WebClient
{
    [System.Net.WebClient]$webClient
    WebClient() { $this.webClient = New-Object System.Net.WebClient }

    [void]DownloadFile($activity, $url, $path)
    {
        $parent = Split-Path $path -Parent
        if (!(Test-Path -LiteralPath $parent)) { $null = New-Item -ItemType Directory -Path $parent -Force -ErrorAction Stop }
        $temporary = $path + '.' + [guid]::NewGuid().ToString('N') + '.download'
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
            Write-Progress -Activity $activity -Status $url
            $this.webClient.DownloadFile($url, $temporary)
            if ((Get-Item -LiteralPath $temporary).Length -eq 0) { throw 'Download was empty.' }
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
    [WebClient]$webClient
    [string]$packagesDir
    PackageManager($packagesDir) { $this.webClient = [WebClient]::new(); $this.packagesDir = $packagesDir }

    [void]DownloadPackages($packages, $prerelease)
    {
        if (!(Test-Path -LiteralPath $this.packagesDir)) { $null = New-Item -ItemType Directory -Path $this.packagesDir -Force -ErrorAction Stop }
        $downloads = New-Object System.Collections.Generic.List[System.Object]
        foreach ($package in $packages) {
            $releases = @($package.Releases | Where-Object { [string]$_.Prerelease -eq [string][bool]$prerelease })
            if (!$releases.Count -and $prerelease) { $releases = @($package.Releases | Where-Object { [string]$_.Prerelease -eq 'False' }) }
            $release = $releases | Sort-Object { [version]$_.Version } -Descending | Select-Object -First 1
            if (!$release) { continue }
            if ([IO.Path]::GetFileName([string]$release.FileName) -ne $release.FileName -or $release.FileName -match '[/\\:]') { throw 'Invalid package filename in catalog.' }
            if (!([string]$release.FileName).EndsWith('.zip',[StringComparison]::OrdinalIgnoreCase)) { throw 'Standard packages must be ZIP archives.' }
            $downloads.Add(@{Name=$package.Name;Url=$release.Url;FileName=$release.FileName})
        }
        if (!$downloads.Count) { throw 'The package list contains no matching releases. Update the packages list first.' }
        $index = 0
        foreach ($download in $downloads) {
            $this.webClient.DownloadFile(('Downloading package {0}/{1}: {2}' -f ++$index,$downloads.Count,$download.Name),$download.Url,(Join-Path $this.packagesDir $download.FileName))
        }
    }
}
