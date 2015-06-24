# ElpisControl
Windows based remote control for the Elpis Windows Desktop Pandora Radio Client 

This is a Windows based remote control for the very nice Elpis Windows Desktop Pandora Radio Client that plays music from Pandora.  (See https://github.com/adammhaile/Elpis).  

Why a windows remote control program to control another windows program?  This was designed for the situation where Elpis is running on a Media Center Computer (with the nice sound system) yet you want to control Elpis from another laptop or desktop that you are working on.  This program only controls Elpis, it does not play Pandora music itself. 

This program creates a small window that displays the current song information and provides the standard Pandora Controls:  Play, Pause, Next, Like and Dislike.  It also has links to bring up additional information about the currently playing selection through the Pandora website.

![main](https://cloud.githubusercontent.com/assets/12969633/8319944/a7718e98-19e2-11e5-8336-12a779aef875.PNG)

Two window views are provided - the main one for choosing the media computer to connect to and showing album art.  A 'compact' view taking only a single line of screen space with more limited functions:

 ![compact](https://cloud.githubusercontent.com/assets/12969633/8319943/a763c3b2-19e2-11e5-9583-1c3e10c3169f.PNG)

A second program, PlayPause is provided to automate starting Elpis on the Media Center in a Paused state, ready to receive a play command from Elpis Control.  
Both programs are ‘developed' in AutoHotkey, which should allow easy modification to address any customizations desired.  

Setup
ElpisControl.exe is a standalone executable – just place it where you would like to keep it and execute it in place.  Optionally you can right-click and Sendto your desktop to create a desktop icon or drag the program to the Start Menu to create a start menu icon.
PlayPause.exe can be run on the computer where Elpis is installed to automate starting Elpis when a user logs in (ideally, via automatic login – either via being the default user with no password required or via an automation tool like Autologon from sysinternals.com).  
PlayPause.exe will offer to copy itself to the Elpis directory, and will create a ‘run’ registry entry to run itself automatically on logon – essentially ‘installing’ itself if run automatically.  You can use MSCONFIG to disable this run entry if you no longer want Elpis to start on every logon.
