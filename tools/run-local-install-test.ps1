param(
    [string]$SettingsDir,
    [switch]$PrepareOnly
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
Set-Location $repo
if (!$SettingsDir) { $SettingsDir = Join-Path $repo '.output/local-base32/settings' }
$SettingsDir = (Resolve-Path -LiteralPath $SettingsDir).Path
Import-Module ./modules/config.psm1 -Force
Import-Module ./modules/data.psm1 -Force

# Every invocation owns a new image, settings, temporary files, and logs.
$runId = (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0, 8)
$runDir = Join-Path $repo ('.output/local-tests/' + $runId)
if (Test-Path -LiteralPath $runDir) { throw 'Test directory already exists.' }
foreach ($folder in @('image', 'settings', 'temp', 'logs')) {
    $null = New-Item -ItemType Directory -Path (Join-Path $runDir $folder)
}
Copy-Item -LiteralPath (Join-Path $SettingsDir 'hstwb-installer-settings.ini') -Destination (Join-Path $runDir 'settings')
Copy-Item -LiteralPath (Join-Path $SettingsDir 'hstwb-installer-assigns.ini') -Destination (Join-Path $runDir 'settings')
$env:TEMP = Join-Path $runDir 'temp'
$env:TMP = $env:TEMP
Start-Transcript -Path (Join-Path $runDir 'logs/host-transcript.txt')

try {
    # Use setup's existing image-creation implementation; replace only its
    # prompts with the predetermined test template and new output directory.
    $tokens = $null; $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $repo 'setup.ps1'), [ref]$tokens, [ref]$parseErrors)
    if ($parseErrors.Count) { throw 'Setup contains parse errors.' }
    foreach ($name in @('CreateImageDirectoryFromImageTemplate', 'Save')) {
        $fn = $ast.Find({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $name }, $true)
        Invoke-Expression $fn.Extent.Text
    }
    function Menu($hstwb, $title, $options, $returnIndex) {
        for ($i = 0; $i -lt $options.Count; $i++) {
            if ($options[$i] -match '^2GB:.*DH0 \(100MB DOS') { return $i }
        }
        throw 'Bundled 2GB DOS7 template not found.'
    }
    function FolderBrowserDialog { return (Join-Path $runDir 'image') }
    function ConfirmDialog { throw 'Unexpected overwrite confirmation.' }
    function Read-Host { return '' }
    $settingsFile = Join-Path $runDir 'settings/hstwb-installer-settings.ini'
    $assignsFile = Join-Path $runDir 'settings/hstwb-installer-assigns.ini'
    $hstwb = @{
        Images = (ReadImages (Join-Path $repo 'images'))
        Settings = (ReadIniFile $settingsFile)
        Assigns = (ReadIniFile $assignsFile)
        Paths = @{ SettingsFile = $settingsFile; AssignsFile = $assignsFile }
    }
    CreateImageDirectoryFromImageTemplate $hstwb
    Write-Host "Fresh test directory: $runDir"
    if ($PrepareOnly) { return }

    function Start-Process {
        param($FilePath, $ArgumentList, [switch]$Wait, [switch]$NoNewWindow)
        # Refuse a second emulator launch against this test's image.
        $marker = [IO.File]::Open((Join-Path $runDir 'launched-once'), [IO.FileMode]::CreateNew, [IO.FileAccess]::Write)
        $marker.Dispose()
        $generated = @(Get-ChildItem (Join-Path $runDir 'temp') -Recurse -Filter 'hstwb-installer.uae')
        if ($generated.Count -ne 1) { throw 'Expected one generated WinUAE configuration.' }
        $config = Get-Content -LiteralPath $generated[0].FullName
        if (@($config | Where-Object { $_ -eq 'floppy_speed=0' }).Count -ne 1) { throw 'Generated configuration does not use Turbo floppy speed.' }
        Copy-Item -LiteralPath $generated[0].FullName -Destination (Join-Path $runDir 'logs/generated-install.uae')
        $image = Get-Content (Join-Path $runDir 'image/hstwb-image.json') -Raw | ConvertFrom-Json
        foreach ($drive in $image.Harddrives | Where-Object { $_.Type -eq 'hdf' }) {
            $diskPath = Join-Path $runDir ('image/' + $drive.Path)
            if (!(Test-Path -LiteralPath $diskPath)) { throw 'Fresh image disk missing.' }
            $writeReady = $false
            $consecutivePasses = 0
            for ($attempt = 0; $attempt -lt 60; $attempt++) {
                try {
                    $probe = [IO.File]::Open($diskPath, [IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
                    $probe.Dispose()
                    $consecutivePasses++
                    if ($consecutivePasses -ge 10) { $writeReady = $true; break }
                    Start-Sleep -Milliseconds 500
                }
                catch {
                    $accessError = $_.Exception.GetBaseException().Message
                    $consecutivePasses = 0
                    if ($attempt -eq 0) { Write-Host "Waiting for disk access: $accessError" }
                    Start-Sleep -Milliseconds 500
                }
            }
            if (!$writeReady) { throw "Disk unavailable before launch: $accessError" }
        }
        Write-Host 'Verified fresh image, exclusive write access, and floppy_speed=0.'
        Microsoft.PowerShell.Management\Start-Process -FilePath $FilePath -ArgumentList ($ArgumentList + ' -log -logfile -s harddrive_write_protect=false -s absolute_mouse=mousehack -s magic_mouse=true') -Wait:$Wait -NoNewWindow:$NoNewWindow -PassThru -RedirectStandardOutput (Join-Path $runDir 'logs/winuae-stdout.txt') -RedirectStandardError (Join-Path $runDir 'logs/winuae-stderr.txt')
    }
    & (Join-Path $repo 'run.ps1') -settingsDir (Join-Path $runDir 'settings')
}
catch {
    Write-Host $_.Exception.Message
    Write-Host $_.ScriptStackTrace
    throw
}
finally { Stop-Transcript }
