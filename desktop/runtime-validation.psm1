# This snapshot is passed in memory from the final GUI validation to the installer.
# It is never loaded from the remembered scan cache.
function NewDesktopRuntimeValidation($hstwb,$userNames){
 $paths=@($hstwb.AmigaOsEntries | ForEach-Object File)+@($hstwb.KickstartEntries | ForEach-Object File)+@($hstwb.KickstartEntries | ForEach-Object RomKeyFile)+@($hstwb.Packages.Values | ForEach-Object PackageFile)
 $stamps=@(foreach($path in @($paths | Where-Object {$_} | Sort-Object -Unique)){$file=Get-Item -LiteralPath $path -ErrorAction Stop;@{Path=$file.FullName;Length=$file.Length;Ticks=$file.LastWriteTimeUtc.Ticks}})
 return @{Packages=$hstwb.Packages;AmigaOsEntries=$hstwb.AmigaOsEntries;KickstartEntries=$hstwb.KickstartEntries;SelectedUserNames=@($userNames);Stamps=$stamps}
}
function AssertDesktopRuntimeValidation($snapshot){
 if(!$snapshot -or !$snapshot.Stamps.Count){throw 'Installer validation snapshot is missing.'}
 foreach($stamp in $snapshot.Stamps){$file=Get-Item -LiteralPath $stamp.Path -ErrorAction Stop;if($file.PSIsContainer -or $file.Length -ne $stamp.Length -or $file.LastWriteTimeUtc.Ticks -ne $stamp.Ticks){throw ('A validated file changed during image creation. Validate again: '+$stamp.Path)}}
}
Export-ModuleMember -Function NewDesktopRuntimeValidation,AssertDesktopRuntimeValidation
