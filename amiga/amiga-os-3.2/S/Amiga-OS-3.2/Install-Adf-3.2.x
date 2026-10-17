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
; The 3.2.3 update also installs its companion disks through Adf-Template.


; install amiga os 3.2.x update from adf files message
echo ""
echo "*e[1mInstall AmigaOS 3.2.x update from adf files:*e[0m"

; set amigaosdisk to ff0: device
setenv amigaosdisk "ff0"

; set target to state target version
Search "INSTALLDIR:Prefs/AmigaOS-3.2.x-State.json" "TargetVersion" NONUM >T:_32x_line
sed "s/ //g;s/*"//g;s/,//g;s/TargetVersion://" T:_32x_line >T:_32x_target
set target `Type T:_32x_target`


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
    IF WARN
      quit 20
    ENDIF

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
    IF WARN
      quit 20
    ENDIF

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
    IF WARN
      quit 20
    ENDIF

  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-classes.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Classes3.2.3" "AmigaOS 3.2.3 Classes3.2.3" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-classes.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-disk-doctor.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "DiskDoctor3.2.3" "AmigaOS 3.2.3 DiskDoctor3.2.3" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-disk-doctor.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-extras.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Extras3.2.3" "AmigaOS 3.2.3 Extras3.2.3" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-extras.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-cz.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Locale3.2.3" "AmigaOS 3.2.3 Locale3.2.3-CZ" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-cz.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-de.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Locale3.2.3" "AmigaOS 3.2.3 Locale3.2.3-DE" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-de.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-dk.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Locale3.2.3" "AmigaOS 3.2.3 Locale3.2.3-DK" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-dk.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-en.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Locale3.2.3" "AmigaOS 3.2.3 Locale3.2.3-EN" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-en.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-es.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Locale3.2.3" "AmigaOS 3.2.3 Locale3.2.3-ES" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-es.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-fr.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Locale3.2.3" "AmigaOS 3.2.3 Locale3.2.3-FR" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-fr.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-gr.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Locale3.2.3" "AmigaOS 3.2.3 Locale3.2.3-GR" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-gr.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-it.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Locale3.2.3" "AmigaOS 3.2.3 Locale3.2.3-IT" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-it.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-nl.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Locale3.2.3" "AmigaOS 3.2.3 Locale3.2.3-NL" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-nl.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-no.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Locale3.2.3" "AmigaOS 3.2.3 Locale3.2.3-NO" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-no.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-pl.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Locale3.2.3" "AmigaOS 3.2.3 Locale3.2.3-PL" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-pl.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-pt.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Locale3.2.3" "AmigaOS 3.2.3 Locale3.2.3-PT" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-pt.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-rs.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Locale3.2.3" "AmigaOS 3.2.3 Locale3.2.3-RS" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-rs.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-ru.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Locale3.2.3" "AmigaOS 3.2.3 Locale3.2.3-RU" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-ru.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-se.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Locale3.2.3" "AmigaOS 3.2.3 Locale3.2.3-SE" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-se.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-tr.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Locale3.2.3" "AmigaOS 3.2.3 Locale3.2.3-TR" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-tr.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-uk.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Locale3.2.3" "AmigaOS 3.2.3 Locale3.2.3-UK" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-locale-uk.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-modules-a1200.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Modules3.2.3" "AmigaOS 3.2.3 ModulesA1200_3.2.3" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-modules-a1200.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-modules-a2000.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Modules3.2.3" "AmigaOS 3.2.3 ModulesA2000_3.2.3" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-modules-a2000.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-modules-a3000.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Modules3.2.3" "AmigaOS 3.2.3 ModulesA3000_3.2.3" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-modules-a3000.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-modules-a4000d.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Modules3.2.3" "AmigaOS 3.2.3 ModulesA4000D_3.2.3" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-modules-a4000d.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-modules-a4000t.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Modules3.2.3" "AmigaOS 3.2.3 ModulesA4000T_3.2.3" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-modules-a4000t.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-modules-a500.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Modules3.2.3" "AmigaOS 3.2.3 ModulesA500_3.2.3" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-modules-a500.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-modules-a600.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Modules3.2.3" "AmigaOS 3.2.3 ModulesA600_3.2.3" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-modules-a600.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF
  IF EXISTS "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-modules-cd32.adf"
    Execute "INSTALLDIR:S/Amiga-OS-3.2/Adf-Template" "Modules3.2.3" "AmigaOS 3.2.3 ModulesCD32_3.2.3" "INSTALLDIR:Temp/Amiga-OS/amiga-os-323-modules-cd32.adf"
    IF WARN
      quit 20
    ENDIF
  ENDIF

  SKIP adfdone
ENDIF


; unsupported target
; ------------------
echo "*e[1mError: AmigaOS 3.2.x update adf installation doesn't support target '$target'.*e[0m"
quit 20


; done
; ----
LAB adfdone

; Record actual installed file versions, independently of the release preference.
Version "SYSTEMDIR:Libs/version.library" FILE >INSTALLDIR:Temp/Update-Installed-Versions.log
Version "SYSTEMDIR:Classes/window.class" FILE >>INSTALLDIR:Temp/Update-Installed-Versions.log
Version "SYSTEMDIR:Tools/TextEdit" FILE >>INSTALLDIR:Temp/Update-Installed-Versions.log
Version "SYSTEMDIR:C/DiskDoctor" FILE >>INSTALLDIR:Temp/Update-Installed-Versions.log

; install amiga os 3.2.x update done
echo "Done"
