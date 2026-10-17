function UpdateOfficialPackageCatalog($catalog)
{
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $updated=@()
    foreach($package in $catalog.Packages) {
        $repo=[string]$package.Repository
        if(!$repo) {
            $url=@($package.Releases)[0].Url
            if($url -notmatch '^https://github\.com/([^/]+/[^/]+)/releases/download/') { throw ('No GitHub release source for '+$package.Name) }
            $repo=$Matches[1]
        }
        if($repo -notmatch '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$'){throw 'Invalid package repository.'}
        Write-Host ('Checking releases: '+$package.Name)
        $response=Invoke-WebRequest -Uri ('https://api.github.com/repos/'+$repo+'/releases?per_page=100') -UseBasicParsing -TimeoutSec 30 -Headers @{'User-Agent'='hstwb-updated'} -ErrorAction Stop
        $rows=$response.Content | ConvertFrom-Json -ErrorAction Stop
        $releases=@();$keys=@{}
        foreach($row in $rows) {
            if($row.draft -or $row.tag_name -notmatch '^v?(\d+(?:\.\d+){1,3})(?:[-_].*)?$'){continue}
            $version=$Matches[1]
            $assets=@($row.assets | Where-Object {$_.name -match '\.zip$'})
            if($assets.Count -ne 1){continue}
            $asset=$assets[0]
            $releases+=@{Prerelease=[string][bool]$row.prerelease;Version=$version;Url=$asset.browser_download_url;FileName=$asset.name}
            $keys[$version+'|'+[string][bool]$row.prerelease+'|'+$asset.name]=$true
        }
        if(!$releases.Count){throw ('No unambiguous package ZIP releases found for '+$repo)}
        foreach($old in $package.Releases) {
            if(!$keys.ContainsKey($old.Version+'|'+[string]$old.Prerelease+'|'+$old.FileName)){$releases+= $old}
        }
        $updated+=@{Name=$package.Name;Repository=$repo;Releases=@($releases | Sort-Object {[version]$_.Version} -Descending)}
    }
    if(!$updated.Count){throw 'Package catalog is empty.'}
    return @{Date=(Get-Date).ToUniversalTime().ToString('o');CheckedAt=(Get-Date).ToUniversalTime().ToString('o');Description='HstWB packages checked against official GitHub release repositories';Source='GitHubReleases';Packages=$updated}
}
