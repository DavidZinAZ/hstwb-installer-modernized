# Apply compatibility fixes to extracted upstream scripts, keeping downloaded ZIPs intact.
function UpdateEabPackageInstallScript($path, [bool]$freshInstall)
{
    $encoding = [Text.Encoding]::GetEncoding('ISO-8859-1')
    $text = [IO.File]::ReadAllText($path, $encoding).Replace("`r`n", "`n")
    $pattern = '(?ms)(; Add or update A-(Games(?:Beta)?|Demos(?:Beta)?) (?:to )?assign.*?ELSE\n)(.*?)(\nENDIF)'
    $blocks = [regex]::Matches($text, $pattern)
    if (!$blocks.Count) { throw "Unrecognized EAB assign configuration in $path" }
    for($index=$blocks.Count-1;$index -ge 0;$index--) {
        $match=$blocks[$index]
        $kind = $match.Groups[2].Value
        $variable = '$' + $kind.ToUpperInvariant() + 'DIR'
        $body = $match.Groups[3].Value
        if ($freshInstall) {
            $body = [regex]::Replace($body, '(?m)^  setenv updateassign .*$', '  setenv updateassign 1')
        }
        $guard = '  search SYSTEMDIR:S/Assign-Startup "Assign >NIL: A-' + $kind + ': ' + $variable + '" >NIL:'
        $replacement = $match.Groups[1].Value + $guard + "`n  IF WARN`n" + $body + "`n  ENDIF" + $match.Groups[4].Value
        $text = $text.Substring(0, $match.Index) + $replacement + $text.Substring($match.Index + $match.Length)
    }
    [IO.File]::WriteAllText($path, $text, $encoding)
}
