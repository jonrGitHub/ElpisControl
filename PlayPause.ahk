; This program Starts Elpis and pauses it - waiting for input from a user or Elpis remote (Android or Windows).  
; It is designed to be part of the startup of a Media Center computer that has been set up to logon automatically 
; (If a user is not logged in, then Elpis can't run - but then, nor could any other media player or DNLA renderer)
; 
; The program is 'self installing' - The first time it runs it tries to locate the Elpis program and (optionally) copy itself to the same directory.
; and creates a shortcut for the current user to start on every logon.
; 
; 
; SelfInstaller - adapted from BettyJ: http://www.autohotkey.com/board/topic/85080-auto-run-at-startup-installer/
; If this is being run via the 'run' entry, it will have an argument 'AutoStart'
; HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\C808785B48DB868F32896B039465FA31
RegRead, ElpisPath, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\C808785B48DB868F32896B039465FA31, 1C4FC0C82823EE544A11FE305B9B9620
if (Errorlevel > 0) 
{
;   Key doesn't exist, try to locate Elpis (later, if ever needed - for now, just exit)
	msgbox, Cannot locate Elpis on this computer.  Please check the installation.`n Aborting.
	ExitApp
}
; Check if the script was called with the argument put into the autostart path.
if 0=0
{
    ; See if this is already installed.
    RegRead, Path, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Run, StartElpis
    ifEqual, Path,
	    RegRead, Path, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Run, StartElpis
    IfNotEqual, Path, %A_ScriptFullPath% AutoStart
    {

        if not A_IsAdmin
    	{
       	    Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+ UAC
       	    ExitApp
    	}

Splash=
(
PlayPause is a program designed to start the wonderful Elpis Pandora client and place it in a paused state.  (see https://github.com/adammhaile/Elpis for more information about the Windows Desktop Pandora Radio Client).

It addresses the situation where the Elpis Pandora client is running on a windows media center to play music but remote control of the music is desired from another computer (see Elpis Control) or via an Android phone (see Elpis Remote -https://github.com/seliver/ElpisRemote).

This program will install PlayPause to run on user logon.  PlayPause will then start Elpis upon windows logon and then pause Elpis, waiting for a play command from a remote.

Prerequisites.
- Elpis must be installed and configured on the computer.  At least one Pandora station must be configured.
- Open the settings screen by selecting the ‘wrench and screwdriver’ icon. the following must be configured:
    o Under Login - Automatically Logon should be selected (the default).
    o Under Pandora - Configure Elpis to Automatically Play Last Station.

To stop Elpis from autostarting, disable the link via the MSCONFIG command.

This program does Not install Elpis, nor does it log a user into windows automatically.  For the latter, autologon.exe from Sysinternals (a Microsoft company) is recommended: http://live.sysinternals.com/autoruns.exe

                                           						Type Y to Continue, N to Cancel
)
	Progress, m2 b C00 w800 fs12 zh0, %Splash%, , , 
	MsgBox, 4, PlayPause Installation, Would you like to install PlayPause?
	IfMsgBox, NO
		ExitApp
	Progress, Off

	; Offer to make it autostart and to copy this file to the elpis directory - if it isn't already there
	SplitPath, ElpisPath,, dir
	if dir!=A_ScriptDir  ; If running from the elpis directory, just assume we should fire up Pandora
	{
		Path := A_ScriptFullPath
		msgbox, 4, PlayPause Installation, Would you like a copy of this program placed in the Elpis directory?`n	%dir%`n(Otherwise the program will be run from it's current location)
		IfMsgBox, YES
		{
			msgbox, Copying %A_ScriptFullPath% `nto `n%dir% 
			FileCopy, %A_ScriptFullPath%, %dir%, 1
			if ErrorLevel
			{
				msgbox, File failed to copy - Error: %A_LastError%
				ExitApp
			}
			Path = %dir%\%A_ScriptName%
		}
		; Now Create a Startup entry to start this every time this guy logs on.
		RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, StartElpis, %Path% AutoStart
;		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Run, StartElpis, %Path% AutoStart
		if errorlevel
		{
			MsgBox, Insufficient priviledges to install.  Please right click the application and select "Run as Administrator"  
		}
		else
		{
			MsgBox, PlayPause will automatically start Elpis in a paused state every time this user logs in.
		}

	}
	
    }

}

; Again, if an argument wasn't supplied, assume this is running interactively
if 0=0
{
	msgbox,4,PlayPause Installation, Would you like start Elpis paused right now?
	IfMsgBox, No
		ExitApp
}


; Get the current Mute state
SoundGet, Mute_State, , MUTE

; Mute the sound system (just in case)
SoundSet, 1, ,MUTE

; Start Elpis
;run, %A_ScriptDir%\Elpis.exe
run, C:\Program Files (x86)\Elpis\Elpis.exe

; If Elpis starting and running an existing station isn't detected, timeout this process and return the Mute state to where it was.  
; Feel free to add more milliseconds if you find that you have a media center even slower than mine.
SetTimer, Endit, 180000

; Wait for Elpis to start and begin a station 
winwait, Elpis |
WinHide
;WinMinimize
Endit:

; Pause Elpis using the global Play/Pause hotkey
;Sendevent, {MEDIA_PLAY_PAUSE} 

; Instead of using the Media Keys, use the HTML interface to send a Pause command - much more reliable.
url = http://Localhost:35747/pause
Loop {
	sleep, 500
	Result := HTMLText(url)
} until (Result="Paused.")


; Return Mute Settings to where it was
sleep, 1000  ; Seems to need a slight pause before turning on the speakers
SoundSet, % Mute_State="ON" ? 1 : 0, ,MUTE

ExitApp

; Function that communications with the remote Elpis program via the HTML COM object - largely stolen from the internet, original source lost - 
; modified to make it asynchronous (prevents program from locking up when elpis isn't started a bad server or URL is provided), and error 
; checking added.
; Note that the AutoHotKey help has a very similar version
HTMLText(url){
	doc := ComObjCreate("HTMLfile")
	pwhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	try pwhr.Open("GET",url, true) 
	catch e
		return, % "E: Cannot Connect"
	try pwhr.Send()
	try pwhr.WaitForResponse()
	catch e
		return, % "E: No Response" 
	doc.write(pwhr.ResponseText)
	text := doc.body.outerText
	return, text	
}


; A little work in progress in case we ever want to search the disk for the Elpis program
FindElpis:
;   ProgramFilesX86 is From: http://www.autohotkey.com/board/topic/79160-a-programfiles-for-programs-in-windows-7-x86-directory/
    ProgramFilesX86 := A_ProgramFiles . (A_PtrSize=8 ? " (x86)" : "")  
	msgbox,ProgramFilesX86
    Srch1  = %ProgramFilesX86%\Elpis\Elpis.exe
    Srch2  = %A_ScriptDir%\Elpis.exe
    Srch3  = "C:\Program Files (x86)\*\Elpis.exe"  ; Won't work - need a file loop.

    loop, 3
    {
	FilePath := Srch%A_Index%
    	IfExist, %FilePath%
	{
		msgbox, Found it %FilePath%
	}
	else
		msgbox,Not Found %FilePath%
    }
return

