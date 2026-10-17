; Install Update 3.2.x
; --------------------
;
; Date: 2026-08-28
; Author: HstWB
;
; AmigaDOS script to consume the host-generated AmigaOS 3.2.x release state
; and execute the supported update sequence for AmigaOS 3.2.2, 3.2.2.1 and
; 3.2.3.
;
; The host-side orchestration (run.ps1) writes the state file
; INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json with the target release, source
; release, media sequence, install entry point and Kickstart version. This
; script is the Amiga-side entry point named "Install-Update-3.2.x" in
; data/release-manifest.json.
;
; Supported paths:
;   3.2     -> 3.2.1  (existing Install-Adf-3.2.1 flow, logged as no-op here)
;   3.2     -> 3.2.2  (base installed by existing flow, then this update)
;   3.2.1   -> 3.2.2  (3.2.1 installed by existing flow, then this update)
;   3.2.2   -> 3.2.2.1 (installer-driven update, installed 3.2.2 required)
;   3.2     -> 3.2.3  (base installed by existing flow, then this update)
;   3.2.1   -> 3.2.3  (3.2.1 installed by existing flow, then this update)
;   3.2.2   -> 3.2.3  (3.2.2 installed by this flow, then this update)
;
; Unsupported:
;   3.2.2.1 -> 3.2.3  (unverified edge, explicitly rejected)


; exit, if host-generated 3.2.x state file doesn't exist
IF NOT EXISTS "INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json"
  echo "No AmigaOS 3.2.x state file found. No AmigaOS 3.2.x update to run."
  SKIP end
ENDIF


; A failure must not reach the normal completion marker.
echo "Update has not completed" >INSTALLDIR:Prefs/Install-Failed

; read state
; ----------

; get state format version
Search "INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json" "FormatVersion" NONUM >T:_32x_line
sed "s/ //g;s/*"//g;s/,//g;s/FormatVersion://" T:_32x_line >T:_32x_state_format
Copy T:_32x_state_format INSTALLDIR:Temp/State-FormatVersion.txt
set formatversion `type T:_32x_state_format`

; get state family
Search "INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json" "Family" NONUM >T:_32x_line
sed "s/ //g;s/*"//g;s/,//g;s/Family://" T:_32x_line >T:_32x_state_family
Copy T:_32x_state_family INSTALLDIR:Temp/State-Family.txt
set family `type T:_32x_state_family`

; get state target version
Search "INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json" "TargetVersion" NONUM >T:_32x_line
sed "s/ //g;s/*"//g;s/,//g;s/TargetVersion://" T:_32x_line >T:_32x_state_target
Copy T:_32x_state_target INSTALLDIR:Temp/State-TargetVersion.txt
set targetversion `type T:_32x_state_target`

; get state source version (may be the literal string null)
Search "INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json" "SourceVersion" NONUM >T:_32x_line
sed "s/ //g;s/*"//g;s/,//g;s/SourceVersion://" T:_32x_line >T:_32x_state_source
Copy T:_32x_state_source INSTALLDIR:Temp/State-SourceVersion.txt
set sourceversion `type T:_32x_state_source`

; get state kickstart version
Search "INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json" "KickstartVersion" NONUM >T:_32x_line
sed "s/ //g;s/*"//g;s/,//g;s/KickstartVersion://" T:_32x_line >T:_32x_state_kickstart
Copy T:_32x_state_kickstart INSTALLDIR:Temp/State-KickstartVersion.txt
set kickstartversion `type T:_32x_state_kickstart`


; validate state
; --------------

; exit, if state format version is missing or not 1.0
IF NOT "$formatversion" EQ "1.0"
  echo "AmigaOS 3.2.x state file format version is '$formatversion', expected 1.0."
  quit 20
ENDIF

; exit, if state family is not AmigaOS 3.2.x
IF NOT "$family" EQ "AmigaOS3.2.x"
  echo "AmigaOS 3.2.x state file family is '$family', expected AmigaOS 3.2.x."
  quit 20
ENDIF

; exit, if state target version is missing
IF "$targetversion" EQ ""
  echo "AmigaOS 3.2.x state file is missing a target version."
  quit 20
ENDIF


; 3.2 base target
; ---------------
; the 3.2 base install is already handled by the existing Install-Adf or
; Install-Disk flow in Install-Amiga-OS-3.2. nothing to do here.
IF "$targetversion" EQ "3.2"
  echo "AmigaOS 3.2 base is already installed by the existing install flow. Nothing to do."
  SKIP end
ENDIF


; 3.2.1 target
; ------------
; the 3.2 -> 3.2.1 update is already handled by the existing Install-Adf-3.2.1
; flow in Install-Amiga-OS-3.2. nothing to do here.
IF "$targetversion" EQ "3.2.1"
  echo "AmigaOS 3.2.1 is already installed by the existing 3.2.1 update flow. Nothing to do."
  SKIP end
ENDIF


