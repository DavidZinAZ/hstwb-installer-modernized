# Inherited imager source

This directory contains the original experimental .NET/Electron imager. It is
separate from the maintained Windows desktop installer in `desktop/` and the
PowerShell CLI. The desktop/CLI release builder does not include this tree.

The October 20, 2026 dependency review identified known advisories in this
inherited source. Its prerelease workflow is disabled pending dependency updates
and separate validation. See [dependency review](../docs/dependency-review.md).
Do not use its old build instructions as the supported desktop download path.

## Original development references

### image/harddisk tools

https://github.com/discutils/discutils
https://applegazette.com/mac/pro-terminal-commands-using-diskutil/

# net core

https://gunnarpeipman.com/dotnet-core-self-contained-executable/

# Console UI

https://itnext.io/terminal-console-user-interface-in-net-core-4e978f1225b
https://github.com/migueldeicaza/gui.cs
