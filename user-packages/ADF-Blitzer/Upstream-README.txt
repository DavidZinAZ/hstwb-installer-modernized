Welcome to the whole new world of ADF-Blitzer 3.x
-------------------------------------------------



Requirements:

  - OS 2+ 
  - 68000


That's all. New: 1 MB RAM is plenty, even with only 512 kb (and a HD) it's still
usable. Also tested under Kick/WB 3.2.
      
      
How to install ADF-Blitzer:

  Drag it to the preferred drive or directory. No external files are needed.


How to use it:

   In the main (and only) window you have two buttons to choose from:
        Left one:  Lets you write an adf-file from your harddisk to your
                   diskdrive (DF0: to DF3:)       
        Right one: Lets you create an adf-file from dfx: (DF0: to DF3:) 
                   to your harddisk
        

Have a look at the menu:

If you want to change the diskdrive which ADF-Blitzer uses, you just 
have to select the proper Menu-Item in the "Drive"-Menu. This menu 
only appears when you actually have more than one drive to choose from.


*********************************************************
ADF-Blitzer has originally been coded by Magnus Lundin 
up to V1.2. As he didn't do a new version I asked him to release the
source code. He sent it (based on V1.1) to me and gave me the
permission to publish new versions.

ADF-Blitzer V2.0 and up are coded by Andreas Gouders (Etzrodt until my
marriage), based on the above mentioned code by Magnus Lundin.



*********************************************************
 ADF-Blitzer is provided "AS IS" without warranty
 of any kind and the author is not responsible for
 any data loss or damage this software may do.

 Commercial use of ADF-Blitzer without my permission 
 is not allowed. This also applies to the inclusion 
 in paid ADF-Toolkits as well as paid WB-Distributions 
 or Toolpacks.
 
 You ARE allowed to include it on any kind of magazine 
 cover disk or CD as long as this readme is included.
*********************************************************



History
-------

changes after more than 23 years:

V3.10 (22-Nov-2024):

- automatic language recognition for German language.
  Everyone with WB2.1 and up running a German Workbench will see
  the localized ADF-Blitzer. Everyone else sees the "normal"
  English version. NO, I'm not gonna add other languages.
  Please don't ask.
  
+ smaller brush-ups:
- changed the status update to make more sense.
- optimized the included gfx so they don't add 20+kb to the exe.
- removed the word "drive" from the window title as the title could be
  too long with a large font. 
- now the ASL Requester always appears on top of the main window 
  instead of the top left corner of the screen.
- and it's now a little bit larger in vertical size.
- the percentage didn't start with 0% but with 1%
- many other small optimizations




V3.00 (17-Nov-2024):

- rewrote 90% of the awful code. Although V2.2 only had 215 lines of code,
  it was a pain to get through. The new version has just under 350 lines 
  and is still much clearer. Though I won't release the code for the
  time being.
  
- A more pleasing GUI without changing the basic function.

- much smaller memory requirement, the whole 880kb file is no longer kept 
  in memory. Instead of needing at least 1.5 MB RAM, 512kb thoretically
  is enough. In tried it with AmiBerry Amiga Emulator with a cofiguration
  of just 512 kb of Chip RAM (no Fast RAM). I was able to boot to Workbench 
  3.1 and still could use ADF-Blitzer without problems.
  
- Disk-operations can be canceled.

- Progress bar with percentage display.

- The drive menu is only displayed if more than one drive is present.
  Furthermore only the devices that are present are listed.
  
- more error messages, so it's safer to use.

- replaced the useless Quit-button (there's a window-close-button anyway)
  with a Pause/Cancel button
  
- The whole thing has been successfully tested under Kick/WB 2.0 to 3.2.


Back in the day:

V2.20 (28-May-2001):
- Now it's possible to select the drive via keyboard
- slightly changed an error message
- added a new error message (if disk is write protected)
- inhibit the drive to prevent other tasks accessing it
- changed "by Lundin/Etzrodt" to "Etzrodt/Lundin" :-)


V2.10 (08-Dec-2000):
- now you can also use DF1-DF3!
- removed a little bug (CPU-consumption)


V2.00 (25-Sep-2000):
- some code-optimizations (removed "Gotos",
  changed the code for the button-check,
  removed some unnecessary variables)
- removed the background-pic (caused some
  trouble with palette)
- improved (?) the GUI a little bit
- added a menu
- added an About-Requester (Menu)
- added a close-gadget at the window-border
- added keyboard-support