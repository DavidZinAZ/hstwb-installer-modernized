param([switch]$BuildOnly)
$ErrorActionPreference='Stop'
$framework=Join-Path $env:WINDIR 'Microsoft.NET/Framework64/v4.0.30319'
$source=Join-Path $PSScriptRoot 'App.cs'
Import-Module (Join-Path $PSScriptRoot '../modules/version.psm1') -Force
$version=HstwbInstallerVersion
if($version -notmatch '^\d+\.\d+\.\d+(?:-[A-Za-z0-9.-]+)?$'){throw 'Invalid installer version.'}
$number=($version -split '-')[0]
$buildId=(Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.Substring(0,12).ToLowerInvariant()+'-'+$version
$out=Join-Path $PSScriptRoot ('../.output/desktop/builds/'+$buildId)
$null=New-Item -ItemType Directory -Path $out -Force
$executable=Join-Path $out 'HstwbDesktop.exe'
if(!(Test-Path -LiteralPath $executable)){
 $versionSource=Join-Path $out 'Version.cs'
 [IO.File]::WriteAllText($versionSource,('public static class DesktopVersion { public const string Number="'+$number+'"; public const string Display="'+$version+'"; }'))
 $refs=@('System.dll','System.Core.dll','System.Web.Extensions.dll','WPF/WindowsBase.dll','WPF/PresentationCore.dll','WPF/PresentationFramework.dll','System.Xaml.dll','System.Windows.Forms.dll','System.IO.Compression.dll','System.IO.Compression.FileSystem.dll') | ForEach-Object {'/reference:'+(Join-Path $framework $_)}
 & (Join-Path $framework 'csc.exe') /nologo /target:winexe /out:"$executable" $refs $source $versionSource
 if($LASTEXITCODE -ne 0){throw 'Desktop build failed.'}
}
[IO.File]::WriteAllText((Join-Path $PSScriptRoot '../.output/desktop/latest.txt'),[IO.Path]::GetFullPath($executable))
Write-Output ([IO.Path]::GetFullPath($executable))
if(!$BuildOnly){Start-Process -FilePath $executable -ArgumentList ('"'+(Split-Path $PSScriptRoot -Parent)+'"') -WorkingDirectory (Split-Path $PSScriptRoot -Parent) -WindowStyle Normal}
