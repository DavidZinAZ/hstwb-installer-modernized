param([string]$Repository=$env:GITHUB_REPOSITORY,[string]$Commit=$env:GITHUB_SHA,[string]$Directory)
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
if(!$Directory){$Directory=Join-Path $root '.release/desktop'}
if(!$Commit){$Commit=(& git -C $root rev-parse HEAD).Trim()}
Import-Module (Join-Path $PSScriptRoot 'desktop-release-publishing.psm1') -Force
PublishDesktopPreview $Repository $Commit $Directory $env:GH_TOKEN
