$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $repo 'modules/data.psm1') -Force
Import-Module (Join-Path $repo 'modules/config.psm1') -Force
function Assert($ok, $message) { if (!$ok) { throw $message } }
$testDir = Join-Path $repo ('.output/media-library-test-' + [guid]::NewGuid().ToString('N'))
$media = Join-Path $testDir 'library'
foreach ($folder in @('library/os/3.2/ADF', 'library/roms/3.2', 'settings')) { New-Item -ItemType Directory (Join-Path $testDir $folder) -Force | Out-Null }
$adf = Join-Path $media 'os/3.2/ADF/renamed.adf'
$rom = Join-Path $media 'roms/3.2/renamed.bin'
[byte[]]$adfBytes = New-Object byte[] 901120
$adfBytes[0]=68; $adfBytes[1]=79; $adfBytes[2]=83; $adfBytes[3]=1
$volume=[Text.Encoding]::ASCII.GetBytes('SyntheticOS'); $adfBytes[0x6e1b0]=$volume.Length
[Array]::Copy($volume,0,$adfBytes,0x6e1b1,$volume.Length)
[IO.File]::WriteAllBytes($adf,$adfBytes)
[IO.File]::WriteAllBytes($rom,[byte[]](1,2,3,4,5,6,7,8))
$adf = (Resolve-Path $adf).Path
$rom = (Resolve-Path $rom).Path
$osCatalog=Join-Path $testDir 'os.csv'; $romCatalog=Join-Path $testDir 'rom.csv'
@([pscustomobject]@{Name='Test OS';Set='Synthetic OS';Md5Hash=(CalculateMd5FromFile $adf);VolumeName='SyntheticOS';Filename='test.adf';Required='True'}) | Export-Csv $osCatalog -Delimiter ';' -NoTypeInformation
@([pscustomobject]@{Name='Test ROM';Set='Synthetic ROM';Md5Hash=(CalculateMd5FromFile $rom);Filename='test.rom';Required='True';Encrypted='No'}) | Export-Csv $romCatalog -Delimiter ';' -NoTypeInformation
$hstwb=@{Settings=@{Installer=@{Mode='Install'};AmigaOs=@{AmigaOsSet='Synthetic OS';TargetVersion='3.2.3'};Kickstart=@{KickstartSet='Synthetic ROM'}};UI=@{AmigaOs=@{};Kickstart=@{}};Assigns=@{};Paths=@{AmigaOsEntriesFile=$osCatalog;KickstartEntriesFile=$romCatalog;SettingsFile=(Join-Path $testDir 'settings/settings.ini');AssignsFile=(Join-Path $testDir 'settings/assigns.ini')}}
$tokens=$null;$errors=$null
$ast=[Management.Automation.Language.Parser]::ParseFile((Join-Path $repo 'setup.ps1'),[ref]$tokens,[ref]$errors)
Assert ($errors.Count -eq 0) 'Setup parse failure'
foreach($name in @('Save','ChangeMediaLibraryDir','RescanMediaLibrary','UseMediaLibraryFolder')) {
 $fn=$ast.Find({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $name},$true)
 Invoke-Expression $fn.Extent.Text
}
# Only replace presentation; discovery and settings are the real implementations.
function FolderBrowserDialog { return $media }
function UiAmigaOsSetInfo { }
function UiKickstartSetInfo { }
ChangeMediaLibraryDir $hstwb
Assert ($hstwb.AmigaOsEntries[0].File -eq $adf) 'Nested OS not found'
Assert ($hstwb.KickstartEntries[0].File -eq $rom) 'Nested renamed ROM not found'
$saved=ReadIniFile $hstwb.Paths.SettingsFile
Assert ($saved.Media.Dir -eq $media) 'Shared folder not saved'
Assert ($saved.AmigaOs.AmigaOsDir -eq $media -and $saved.Kickstart.KickstartDir -eq $media) 'Existing runtime fields not saved'
Assert ($saved.AmigaOs.TargetVersion -eq '3.2.3' -and $saved.Kickstart.KickstartSet -eq 'Synthetic ROM') 'Selection changed during discovery'
$hstwb.Settings.Kickstart.KickstartDir=Join-Path $testDir 'settings'
RescanMediaLibrary $hstwb
Assert (!$hstwb.KickstartEntries[0].File) 'Rescan retained stale ROM match'
UseMediaLibraryFolder $hstwb 'Kickstart'
Assert ($hstwb.KickstartEntries[0].File -eq $rom) 'Returning from override failed'
$volumeEntry=[pscustomobject]@{VolumeName='SyntheticOS';Filename='fallback.adf'}
FindMatchingAmigaOsEntriesByAdfVolumeName @($volumeEntry) $media
Assert ($volumeEntry.File -eq $adf -and $volumeEntry.MatchType -eq 'VolumeName') 'Nested volume fallback failed'
$encryptedDir=Join-Path $media 'encrypted/roms'
New-Item -ItemType Directory $encryptedDir -Force | Out-Null
[byte[]]$plain=20..51
[byte[]]$key=3,5,7
[byte[]]$encoded=New-Object byte[] $plain.Length
for($i=0;$i -lt $plain.Length;$i++) { $encoded[$i]=$plain[$i] -bxor $key[$i % $key.Length] }
$encryptedFile=Join-Path $encryptedDir 'renamed.dat'
$keyFile=Join-Path $encryptedDir 'rom.key'
[IO.File]::WriteAllBytes($encryptedFile,([Text.Encoding]::ASCII.GetBytes('AMIROMTYPE1')+$encoded))
[IO.File]::WriteAllBytes($keyFile,$key)
[IO.File]::WriteAllBytes((Join-Path $media 'rom.key'),[byte[]](11,12,13))
$encryptedEntry=[pscustomobject]@{Md5Hash=(CalculateMd5FromBytes $plain)}
FindMatchingKickstartFileHashes @($encryptedEntry) $media
Assert ($encryptedEntry.File -eq $encryptedFile -and $encryptedEntry.Encrypted -eq 'Yes') 'Nested encrypted ROM not recognized with adjacent key'
Assert ($encryptedEntry.RomKeyFile -eq $keyFile) 'Key path not retained for runtime'
Write-Host 'PASS: recursive OS/ROM discovery, setup persistence, preserved selections, overrides, stale-match removal, and nested volume fallback'
