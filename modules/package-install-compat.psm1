# Apply compatibility fixes to extracted upstream scripts, keeping downloaded ZIPs intact.
function UpdateEabPackageInstallScript($path, [bool]$freshInstall)
{
    $encoding = [Text.Encoding]::GetEncoding('ISO-8859-1')
    $text = [IO.File]::ReadAllText($path, $encoding).Replace("`r`n", "`n")
    $pattern = '(?ms)(; Add or update A-(Games|Demos) (?:to )?assign.*?ELSE\n)(.*?)(\nENDIF)'
    $match = [regex]::Match($text, $pattern)
    if (!$match.Success) { throw "Unrecognized EAB assign configuration in $path" }
    $kind = $match.Groups[2].Value
    $variable = if ($kind -eq 'Games') { '$GAMESDIR' } else { '$DEMOSDIR' }
    $body = $match.Groups[3].Value
    if ($freshInstall) {
        $body = [regex]::Replace($body, '(?m)^  setenv updateassign .*$', '  setenv updateassign 1')
    }
    $guard = '  search SYSTEMDIR:S/Assign-Startup "Assign >NIL: A-' + $kind + ': ' + $variable + '" >NIL:'
    $replacement = $match.Groups[1].Value + $guard + "`n  IF WARN`n" + $body + "`n  ENDIF" + $match.Groups[4].Value
    $text = $text.Substring(0, $match.Index) + $replacement + $text.Substring($match.Index + $match.Length)
    [IO.File]::WriteAllText($path, $text, $encoding)
}
