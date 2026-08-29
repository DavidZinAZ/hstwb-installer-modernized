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


; read state
; ----------

; get state format version
sed -n 's/^[ ]*"FormatVersion": "\(.*\)",*$/\1/p' "INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json" >T:_32x_state_format
set formatversion `type T:_32x_state_format`

; get state family
sed -n 's/^[ ]*"Family": "\(.*\)",*$/\1/p' "INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json" >T:_32x_state_family
set family `type T:_32x_state_family`

; get state target version
sed -n 's/^[ ]*"TargetVersion": "\(.*\)",*$/\1/p' "INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json" >T:_32x_state_target
set targetversion `type T:_32x_state_target`

; get state source version (may be the literal string null)
sed -n 's/^[ ]*"SourceVersion": "\(.*\)",*$/\1/p' "INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json" >T:_32x_state_source
set sourceversion `type T:_32x_state_source`

; get state kickstart version
sed -n 's/^[ ]*"KickstartVersion": "\(.*\)",*$/\1/p' "INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json" >T:_32x_state_kickstart
set kickstartversion `type T:_32x_state_kickstart`


; validate state
; --------------

; exit, if state format version is missing or not 1.0
IF NOT "$formatversion" EQ "1.0"
  echo "AmigaOS 3.2.x state file format version is '$formatversion', expected 1.0."
  quit 20
ENDIF

; exit, if state family is not AmigaOS 3.2.x
IF NOT "$family" EQ "AmigaOS 3.2.x"
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

; set uae to 1, if uae prefs exist
set uae "0"
IF EXISTS INSTALLDIR:Prefs/UAE
  set uae "1"
ENDIF

; quit uae, if uae is used. otherwise reboot
IF $uae EQ 1 VAL
  echo "UAE will quit in 10 seconds..."
  wait 10
  UAEquit >>SYS:hstwb-installer.log
ELSE
  echo "System will reboot in 10 seconds..."
  wait 10
  TotalReset >>SYS:hstwb-installer.log
ENDIF


; end
; ---
LAB end
