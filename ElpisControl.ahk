; Elpis Control
;
; This is a Windows based remote control for the very nice Elpis program that plays music from Pandora.  https://github.com/adammhaile/Elpis
; 
; Why a windows remote control for a windows program?  This allows Elpis to run on a Media Center (with the nice sound system) - yet be 
; controlled from the windows computer one is working on.
;
; Two dialogs are provided - the main one for choosing the media computer to connect to and showing album art.  A 'compact' one taking only a 
; line of screen space with limited functions.
;
; 'Developed' in AutoHotkey, which should allow easy modification to address any customizations desired.  
;
; Thrown together with few apologies using codes samples from around the web, it does not serve as a respectable example of coding design.  
; Available Characters for controls ||][ ☺►≥→☺☝☟☹➧➷➨➩➻➼➽」「〉》➘➚➥  - stored in the source code for easy customization


; Some initial values.
Compact=0

; Directive to the compiler to store and extract this bitmap file (if not compiled, it copies it from the working directory)
FileInstall ElpisStart.jpg,%A_Temp%\ElpisStart.jpg,0
FileInstall main_icon1.ico,%A_Temp%\main_icon1.ico,0

; Change the icon shown on the window, Alt-Tab, and, ideally, the task bar.
Menu, Tray, Icon, %A_Temp%\main_icon1.ico, , 1" 

; Enable ToolTips
OnMessage(0x200, "WM_MOUSEMOVE")

; Check if a stored value for the current server is sitting in the registry, if so, retrieve it and make it the default
RegRead, ServerList, HKEY_CURRENT_USER\Software\ElpisControl, Server
if (Errorlevel != 0) 
	ServerList = Elpis Computer||

; Create the initial Screen
gosub CreateBig
; Disable all the controls (other than the server name entry) until a server connection is established
gosub Disable


; Transparent control?  Give it a try if you want.  I didn't find it useful (hence the creation of the compact view).
Transparent=0
if (Transparent)
	WinSet, AlwaysOnTop, On, Elpis Control
Return



; Everything else is event driven.

CreateBig:
; Original version of the Interface was created with SmartGuiCreator from meet_rajat@gawab.com - http://www.autohotkey.com/board/topic/738-smartgui-creator/
; Find the number of rows (servers) in the list
junk := StrReplace(ServerList, "|", ,ServerRows)
Msgbox %ServerList% %junk% ServerRows = %ServerRows%
;*************************************************************************************
; Create and display the Big user interface 
;Gui, -SysMenu
;Gui, +ToolWindow
;BackgroundTrans 
Gui, Add, ComboBox, vServ gAutoComplete x23 y5 w100 h20 r%ServerRows% hwndhcbx, %ServerList%
Serv_TT := "Enter the Name/IP of the computer running Elpis."
Gui, Add, Button, vConnect x124 y5 h20 gButtonConnect default,›
Connect_TT := "Connect to the computer running Elpis"
Gui, Add, Text, vStatus y9 w120 h20 +Center
Gui, Add, Button, vb1 x22 y119 w100 h30 , &Play
b1_TT:="Play Selection"
Gui, Add, Button, vb2 x22 y149 w100 h30 , P&ause
b2_TT:="Pause Selection"
Gui, Add, Button, vb3 x22 y179 w100 h30 , &Next
b3_TT:="Fast Forward to Next Selection"
Gui, Add, Button, vb4 x22 y209 w100 h30 , &Like
b4_TT:=FavIcon_TT
Gui, Add, Button, vb5 x22 y239 w100 h30 , &DisLike
b5_TT:="Mark as 'Disliked'"
Gui, Add, Text, vStation x22 y280 w240 h30 +Center, Station
Station_TT:="Pandora Station currently selected.  Use full Elpis program (not this remote) to change stations"
Gui, Add, Button, vFavIcon gButtonFavIcon cGreen x20 y29 w20 h20 , %FavIconVal%
Gui, Font, S14
Gui, Add, Text, vSong gGetSongInfo x42 y29 w245 h30 -wrap, Selection
Gui, Add, Text, vArtist gGetArtistInfo x42 y54 w245 h30 -wrap, Artist
Gui, Add, Text, vAlbum gGetAlbumInfo x42 y79 w230 h40 -wrap, Album
Song_TT:="Click on the title to get additional information about the selection"
Artist_TT:="Click on the Artist name to get additional information about the Artist"
Album_TT:="Click on the Album title to get additional information about the album"


; Compact Button
;Gui, Add, Button, vb6 gCompact x290 y280 h20 w20, ➚
Gui, Add, Button, vb6 gCompact x290 y5 h20 w20, ➚
b6_TT := "Activate Compact View"

; Titles
Gui, Font, s10 witalic
Gui, Add, Text, cGreen x22 y60 w20 h30, By
Gui, Add, Text, cGreen x22 y83 w20 h30, On

; For the starting album picture, grab a generic design stored with the application
Gui, Add, Picture, vAlbumArt gGetSongInfo x132 y119 w150 h150 , %A_Temp%\ElpisStart.jpg
AlbumArt_TT:="Click on the picture to get additional information about the selection"

; Generated using SmartGUI Creator 4.0
; Display the user interface.
Gui, Show, x127 y87 h301 w310, Elpis Control
Compact=0

return



; Create the Compact View (when called)
CreateSmall:
Gui, -Caption +AlwaysOnTop		;+ToolWindow  
Gui, Add, Button, vb3 gButtonNext x22 y7 w20 h20 , >>
b3_TT:="Fast Forward to Next Selection"
Gui, Add, Button, vb1 gButtonToggle x2 y7 w20 h20 , %PlayIcon%
b1_TT:="Play / Pause"
Gui, Add, Button, vFavIcon gButtonFavIcon cGreen HWNDHB1 x42 y7 w20 h20, %FavIconVal%
Gui, Add, Text, vSong gGetSongInfo x64 y10 w200 h20 -wrap HWNDH1, Selection
Gui, Add, Text, vArtist gGetArtistInfo x64 y35 w200 h20 -wrap HWNDH2, Artist
Gui, Add, Text, vAlbum gGetAlbumInfo x64 y35 w200 h20 -wrap HWNDH3, Album
Song_TT:="Click on the title to get additional information about the selection"
Artist_TT:="Click on the Artist name to get additional information about the Artist"
Album_TT:="Click on the Album title to get additional information about the album"
; Gui, Add, Text, vStatus x64 y10 w200 h20 -wrap hidden, 

Gui, Add, Button,  gBIG x288 y18 w12 h12 ,➘
BIG_TT:="Return to Full view"
Gui, Add, Button, vb5 gButtonDisLike x270 y7 w19 h20 , ☹
b5_TT:="Mark as 'Disliked'"
; Generated using SmartGUI Creator 4.0
Gui, Font, s6 witalic
; These are not used unless code is uncommented in RotateText
;Gui, Add, Text, cGreen x44 y35 w20 h10 HWNDHB2, BY
;Gui, Add, Text, cGreen x44 y35 w20 h10 HWNDHB3, ON

; if the Compact was repositioned manually in the past, use that same location.
RegRead, tx, HKEY_CURRENT_USER\Software\ElpisControl, CompactPositionX
RegRead, ty, HKEY_CURRENT_USER\Software\ElpisControl, CompactPositionY
; Otherwise put in default values
;x:= tx ? tx : A_ScreenWidth - 200 
x:= tx ? tx : 200 
;y:=ty ? ty : A_ScreenHeight - 70 ; Would like to put it at the bottom of the screen, but differing screens makes that risky - let the user drag it to where it is wanted.
y:=ty ? ty : 0 
Gui, Show, x%x% y%y% h30 w299, Elpis Control Compact

; Store the current window in a global variable 
Gui, 1:+LastFound		; Hmmm - why is this still needed if not using a control group?
CompactWin := WinExist() 	; Get the window info
; Create a control group for identifying this GUI control
;Gui1_ID := WinExist()
;GroupAdd, Compact_Gui, ahk_id %Gui1_ID%
;WinGetPos, EWD_WinX, EWD_WinY,,, ahk_id %Gui1_ID%
;msgbox, EWD_WinX %EWD_WinX%

Compact=1
gosub DisplayStatus
SetTimer, RotateText, 5000	;Start a thread that adds some bling to the user interface.
;WinSet, AlwaysOnTop,On,Elpis Control Compact
return



RotateText:
; Rotate between Song, Artist, and Album  
pos1=10
pos2=40

Num1++
if (Num1>3)
	Num1:=1
W1:=H%Num1%
;;WB1:=HB%Num1%
Num2:=mod(Num1,3)+1
W2:=H%Num2%
;;WB2:=HB%Num2%
; For scrolling 'On' and 'By' buttons, comment the line below, and uncomment the other lines in this
GuiControl,,FavIcon, % Num2=1 ? FavIconVal : (Num2=2 ? "By" : "On")
Loop, 30
{
    ControlMove, , , % pos1--, , ,ahk_id %W1%
;;    ControlMove, , , % pos1-3, , ,ahk_id %WB1%
    ControlMove, , , % pos2--, , ,ahk_id %W2%
;;   ControlMove, , , % pos2-3, , ,ahk_id %WB2%
}

return




;**********************************************************************
;  Handle User Events 

; Default Action when a Server Name is entered:
ButtonConnect:
; In case someone goes up and changes a connected server to a new one, reset to initial conditions.
gosub Disable

; Try to connect to the server name entered.
GuiControlGet, Server,, Serv
Stat:=Control("connect")

; If there is a connection problem, we return an error message starting with 'E:'
if (SubStr(Stat,1,2)="E:")
	return

 

; Update the status (it should have come back as 'true')
GuiControl,, Status, %Server% Connected.



; Enable the user interface buttons
Gosub Enable

; Update the Dropdown List with the most recent Server
ServerList :=  StrReplace(StrReplace(ServerList,"Elpis Computer||"),"||","|")
ServerList :=  Server . "||" . RegExReplace(ServerList,"i)" . Server . "\|+")

; Update the ComboBox
GuiControl,, Serv,|%ServerList%

; Store the 'last' server name in the registr
RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\ElpisControl, Server, %ServerList%





; Get the current information from the remote Elpis program - Repeat every 5000 ms
Gosub DisplayStatus
SetTimer,DisplayStatus,5000
return

ButtonPlay:
Control("play")
PlayIcon:= "]["
Gosub DisplayStatus
return

ButtonPause:
Control("pause")
PlayIcon:= "➧" 
return

ButtonNext:
Control("next")
Gosub DisplayStatus
return

ButtonFavIcon:
Gosub ButtonLike
return

ButtonLike:
Stat:=Control("like")
; Set 'like' status here to show an immediate change (The DisplayStatus value may take a few seconds to update)
if (Stat = "Liked")
	{
		Stat := "No longer Liked"
		GuiControl,, Status, %Stat%
		if Compact
			ScreenDetectToolTip(stat)
		FavIconVal:="-"
		FavIcon_TT="Mark as 'Liked'"
		b4_TT:=FavIcon_TT
	}
	else
	{
		if (Stat = "Like")	; Just in case there was a failure
			FavIconVal:="☺"
			FavIcon_TT:="Identified as 'Liked'.  Click to Remove 'Liked' Designation"
			b4_TT:="Remove 'Liked' Designation"
	}
	GuiControl,,FavIcon,%FavIconVal%

; Block DisplayStatus Updates for 10 seconds or so because we get faulty data for a bit - do this by merely resetting the timer
SetTimer,DisplayStatus,5000

return


ButtonDisLike:
Control("dislike")
return

;If the Picture or Song Title is clicked, open a browswer with the Song information 
; Compact and 
GetSongInfo:
Gosub DragWindow
if NOT Dragging
    run,% json(DStatus,"SongDetailUrl")
return

GetArtistInfo:
Gosub DragWindow
if NOT Dragging
    run,% json(DStatus,"ArtistDetailUrl")
return

GetAlbumInfo:
Gosub DragWindow
if NOT Dragging
    run,% json(DStatus,"AlbumDetailUrl")
return


ButtonToggle:
Stat:=Control("toggleplaypause")
PlayIcon:= Stat="Paused." ? "➧" : "]["
GuiControl,,b1,%PlayIcon%
return




GuiClose:
ExitApp



Disable:
; Reset Global Variables 
PlayIcon:="➧"
FavIconVal:="-"
FavIcon_TT="Mark as 'Liked'"
b4_TT:=FavIcon_TT
; Load the startup Graphic
; GuiControl,,AlbumArt,%A_Temp%\ElpisStart.jpg

; Disable all the buttons 'b1'-'b5' and FavIcon
loop,6
	GuiControl, disable, b%A_Index%
GuiControl, disable, FavIcon
return

Enable:
; Enable all the buttons 'b1'-'b5' and FavIcon
loop,6
	GuiControl, enable, b%A_Index%
GuiControl, enable, FavIcon
return


Compact:
; Switch to the small display
Gui, Destroy
gosub CreateSmall
return

Big:
; Switch to the large display
SetTimer, RotateText, Off
Gui, Destroy
gosub CreateBig
; Kill the old Album Art filename (can we say non-modular code here?) so that the picture is re-fetched.
LastURL=
gosub DisplayStatus
; Put the Server name back in the Server name entry field (it was destroyed when we went to the compact screen)
GuiControl,, Serv, %Server%

return



DisplayStatus:
; Get and parse the 'CurrentSong' data from the remote Elpis program

	url = http://%Server%:35747/currentsong
	DStatus := HTMLText(url)

	Fav:=json(DStatus,"Loved")
	GuiControl,,FavIcon, % Fav ? "☺" : "-"
	FavIcon_TT:= % Fav ? "Identified as 'Liked'.  Click to Remove 'Liked' Designation" : "Mark as 'Liked'"
	b4_TT:= % Fav ? "Remove 'Liked' Designation" : "Mark as 'Liked'"

	; Place the Song, Artist, Album, and Station on the UI.  
	; GUI needs any & to be 'escaped' by doubling it
        StringReplace,Name2,% UnSlashUnicode(json(DStatus,"SongTitle")),&,&&,All
	GuiControl,,Song, %Name2%

        StringReplace,Name2,% UnSlashUnicode(json(DStatus,"Artist")),&,&&,All
	GuiControl,,Artist, %Name2%
        StringReplace,Name2,% UnSlashUnicode(json(DStatus,"Album")),&,&&,All
	GuiControl,,Album, %Name2%
	Station:=json(DStatus,"Station")
        StringReplace,Name2,% UnSlashUnicode(json(Station,"Name")),&,&&,All
	GuiControl,,Station, %Name2%


	; Get the Album Cover art from the web.  (only if the name has changed - i.e. song change)

	Name2:=json(DStatus,"AlbumArtUrl")
	if (Name2 <> LastURL)
	{
		UrlDownloadToFile,*0 %Name2%,%A_Temp%\ElpisImage.jpg
		if (errorlevel > 0)
		{
			; Place the default image back up.
			GuiControl,,AlbumArt,%A_Temp%\ElpisStart.jpg
		}
		else
		{
			GuiControl,,AlbumArt,%A_Temp%\ElpisImage.jpg
		}
		LastURL := Name2
	}

	return


; Stolen from http://www.autohotkey.com/board/topic/48103-google-translate-in-tooltip-still-works/
UnSlashUnicode(s)
{ 
  ; unslash unicode sequences like \u0026
  ; by Mikhail Kuropyatnikov 2009 (micdelt@mail.ru)
	rx = \\u([0-9a-fA-F]{4})
	pos = 0

	loop
	{
	pos := RegExMatch(s,rx,m,pos+1)
	if (pos = 0) 
		break
	StringReplace, s, s, %m%, % Chr("0x" . SubStr(m,3,4))
	}
	
	return s
}




; Stolen from polyethene http://www.autohotkey.com/board/topic/17367-url-encoding-and-decoding-of-special-characters/
uriDecode(str) {
msgbox,%str%
	Loop
		If RegExMatch(str, "i)(?<=%)[\da-f]{1,2}", hex)
			StringReplace, str, str, `%%hex%, % Chr("0x" . hex), All
		Else Break
	Return, str
}

; Function to request information from the remote Elpis program
Control(todo){
	; Put a status message up - if the remote Elpis is unavailable or slow.
	SetTimer,Trying, 100
	global Server
	url = http://%Server%:35747/%todo%
	Stat := HTMLText(url)
	SetTimer,Trying, off
	; Place the results of the call to Elpis on the status line
	GuiControl,, Status, %Stat%
	; Use the title field for status in the compact view
	global Compact
	if Compact
		ScreenDetectToolTip(stat)
	; Clear the status after 5000 ms
	SetTimer,StatusClear,5000
	return, Stat
}

Trying:
	GuiControl,, Status, Contacting %Server%
	SetTimer,Trying, off
	if compact
		ScreenDetectToolTip("Contacting %Server%")
	if (Transparent)
		WinSet, Transparent, off, Elpis Control
	return


StatusClear:
	SetTimer,StatusClear,off
	GuiControl,, Status, 
	if (Transparent)
		WinSet, Transparent, 150, Elpis Control
	ScreenDetectToolTip("")
	return

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

; Stolen from a collaboration of philz, toralf, polyethene, and daorc on http://www.autohotkey.com/board/topic/19165-smart-comboboxes/  - with a slight modification by me.

AutoComplete() { 
   static lf = "`n" 
   If GetKeyState("Delete") or GetKeyState("Backspace") 
      Return 
   SetControlDelay, -1 
   SetWinDelay, -1 
   GuiControlGet, h, Hwnd, %A_GuiControl% 
   ControlGet, haystack, List, , , ahk_id %h% 
   GuiControlGet, needle, , %A_GuiControl% 
   StringMid, text, haystack, pos := InStr(lf . haystack, lf . needle) 
      , InStr(haystack . lf, lf, false, pos) - pos 
   If text !=
   {
      if pos != 0
      { 
         ControlSetText, , %text%, ahk_id %h% 
         ControlSend, , % "{Right " . StrLen(needle) . "}+^{End}", ahk_id %h% 
      } 
   }
} 



; The following is taken from https://github.com/polyethene/AutoHotkey-Scripts/blob/master/json.ahk
/*
	Function: JSON

	Parameters:
		js - source
		s - path to element
		v - (optional) value to overwrite

	Returns:
		Value of element (prior to change).

	License:
		- Version 2.0 <http://www.autohotkey.net/~polyethene/#json>
		- Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>
*/
json(ByRef js, s, v = "") {
	j = %js%
	Loop, Parse, s, .
	{
		p = 2
		RegExMatch(A_LoopField, "([+\-]?)([^[]+)((?:\[\d+\])*)", q)
		Loop {
			If (!p := RegExMatch(j, "(?<!\\)(""|')([^\1]+?)(?<!\\)(?-1)\s*:\s*((\{(?:[^{}]++|(?-1))*\})|(\[(?:[^[\]]++|(?-1))*\])|"
				. "(?<!\\)(""|')[^\7]*?(?<!\\)(?-1)|[+\-]?\d+(?:\.\d*)?|true|false|null?)\s*(?:,|$|\})", x, p))
				Return
			Else If (x2 == q2 or q2 == "*") {
				j = %x3%
				z += p + StrLen(x2) - 2
				If (q3 != "" and InStr(j, "[") == 1) {
					StringTrimRight, q3, q3, 1
					Loop, Parse, q3, ], [
					{
						z += 1 + RegExMatch(SubStr(j, 2, -1), "^(?:\s*((\[(?:[^[\]]++|(?-1))*\])|(\{(?:[^{\}]++|(?-1))*\})|[^,]*?)\s*(?:,|$)){" . SubStr(A_LoopField, 1) + 1 . "}", x)
						j = %x1%
					}
				}
				Break
			}
			Else p += StrLen(x)
		}
	}
	If v !=
	{
		vs = "
		If (RegExMatch(v, "^\s*(?:""|')*\s*([+\-]?\d+(?:\.\d*)?|true|false|null?)\s*(?:""|')*\s*$", vx)
			and (vx1 + 0 or vx1 == 0 or vx1 == "true" or vx1 == "false" or vx1 == "null" or vx1 == "nul"))
			vs := "", v := vx1
		StringReplace, v, v, ", \", All
		js := SubStr(js, 1, z := RegExMatch(js, ":\s*", zx, z) + StrLen(zx) - 1) . vs . v . vs . SubStr(js, z + StrLen(x3) + 1)
	}
	Return, j == "false" ? 0 : j == "true" ? 1 : j == "null" or j == "nul"
		? "" : SubStr(j, 1, 1) == """" ? SubStr(j, 2, -1) : j
}




; Tool tip code "OnMessage(0x200, "WM_MOUSEMOVE")" above and this function are from the GUI AutoHotkey Help 
WM_MOUSEMOVE()
{
;   If a tooltip is currently being displayed for another part of the program, we should avoid overwriting them.
    static CurrControl, PrevControl, _TT  ; _TT is kept blank for use by the ToolTip command below.
    CurrControl := A_GuiControl
    If (CurrControl <> PrevControl and not InStr(CurrControl, " "))
    {
        ToolTip,,,,20  ; Turn off any previous tooltip.
        SetTimer, DisplayToolTip, 1000
        PrevControl := CurrControl
    }
    return

    DisplayToolTip:
    SetTimer, DisplayToolTip, Off
    CoordMode, Mouse  ; Switch to screen/absolute coordinates.
    CoordMode, Tooltip
    MouseGetPos, MouseX, MouseY
    text:=%CurrControl%_TT  ; The leading percent sign tell it to use an expression.
    ScreenDetectToolTip(text,20)
    SetTimer, RemoveToolTip, 3000
    return

    RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip,,,,20
    return
}


ScreenDetectToolTip(text,ToolTipNum:=1)
{
 ;  Add check for off screen next time
 ;  Tool tip 20 is special case (basically mouse-over tool-tip.)  Never let it interupt an existing tooltip
 ;  Note that this only supports tooltip 1 (default) and 20.  It doesn't track other tooltips separate from 1.
    static Active:=0

    if (text="")
    {
	ToolTip,,,,%ToolTipNum%
	if (ToolTipNum < 20)
		Active:=0
	return
    }
    ; Don't let 20 interupt anything
    if (ToolTipNum=20 AND Active>0)
	return
    ; Remove 20 if it is active
    if ToolTipNum<20 
    {
	ToolTip,,,,20
    	Active:=1
    }
    CoordMode, Mouse  ; Switch to screen/absolute coordinates.
    CoordMode, Tooltip
    MouseGetPos, MouseX, MouseY
    y:= MouseY < A_ScreenHeight - 70 ? MouseY + 25 : MouseY - 35
    y:= y < A_ScreenHeight - 70 ? y : A_ScreenHeight - 65 ; For some reason the tool-tips wrap to the top of the screen if put too low.  Need to test this on multiple machines.
    ToolTip %text%,,y,%ToolTipNum%
    return
}


; Check for someone dragging to move the compact windows vs clicking on the URL.  If the mouse button is down long enough, move the window
; Should be converted to a function, but that will be later.
; Taken from http://www.autohotkey.com/docs/scripts/EasyWindowDrag.htm
; - but modified a bit
; 
;
DragWindow:
; A global flag (that should be a return value on a function
Dragging:=0
; This routine should only be used for the compact window
if NOT Compact 
	return
; Wait 120 milliseconds and check if the mouse is still down.
sleep 120
GetKeyState, EWD_LButtonState, LButton, P
if EWD_LButtonState = U  ; Button has been released assume this was a click and return
	return

Dragging:=1
CoordMode, Mouse  ; Switch to screen/absolute coordinates.
MouseGetPos, EWD_MouseStartX, EWD_MouseStartY, EWD_MouseWin
; Fix window being used
;global CompactWin
EWD_MouseWin:=CompactWin 
WinGetPos, EWD_WinX, EWD_WinY,,, ahk_id %EWD_MouseWin%
;msgbox, EWD_WinX %EWD_WinX%


WinGetPos, EWD_OriginalPosX, EWD_OriginalPosY,,, ahk_id %EWD_MouseWin%
WinGet, EWD_WinState, MinMax, ahk_id %EWD_MouseWin% 
if EWD_WinState = 0  ; Only if the window isn't maximized
    SetTimer, EWD_WatchMouse, 10 ; Track the mouse as the user drags it.
return	;, 1

EWD_WatchMouse:
GetKeyState, EWD_LButtonState, LButton, P
if EWD_LButtonState = U  ; Button has been released, so drag is complete.
{
    SetTimer, EWD_WatchMouse, off
    ; Store new position in the registry so we can start with this position next time.
    RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\ElpisControl, CompactPositionX, %EWD_WinX%
    RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\ElpisControl, CompactPositionY, %EWD_WinY%
    return
}
GetKeyState, EWD_EscapeState, Escape, P
if EWD_EscapeState = D  ; Escape has been pressed, so drag is cancelled.
{
    SetTimer, EWD_WatchMouse, off
    WinMove, ahk_id %EWD_MouseWin%,, %EWD_OriginalPosX%, %EWD_OriginalPosY%
    return
}
; Otherwise, reposition the window to match the change in mouse coordinates
; caused by the user having dragged the mouse:
CoordMode, Mouse
MouseGetPos, EWD_MouseX, EWD_MouseY
WinGetPos, EWD_WinX, EWD_WinY,,, ahk_id %EWD_MouseWin%
SetWinDelay, -1   ; Makes the below move faster/smoother.
EWD_WinX := EWD_WinX + EWD_MouseX - EWD_MouseStartX
EWD_WinX := EWD_WinX < 0 ? 0 : EWD_WinX
EWD_WinY := EWD_WinY + EWD_MouseY - EWD_MouseStartY
EWD_WinY := EWD_WinY < 0 ? 0 : EWD_WinY
WinMove, ahk_id %EWD_MouseWin%,, EWD_WinX, EWD_WinY
EWD_MouseStartX := EWD_MouseX  ; Update for the next timer-call to this subroutine.
EWD_MouseStartY := EWD_MouseY
return
;}