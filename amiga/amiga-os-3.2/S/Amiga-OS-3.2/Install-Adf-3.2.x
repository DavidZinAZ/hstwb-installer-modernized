; Install Adf 3.2.x
; -----------------
;
; Date: 2026-08-28
; Author: HstWB
;
; AmigaDOS script to automate installation of AmigaOS 3.2.2, 3.2.2.1 and
; 3.2.3 updates from adf files.
;
; Invoked by Install-Update-3.2.x after the host-generated 3.2.x state
; file has been validated. The required update adf depends on the state
; target version. Classes and modules adf files are not installed by
; this release: support for them is deferred until their media behavior
; and installers are independently verified.


; install amiga os 3.2.x update from adf files message
echo ""
echo "*e[1mInstall AmigaOS 3.2.x update from adf files:*e[0m"

; set amigaosdisk to ff0: device
setenv amigaosdisk "ff0"

; set target to state target version
set target `sed -n 's/^[ ]*"TargetVersion": "\(.*\)",*$/\1/p' "INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json"`


; 3.2.2 update
; ------------
IF "$target" EQ "3.2.2"
  ; exit, if required amiga os 3.2.2 update adf doesn't exist
  IF NOT EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-322-update.adf"
    echo "*e[1mError: Required adf file 'INSTALLDIR:Temp/Amiga-OS/amiga-os-322-update.adf' doesn't exist!*e[0m"
    quit 20
  ENDIF

  ; run adf template for amiga os 3.2.2 update adf file
  Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Update3.2.2" "AmigaOS 3.2.2 Update" "INSTALLDIR:Temp/Amiga-OS/amiga-os-322-update.adf"

  SKIP adfdone
ENDIF


; 3.2.2.1 update
; --------------
IF "$target" EQ "3.2.2.1"
  ; exit, if required amiga os 3.2.2.1 update adf doesn't exist
  IF NOT EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-3221-update.adf"
    echo "*e[1mError: Required adf file 'INSTALLDIR:Temp/Amiga-OS/amiga-os-3221-update.adf' doesn't exist!*e[0m"
    quit 20
  ENDIF

  ; run adf template for amiga os 3.2.2.1 update adf file
  Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Update3.2.2.1" "AmigaOS 3.2.2.1 Update" "INSTALLDIR:Temp/Amiga-OS/amiga-os-3221-update.adf"

  SKIP adfdone
ENDIF


; 3.2.3 update
; ------------
IF "$target" EQ "3.2.3"
  ; exit, if required amiga os 3.2.3 update adf doesn't exist
  IF NOT EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-update.adf"
    echo "*e[1mError: Required adf file 'INSTALLDIR:Temp/Amiga-OS/amiga-os-323-update.adf' doesn't exist!*e[0m"
    quit 20
  ENDIF

  ; run adf template for amiga os 3.2.3 update adf file
  Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Update3.2.3" "AmigaOS 3.2.3 Update" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-update.adf"

  SKIP adfdone
ENDIF


; unsupported target
; ------------------
echo "*e[1mError: AmigaOS 3.2.x update adf installation doesn't support target '$target'.*e[0m"
quit 20


; done
; ----
LAB adfdone

; install amiga os 3.2.x update done
echo "Done"