; 3.2.2 target
; ------------
; requires an installed 3.2 or 3.2.1 (installed by the existing flow above)
IF "$targetversion" EQ "3.2.2"
  IF NOT "$sourceversion" EQ "3.2"
    IF NOT "$sourceversion" EQ "3.2.1"
      echo "AmigaOS 3.2.2 requires installed AmigaOS 3.2 or 3.2.1, but state source is '$sourceversion'."
      quit 20
    ENDIF
  ENDIF

  echo "Installing AmigaOS 3.2.2 update from installed AmigaOS $sourceversion (Kickstart $kickstartversion)..."

  ; run install amiga os 3.2.x adf
  execute "INSTALLDIR:S/Amiga-OS-3.2/Install-Adf-3.2.x"
  IF WARN
    quit 20
  ENDIF

  ; update amiga os version prefs to 3.2.2
  echo "3.2.2" NOLINE >SYSTEMDIR:Prefs/AmigaOS

  ; create amiga os 3.2.2 prefs
  echo "" NOLINE >INSTALLDIR:Prefs/Amiga-OS-3.2.2

  SKIP reboot
ENDIF


; 3.2.2.1 target
; --------------
; 3.2.2.1 is an installer-driven update requiring installed AmigaOS 3.2.2.
; it is not standalone base media. the update requires installed
; version.library 47.4.
IF "$targetversion" EQ "3.2.2.1"
  IF NOT "$sourceversion" EQ "3.2.2"
    echo "AmigaOS 3.2.2.1 is an installer-driven update requiring installed AmigaOS 3.2.2, but state source is '$sourceversion'."
    quit 20
  ENDIF

  ; exit, if installed version.library is not at least v47.4
  IF NOT EXISTS "SYSTEMDIR:Libs/version.library"
    echo "AmigaOS 3.2.2.1 update requires installed version.library, which doesn't exist."
    quit 20
  ENDIF
  Version >NIL: "SYSTEMDIR:Libs/version.library" 47 4
  IF NOT $RC EQ 0 VAL
    echo "AmigaOS 3.2.2.1 update requires installed version.library v47.4 or newer."
    quit 20
  ENDIF

  echo "Installing AmigaOS 3.2.2.1 update from installed AmigaOS 3.2.2 (Kickstart $kickstartversion)..."

  ; run install amiga os 3.2.x adf
  execute "INSTALLDIR:S/Amiga-OS-3.2/Install-Adf-3.2.x"
  IF WARN
    quit 20
  ENDIF

  ; update amiga os version prefs to 3.2.2.1
  echo "3.2.2.1" NOLINE >SYSTEMDIR:Prefs/AmigaOS

  ; create amiga os 3.2.2.1 prefs
  echo "" NOLINE >INSTALLDIR:Prefs/Amiga-OS-3.2.2.1

  SKIP reboot
ENDIF


; 3.2.3 target
; ------------
; requires an installed 3.2, 3.2.1 or 3.2.2. the 3.2.2.1 -> 3.2.3 edge is
; unverified and explicitly rejected below.
IF "$targetversion" EQ "3.2.3"
  IF NOT "$sourceversion" EQ "3.2"
    IF NOT "$sourceversion" EQ "3.2.1"
      IF NOT "$sourceversion" EQ "3.2.2"
        IF "$sourceversion" EQ "3.2.2.1"
          echo "AmigaOS 3.2.3 from installed AmigaOS 3.2.2.1 is not supported. The 3.2.2.1 -> 3.2.3 update path is unverified."
          quit 20
        ENDIF
        echo "AmigaOS 3.2.3 requires installed AmigaOS 3.2, 3.2.1 or 3.2.2, but state source is '$sourceversion'."
        quit 20
      ENDIF
    ENDIF
  ENDIF

  echo "Installing AmigaOS 3.2.3 update from installed AmigaOS $sourceversion (Kickstart $kickstartversion)..."

  ; run install amiga os 3.2.x adf
  execute "INSTALLDIR:S/Amiga-OS-3.2/Install-Adf-3.2.x"
  IF WARN
    quit 20
  ENDIF

  ; update amiga os version prefs to 3.2.3
  echo "3.2.3" NOLINE >SYSTEMDIR:Prefs/AmigaOS

  ; create amiga os 3.2.3 prefs
  echo "" NOLINE >INSTALLDIR:Prefs/Amiga-OS-3.2.3

  SKIP reboot
ENDIF


; unsupported target version
; --------------------------
echo "AmigaOS 3.2.x state target '$targetversion' is not a supported AmigaOS 3.2.x update."
quit 20


; reboot
; ------
; the 3.2.x updates write Update/Release state and require a reboot.
LAB reboot

echo ""
echo "AmigaOS 3.2.x update is complete."
echo "The system must reboot to finish the update."
echo ""

; Return to the normal installer for completion and cleanup before reboot.

; end
; ---
LAB end
Delete >NIL: INSTALLDIR:Prefs/Install-Failed
