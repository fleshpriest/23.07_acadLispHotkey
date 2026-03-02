; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Global Variables ----------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

GuiName = D_4C4||63//45+L3
armed := 0
Wo_Num :=
Batch_Num :=
Batch_Path :=
Batch_Rooms :=

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Enviornment Settings ------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

#NoEnv                                  ; Prevents empty variables from being referenced, improves performance
#MaxHotkeysPerInterval 99000000         ; Max number of macros before script soft-stop
#HotkeyInterval 1000                    ; Interval(ms) before soft-stopping program
#KeyHistory 1000                        ; Log length recent executions
#Warn                                   ; Enables error warnings at script start
#SingleInstance Force                   ; Disables 'Script Already Running' warning
#UseHook                                ; Disables recursive triggers
#HotkeyModifierTimeout 6                ; Attempts to kill stuck keys which occasionally cause resets
ListLines Off                           ; Extension of KeyHistory, disabled for better speed
Process, Priority, , A                  ; Defines scripts system priority (A = above normal)
SetBatchLines, -1                       ; Speed of script (-1 for never sleep)
SetKeyDelay, -1, -1                     ; Set Delay between keystrokes (-1 = no delay)
SendMode Input                          ; SendInput=Speed, Input=Mouse Reliability
SetWorkingDir %A_ScriptDir%             ; Sets cd to folder containing script
Suspend On                              ; Script starts in suspended states
Menu, Tray, Icon, scripticon.ico, , 1   ; Changes taskbar icon for script
CoordMode, Pixel, Window                ; Image search coords relative to the window
SetNumLockState, AlwaysOn               ; Forces Numlock on, OS hotkey disables further functionality but allows the key to be used to fire specified macros
SetScrollLockState, AlwaysOff           ; Similar to the above

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Primary GUI ---------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

Gui 1:+AlwaysOnTop -SysMenu -Caption +ToolWindow
Gui 1:Color,Blue,Black
Gui 1:Font,s12 cWhite,Consolas
Gui 1:Add,Tab3,w203 cWhite vCurrentGUITab gUpdate_Controls, Main||Doc ;|X
Gui 1:Add,CheckBox,h20 Checked vCheck1 gToggle_Float,L0
Gui 1:Add,Button,h20 gReload_GUI,R
Gui 1:Add,Button,h20 x+10 gOpen_UtilsGUI,U
Gui 1:Add,Edit,x114 y71 r1 w35 vgui_elev gUpdate_Controls,
Gui 1:Add,Edit,x152 y71 r1 w35 vgui_product gUpdate_Controls,
Gui 1:Add,DropDownList,x115 y40 w73 Choose1 vgui_num_input gUpdate_Controls,EP|EE|Sec|Pg|Typ|Blind|size
Gui 1:Tab,Doc
Gui 1:Add,Edit,r1 w50 varch_room_number gUpdate_Controls
Gui 1:Add,Edit,r1 w75 x+10 varch_room_name gUpdate_Controls
Gui 1:Add,Checkbox, xm+18 y75 h20 vCheckName1,Sec
Gui 1:Add,Checkbox, x+7 h20 Checked vCheckName0,Skip
Gui 1:Show,,%GuiName%
guiCoords := DetermineGUIPosition(1, 0, 0, 45)
gui_x := guiCoords[1]
gui_y := guiCoords[2]
Gui 1:Show,x%gui_x% y%gui_y%,%GuiName%
return

GuiClose:
	if (A_Gui = "main")
		exitapp
	else
		Gui %A_Gui%: Destroy
	return

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Functions -----------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

TestIfImageExists(imageFile) {
	if !FileExist(imageFile)
		MsgBox, Image file cannot be found
	else
		MsgBox, Image file exists
}

GetPrimaryMonitorDimensions() {
	SysGet, monitor, Monitor
	return [monitorRight, monitorBottom]
}

DetermineGUIPosition(snapRight, snapBottom, xOffset, yOffset) {
	monitorDimensions := GetPrimaryMonitorDimensions()
	monitorWidth := monitorDimensions[1]
	monitorHeight := monitorDimensions[2]
	WinGetPos,,, guiWidth, guiHeight, ahk_class AutoHotkeyGUI 
	gui_x_pos := xOffset
	gui_y_pos := yOffset
	if (snapRight = 1) {
		gui_x_pos += (monitorWidth - guiWidth)
	}
	if (snapBottom = 1)	{
		gui_y_pos += (monitorHeight - guiHeight)
	}
	return [gui_x_pos, gui_y_pos]
}
	
CheckWinTitleActive(WinTitle, WaitSecs) {
	timeout := (WaitSecs * 1000)
	start_time := A_TickCount ; Get the current timestamp
	while (!WinActive(WinTitle) && (A_TickCount - start_time) < timeout) {
		Sleep, 100
	}
	if (WinActive(WinTitle)) {
		return True
	}
	else {
		return False
	}
}

GetActiveWindowTitle() {
	WinGetTitle, title, A
	return title
}

GetWindowDimensions(windowTitle) {
	WinGetPos, , , winWidth, winHeight, % windowTitle
	return [winWidth, winHeight]
}

GetPrimaryMonitorWidth() {
	SysGet, screenWidth, 0
	return screenWidth
}

GetPrimaryMonitorHeight() {
	SysGet, screenHeight, 0
	return screenHeight
}

DetermineGUIXPosition() {
	monitor_width := GetPrimaryMonitorWidth()
	gui_x_adjust := 230
	return monitor_width - gui_x_adjust
}
	
DetermineGUIYPosition() {
	monitor_height := GetPrimaryMonitorHeight()
	gui_y_adjust := 2516
	return monitor_height - gui_y_adjust
}

CheckGuiFocus() { ; Infinite loop to continuously check the GUI focus
	while WinActive("ahk_class AutoHotkeyGUI") {
		Sleep, 1000
	}
	Gui, Destroy
	return
}

MouseMoveRelativeToWindow(xOffset, yOffset, wtitle) {
	WinGetPos, WinX, WinY, WinWidth, WinHeight, %wtitle%
	MouseGetPos, MouseX, MouseY
	NewX := xOffset
	NewY := yOffset
	MouseMove, NewX, NewY, 0
}

MouseMoveRelativeToWindowBottomRight(xOffset, yOffset, wtitle) {
	WinGetPos, WinX, WinY, WinWidth, WinHeight, %wtitle%
	MouseGetPos, MouseX, MouseY
	NewX := WinWidth - xOffset
	NewY := WinHeight - yOffset
	MouseMove, NewX, NewY, 0
}

AppendFilenamesWithText(filepath, text) {
	Loop, Files, %filepath%\*.*, , D 
	{
		filename := A_LoopFileLongPath
		FileGetAttrib, attr, %filename%
		if !(attr & 0x10) { ; Check if it's not a folder
			SplitPath, filename, name, dir, ext, name_no_ext
			new_filename := dir . "\" . name_no_ext . text . ext
			FileMove, %filename%, %new_filename%
		}
	}
}

CopyDrafterFiles:
	files := ["C:/path/to/file.xyz", "C:/path/to/file.xyz", "C:/path/to/file.xyz"] ; path removed for github
	InputBox, filepath, , Enter file path, , 300, 100
	MsgBox % filepath
	Loop, % files.MaxIndex() {
		FileCopy, % files[A_Index], % filepath
	}
	return
	
SplitStrToArray(x_array) {
	if (!IsObject(x_array))
		x_array := []
	clipboard := clipboard
	Msgbox % "Clipboard contents`n`n" . clipboard
	preparse_str = %clipboard%
	MsgBox % "variable contents`n`n" . preparse_str
	x_array := StrSplit(preparse_str, "`n")
	Loop % x_array.MaxIndex() {
		foo := x_array[A_Index]
		MsgBox, Color number %A_Index% is %foo%.
	}
	return x_array
}

MvClickOkayButton(windowTitle) {
	local
	searchArea := GetWindowDimensions(windowTitle)
	searchAreaX1 := searchArea[1]
	searchAreaY1 := searchArea[2]
	ImageSearch,xTarget,yTarget,0,0,searchAreaX1,searchAreaY1, .\util\mvOkayButton.png
	if (ErrorLevel = 2)
		MsgBox Could not conduct the search
	else if (ErrorLevel = 1)
		MsgBox, 0, Product Placement, Could not find button, 1
	else
		BlockInput, MouseMove
		MouseGetPos,xOriginal,yOriginal
		MouseMove,xTarget,yTarget,3
		Send,{LButton}
		MouseMove,xOriginal,yOriginal,3
		BlockInput, MouseMoveOff
	return
}

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- GoSubs --------------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

Open_UtilsGUI:
	UtilsGUI()
	return

Reload_GUI:
	Reload

Toggle_Float: ; Controls always-on-top status of GUI
	Gui 1: Submit, NoHide
	if (Check1 == 1)
		Gui 1: +AlwaysOnTop
	else if (Check1 == 0)
		Gui 1: -AlwaysOnTop
	return

KB_Float_Toggle: ; keyboard control to trigger Toggle_Float
	ControlGet,checked,checked,,L0,%GuiName%
	if checked = 0
		Control,check,,L0,%GuiName%
	else
		Control,uncheck,,L0,%GuiName%
	return

Update_Controls: ; Forces variable update upon editting associated text box
	Gui 1:Submit,NoHide
	Gui popupGuis: Submit, NoHide
	return

Toggle_Armed:
	if (armed = 0) {
		armed = 1
		Gui 1:Color,Red
		GuiControl,Font,Arm
		GuiControl,Font,Float
	}
	else {
		armed = 0
		Gui 1:Color,Blue
		GuiControl,Font,Arm
		GuiControl,Font,Float
	}
	Suspend,Toggle
	return

Open_Tracking:
	Run,"C:/path/to/file.xyz",,Max ; path removed for github
	return

Block_Library:
	explorerpath:= "explorer /e," "C:/path/to/dir" ; path removed for github
	Run, %explorerpath%
	return

Pics_Library:
	explorerpath:= "explorer /e," "C:/path/to/file.xyz" ; path removed for github
	Run, %explorerpath%
	return

Open_Sinks:
	explorerpath:= "explorer /e," "C:/path/to/dir" ; path removed for github
	Run, %explorerpath%
	return

Open_Shipping:
	Run, "C:/path/to/file.xyz" ; path removed for github
	return

Open_Wains:
	Run, "C:/path/to/file.xyz" ; path removed for github
	return

Open_Lock:
	Run, "C:/path/to/file.xyz" ; path removed for github
	return

Open_Wizard:
	Run, "C:/path/to/file.xyz" ; path removed for github
	return

Open_EngDocWiz:
	Run, "C:/path/to/file.xyz" ; path removed for github
	return

Open_FieldsChkLst:
	Run, "C:/path/to/file.xyz" ; path removed for github
	return

Open_Inventory:
	Run, "C:/path/to/file.xyz" ; path removed for github
	return

Open_DrftChecklist:
	Run, "C:/path/to/file.xyz" ; path removed for github
	return

Open_EngChecklist:
	Run, "C:/path/to/file.xyz" ; path removed for github
	return

Click_Text_Box: ; Better method of targetting text boxes within AutoCAD
	BlockInput, MouseMove
	Send,{Esc}
	Send,_eattedit{enter}
	Send,{LButton}
	BlockInput, MouseMoveOff
	return

AutomateMachineAssignment:
	sleepLength := 2000
	winDims := GetWindowDimensions("Processing Center")
	xMax := winDims[1]
	yMax := winDims[2]
	BlockInput,MouseMove	
	MouseMoveRelativeToWindow(35, 43, "Processing Center") ; Clicks General Tab
	Send,{LButton}
	BlockInput,MouseMoveOff
	; Find Load Machining
	Sleep,1000
	buttonName := "Load Machining button"
	ImageSearch,xLoadMachining,yLoadMachinig,0,0,xMax,yMax, .\util\ahk_acad_loadPartsMachining.png
	if (ErrorLevel = 2) {
		MsgBox, Search crashed while looking for %buttonName%.
		return
	}
	else if (ErrorLevel = 1) {
		MsgBox, %buttonName% could not be found on screen
		return
	}
	else if !ErrorLevel {
		BlockInput,MouseMove
		MouseMove,xLoadMachining,yLoadMachinig,0
		Send,{LButton}
		BlockInput,MouseMoveOff
	}
	Sleep,%sleepLength%
	; Find machine
	buttonName := "2 New Morbidelli"
	ImageSearch,xMorbi,yMorbi,0,0,xMax,yMax, .\util\ahk_acad_2newMorbidelli.png
	if (ErrorLevel = 2) {
		MsgBox, Search crashed while looking for %buttonName%.
		return
	}
	else if (ErrorLevel = 1) {
		MsgBox, %buttonName% could not be found on screen
		return
	}
	else if !ErrorLevel {
		BlockInput,MouseMove
		MouseMove,xMorbi,yMorbi,0
		Send,{LButton}
		BlockInput,MouseMoveOff
	}
	; Find Select All
	buttonName := "Select All Parts"
	ImageSearch,xSelectAll,ySelectAll,0,0,xMax,yMax, .\util\ahk_acad_selectAllParts.png
	if (ErrorLevel = 2) {
		MsgBox, Search crashed while looking for %buttonName%.
		return
	}
	else if (ErrorLevel = 1) {
		MsgBox, %buttonName% could not be found on screen
		return
	}
	else if !ErrorLevel {
		BlockInput,MouseMove
		MouseMove,xSelectAll,ySelectAll,0
		Send,{LButton}
		BlockInput,MouseMoveOff
	}
	; Assign Parts
	buttonName := "Assign Processing Stations To Selected Parts"
	ImageSearch,xAssign,yAssign,0,0,xMax,yMax, .\util\ahk_acad_assignStationToSelected.png
	if (ErrorLevel = 2) {
		MsgBox, Search crashed while looking for %buttonName%.
		return
	}
	else if (ErrorLevel = 1) {
		MsgBox, %buttonName% could not be found on screen
		return
	}
	else if !ErrorLevel {
		BlockInput,MouseMove
		MouseMove,xAssign,yAssign,0
		Send,{LButton}
		BlockInput,MouseMoveOff
	}
	; Wait to verify MV has finished processing Assignments
	if !CheckWinTitleActive("Processing Center", 5) {
		MsgBox,Function timeout while waiting for machine assignments
		return
	}
	Sleep,%sleepLength%
	BlockInput,MouseMove
	MouseMoveRelativeToWindow(35, 43, "Processing Center") ; Clicks General Tab
	Send,{LButton}
	BlockInput,MouseMoveOff
	Sleep,500
	; Find No Machining Button
	buttonName := "Load Parts with No Machining"
	ImageSearch,xLoadMachining,yLoadMachinig,0,0,xMax,yMax, .\util\ahk_acad_loadPartsNoMachining.png
	if (ErrorLevel = 2) {
		MsgBox, Search crashed while looking for %buttonName%.
		return
	}
	else if (ErrorLevel = 1) {
		MsgBox, %buttonName% could not be found on screen
		return
	}
	else if !ErrorLevel {
		BlockInput,MouseMove
		MouseMove,xLoadMachining,yLoadMachinig,0
		Send,{LButton}
		BlockInput,MouseMoveOff
	}
	Sleep,%sleepLength%
	; Find machine
	buttonName := "9 Schelling Prelim only"
	ImageSearch,xPrelim,yPrelim,0,0,xMax,yMax, .\util\ahk_acad_9schellingPrelimOnly.png
	if (ErrorLevel = 2) {
		MsgBox, Search crashed while looking for %buttonName%.
		return
	}
	else if (ErrorLevel = 1) {
		MsgBox, %buttonName% could not be found on screen
		return
	}
	else if !ErrorLevel {
		BlockInput,MouseMove
		MouseMove,xPrelim,yPrelim,0
		Send,{LButton}
		BlockInput,MouseMoveOff
	}
	; Select All
	BlockInput,MouseMove
	MouseMove,xSelectAll,ySelectAll,0
	Send,{LButton}
	BlockInput,MouseMoveOff
	; Assign parts
	BlockInput,MouseMove
	MouseMove,xAssign,yAssign,0
	Send,{LButton}
	BlockInput,MouseMoveOff
	; Wait to verify MV has finished processing Assignments
	if !CheckWinTitleActive("Processing Center", 5) {
		MsgBox,Function timeout while waiting for machine assignments
		return
	}
	Sleep,%sleepLength%
	BlockInput,MouseMove
	MouseMoveRelativeToWindow(35, 43, "Processing Center") ; Clicks General Tab
	Send,{LButton}
	BlockInput,MouseMoveOff
	Sleep,500
	; Find Load All Parts
	buttonName := "Load All Parts"
	ImageSearch,xLoadAll,yLoadAll,0,0,xMax,yMax, .\util\ahk_acad_loadAllParts.png
	if (ErrorLevel = 2) {
		MsgBox, Search crashed while looking for %buttonName%.
		return
	}
	else if (ErrorLevel = 1) {
		MsgBox, %buttonName% could not be found on screen
		return
	}
	else if !ErrorLevel {
		BlockInput,MouseMove
		MouseMove,xLoadAll,yLoadAll,0
		Send,{LButton}
		BlockInput,MouseMoveOff
	}
	return

printPurchaseOrder:
	Suspend,Permit
	time = 200
	if CheckWinTitleActive("ShopPAK", 2) { ; Open file tab, print preView
		Send,!f
		Sleep,%time%
		Send,v
		Sleep,%time%
	}
	else {
		return
	}
	if CheckWinTitleActive("Print Back Ordered only", 1) {
		Send,{enter}
	}
	if CheckWinTitleActive("ShopPAK Report Setup", 2) { ; print report
		Send,p
		Sleep,%time%
		Send,{enter}
	}
	else {
		return
	}
	if CheckWinTitleActive("ShopPAK Report Status", 2)	{
		Sleep,1 ; verify this window appears otherwise something has gone wrong & we should escape
	}
	else {
		return
	}
	if CheckWinTitleActive("ShopPAK Report Setup", 8) {
		Send,{Esc} ; close the Print dialouge box which opens a second time
	}
	if CheckWinTitleActive("ShopPAK", 1) { ; Close the currently open PO
		Send,!f
		Sleep,%time%
		Send,c
	}
	if CheckWinTitleActive("Notice", 1) {
		Send,{Esc}
	}
	return

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Utilities GUI -------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

UtilsGUI() {
	m = 10
	w = 100
	h = 50
	Gui popupGuis: New, -SysMenu +ToolWindow -Caption
	Gui popupGuis: Margin, 10, 10
	Gui popupGuis: Font,s10	cWhite,Consolas
	Gui popupGuis: Color, Black
	Gui popupGuis: Add, Button,       w%w% h%h% gOpen_Tracking      ,Tracking ;R1
	Gui popupGuis: Add, Button, x+%m% w%w% h%h% gBlock_Library      ,Block`nLibrary
	Gui popupGuis: Add, Button, x+%m% w%w% h%h% gPics_Library       ,HW Pics`nLibrary
	Gui popupGuis: Add, Button, x+%m% w%w% h%h% gOpen_Shipping      ,Shipping`nManifest
	Gui popupGuis: Add, Button, x+%m% w%w% h%h% gOpen_Wains         ,Wainscot`nManifest
	Gui popupGuis: Add, Button, xm    w%w% h%h% gOpen_Lock          ,Lock Schedule ;R2
	Gui popupGuis: Add, Button, x+%m% w%w% h%h% gOpen_Wizard        ,Name`nWizard
	Gui popupGuis: Add, Button, x+%m% w%w% h%h% g                   ,
	Gui popupGuis: Add, Button, x+%m% w%w% h%h% gOpen_DrftChecklist ,Drafting`nCheckList
	Gui popupGuis: Add, Button, x+%m% w%w% h%h% gOpen_EngChecklist  ,Engineer`nCheckList
	Gui popupGuis: Add, Button, xm    w%w% h%h% gOpen_Sinks         ,Sinks Directory ;R3
	Gui popupGuis: Add, Button, x+%m% w%w% h%h% gOpen_EngDocWiz     ,Eng Doc`nWizard
	Gui popupGuis: Add, Button, x+%m% w%w% h%h% gOpen_FieldsChkLst  ,Fields`nChecklist
	Gui popupGuis: Add, Button, x+%m% w%w% h%h% gOpen_Inventory     ,Inventory
	Gui popupGuis: Add, Button, x+%m% w%w% h%h% g                   ,
	Gui popupGuis: Add, Button, xm    w%w% h%h% g                   , ;R4
	Gui popupGuis: Add, Button, x+%m% w%w% h%h% g                   ,
	Gui popupGuis: Add, Button, x+%m% w%w% h%h% g                   ,
	Gui popupGuis: Add, Button, x+%m% w%w% h%h% g                   ,
	Gui popupGuis: Add, Button, x+%m% w%w% h%h% g +Default          ,
	Gui popupGuis: Show, Autosize xCenter yCenter, popupGuis
	CheckGuiFocus()
	return
}

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Layers GUI ----------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

LayerGUI() {
	h  := 60          ; button height
	w  := 80          ; button width
	m0 := 10          ; gap between buttons
	ms := m0 * 2      ; cluster gap
	m1 := w + m0      ; center key spacing
	mn := m1 * 2 + ms ; center spacing between clusters
	
	Gui popupGuis: New, -SysMenu +ToolWindow -Caption
	Gui popupGuis: Margin, 10, 10
	Gui popupGuis: Font,s10	cWhite,Consolas
	Gui popupGuis: Color, Black
	
	Gui popupGuis: Add, Button, xm+%m1% w%w% h%h% glyr_ylw           ,&g`rYlw
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% glyr_7             ,&x`r7
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% glyr_8             ,&j`r8
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% glyr_9             ,&k`r9

	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gsc_32             ,&r`r3-8
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gsc_48             ,&m`r1-4
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gsc_64             ,&f`r3-16
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gsc_96             ,&p`r1-8

	Gui popupGuis: Add, Button, xm      w%w% h%h% glyr_mag           ,&1`rMagenta
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% glyr_grn           ,&c`rGrn
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% glyr_blk           ,&q`rBlack
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% glyr_wain          ,&2`rWains
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% glyr_4             ,&i`r4
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% glyr_rst           ,&`;`rReset
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% glyr_g             ,&3`rGlass
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% glyr_5             ,&e`r5
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% glyr_d             ,&,`rDefP
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% glyr_2dbase        ,&4`r2D Base
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% glyr_6             ,&a`r6
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% glyr_2dupper       ,&5`r2D Upper

	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% gsc_dat            ,&6`rDatum
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gsc_8              ,&h`r1 1-2
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gsc_match          ,&7`rMatch
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% gsc_drft           ,&.`rDrft
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gsc_12             ,&t`r1
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gsc_eng            ,&8`rEng
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% g                  ,&'`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gsc_16             ,&s`r3-4
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&9`r
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% g                  ,&z`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gsc_24             ,&n`r1-2
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&0`r

	Gui popupGuis: Add, Button, xm+%m1% w%w% h%h% glyr_red           ,&b`rRed
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% glyr_1             ,&y`r1
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% glyr_2             ,&o`r2
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% glyr_3             ,&u`r3

	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gsc_1              ,&l`r12
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gsc_2              ,&d`r6
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gsc_4              ,&w`r3
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gsc_6              ,&v`r2
	
	Gui popupGuis: Show, Autosize xCenter yCenter, popupGuis
	CheckGuiFocus()
	return
}

sc_match:
	Gui %A_Gui%: Destroy
	Send,{Esc}sm{Enter}
	return

sc_esc:
	Gui %A_Gui%: Destroy
	return

sc_48:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}z48{enter}
	}
	Send,sty1-4{enter}
	return

sc_64:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,z64{enter}
	}
	Send,sty3-16{enter}
	return

sc_96:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,z96{enter}
	}
	Send,sty1-8{enter}
	return

sc_16:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,z16{enter}
	}
	Send,sty3-4{enter}
	return

sc_24:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,z24{enter}
	}
	Send,sty1-2{enter}
	return

sc_32:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,z32{enter}
	}
	Send,sty3-8{enter}
	return

sc_6:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,z6{enter}
	}
	Send,sty2{enter}
	return

sc_8:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,z8{enter}
	}
	Send,sty1-1-2{enter}
	return

sc_12:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,z12{enter}
	}
	Send,sty1{enter}
	return

sc_1:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,z1{enter}
	}
	Send,sty12{enter}
	return

sc_2:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,z2{enter}
	}
	Send,sty6{enter}
	return

sc_4:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,z4{enter}
	}
	Send,sty3{enter}
	return

sc_drft:
	Gui %A_Gui%: Destroy
	Send,drft{enter}
	return

sc_eng:
	Gui %A_Gui%: Destroy
	Send,eng{enter}
	return

sc_dat:
	Gui %A_Gui%: Destroy
	Send,sty3-8dat{enter}
	return

lyr_1:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,colorphantom{enter}
	} else {
		Send,111{enter}
	}
	return

lyr_2:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,coloryellow{enter}
	} else {
		Send,222{enter}
	}
	return

lyr_3:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,colorgreen{enter}
	} else {
		Send,333{enter}
	}
	return

lyr_4:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,colortops{enter}
	} else {
		Send,444{enter}
	}
	return

lyr_5:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,colorwalls{enter}
	} else {
		Send,555{enter}
	}
	return

lyr_6:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,colororange{enter}
	} else {
		Send,666{enter}
	}
	return

lyr_7:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,colorwhite{enter}
	} else {
		Send,777{enter}
	}
	return

lyr_8:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,colorgrey{enter}
	} else {
		Send,888{enter}
	}
	return

lyr_9:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,colorphantom{enter}
	} else {
		Send,999{enter}
	}
	return

lyr_d:
	Gui %A_Gui%: Destroy
	Send,```{enter}
	return

lyr_g:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{esc}glass{enter}
	} else {
		Send,ggg{enter}
	}
	return

lyr_k:
	Gui %A_Gui%: Destroy
	return

lyr_red:
	Gui %A_Gui%: Destroy
	Send,colorred{enter}
	return

lyr_ylw:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,hrd{enter}
	} else {
		Send,coloryellow{enter}
	}
	return

lyr_blu:
	Gui %A_Gui%: Destroy
	Send,colorblue{enter}
	return

lyr_blk:
	Gui %A_Gui%: Destroy
	Send,colorblack{enter}
	return

lyr_grn:
	Gui %A_Gui%: Destroy
	Send,colorgreen{enter}
	return

lyr_mag:
	Gui %A_Gui%: Destroy
	Send,colormagenta{enter}
	return

lyr_rst:
	Gui %A_Gui%: Destroy
	Send,coloreset{enter}
	return

lyr_vanish:
	Gui %A_Gui%: Destroy
	Send,colorvanish{enter}
	return

lyr_wain:
	Gui %A_Gui%: Destroy
	Send,www{enter}
	return

lyr_2dbase:
	Gui %A_Gui%: Destroy
	Send,bbb{enter}
	return

lyr_2dupper:
	Gui %A_Gui%: Destroy
	Send,uuu{enter}
	return

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Dimensional GUI -----------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

DimGUI() {
	h  := 60          ; button height
	w  := 80          ; button width
	m0 := 10          ; gap between buttons
	ms := m0 * 2      ; cluster gap
	m1 := w + m0      ; center key spacing
	mn := m1 * 2 + ms ; center spacing between clusters
	
	Gui popupGuis: New, -SysMenu +ToolWindow -Caption
	Gui popupGuis: Margin, 10, 10
	Gui popupGuis: Font,s12 cWhite,Consolas
	Gui popupGuis: Color, Purple, Red
	
	Gui popupGuis: Add, Button, xm+%m1% w%w% h%h% gdim_scr           ,&g`rScribe
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gdim_leg           ,&x`rLeg
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gdim_sub           ,&j`rSub
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gdim_deck          ,&k`rDeck

	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gutil_cst          ,&r`rCTop
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gutil_4st          ,&m`rSplash
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&f`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gutil_ss0          ,&p`rSS0

	Gui popupGuis: Add, Button, xm      w%w% h%h% gdim_vif           ,&1`rVIF
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gdim_kick          ,&c`rKick
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gdim_typ           ,&q`rTyp
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% gdim_rst           ,&2`rReset
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gdim_over          ,&i`rOverall
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gdim_wns           ,&`;`rWnsCt
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% g                  ,&3`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gdim_soff          ,&e`rSoffit
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gdim_eq            ,&,`rEQ
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% gdim_sill          ,&4`rSill
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gdim_top           ,&a`rTop
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gdim_gap           ,&5`rGap

	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% gutil_pst          ,&6`rSoffit
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gutil_bst          ,&h`rBase
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gutil_tst          ,&7`rTall
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% g                  ,&.`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gutil_ut           ,&t`rUpper
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&8`r
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% g                  ,&'`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&s`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&9`r
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% gutil_hl0          ,&z`rHL
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gutil_ct0          ,&n`rCT0
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&0`r

	Gui popupGuis: Add, Button, xm+%m1% w%w% h%h% gdim_apron         ,&b`rApron
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&y`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gdim_shlf          ,&o`rShelf
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gdim_clr           ,&u`rClear

	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gutil_rbt          ,&l`rTKick
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gutil_lv           ,&d`rLV
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&w`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gutil_ply          ,&v`rPly
	
	Gui popupGuis: Show, AutoSize xCenter yCenter, popupGuis
	CheckGuiFocus()
	return
}

util_lv:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{esc}setvalanceheight{enter}
	} else {
		Send,{esc}lv{enter}
	}
	return

util_tst:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{esc}settalldepth{enter}
	} else {
		Send,{esc}tst{enter}
	}
  return

util_pst:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,pst{enter}
	}
	else {
		Send,flst{enter}
	}
	return

util_ss0:
	Gui %A_Gui%: Destroy
	Send,{esc}stnhatch{enter}
	return

util_hl0:
	Gui %A_Gui%: Destroy
	Send,{esc}hl0{enter}
	return

util_ply:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{esc}plyvert{enter}
	} else {
		Send,{esc}plyhorz{enter}
	}
	return

util_cst:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}setCtDepth{enter}
	} else {
		Send,{Esc}cst{enter}
	}
	return

util_4st:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Ecs}4scs{enter}
	} else {
		Send,4st{enter}
	}
	return

util_ct0:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}ct9{enter}
	} else {
		Send,{Esc}ct0{enter}
	}
	return

util_bst:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}setBaseDepth{enter}
	} else {
		Send,bst{enter}
	}
	return

util_ut:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}setUpperDepth{enter}
	} else {
		Send,ut{enter}
	}
	return

util_rbt:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,pbt{enter}
	}
	else {
		Send,rbt{enter}
	}
	return

util_ast:
	Gui %A_Gui%: Destroy
	Send,{esc}ast{enter}
	return

util_wmi:
	Gui %A_Gui%: Destroy
	Send,{esc}wmi{enter}
	return

util_iwt:
	Gui %A_Gui%: Destroy
	Send,{esc}iwt{enter}
	return
	
dim_gap:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,edgapp{enter}
	}
	else {
		Send,edgap{enter}
	}
	return

dim_apron:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,edapronn{enter}
	}
	else {
		Send,edapron{enter}
	}
	return

dim_typ:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,edtypp{enter}
	}
	else {
		Send,edtyp{enter}
	}
	return

dim_top:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,edtt{enter}
	}
	else {
		Send,edt{enter}
	}
	return

dim_vif:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,edvv{enter}
	}
	else {
		Send,edv{enter}
	}
	return

dim_clr:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,edcc{enter}
	}
	else {
		Send,edc{enter}
	}
	return

dim_kick:
	Gui %A_Gui%: Destroy
	Send,edk{enter}
	return

dim_over:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,edovv{enter}
	}
	else {
		Send,edov{enter}
	}
	return

dim_soff:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,edsoff{enter}
	}
	else {
		Send,edsof{enter}
	}
	return

dim_leg:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,edlegg{enter}
	}
	else {
		Send,edleg{enter}
	}
	return

dim_scr:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,edss{enter}
	}
	else {
		Send,eds{enter}
	}
	return

dim_eq:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,edee{enter}
	}
	else {
		Send,ede{enter}
	}
	return

dim_shlf:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,edshelff{enter}
	}
	else {
		Send,edshelf{enter}
	}
	return

dim_deck:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,eddeckk{enter}
	}
	else {
		Send,eddeck{enter}
	}
	return

dim_sub:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,edsubb{enter}
	}
	else {
		Send,edsub{enter}
	}
	return

dim_sill:
	Gui %A_Gui%: Destroy
  if GetKeyState("BS") {
    Send,edsill{enter}
  }
  else {
    Send,edsil{enter}
  }
  return

dim_rst:
	Gui %A_Gui%: Destroy
	Send,ed1{enter}
	return

dim_wns:
	Gui %A_Gui%: Destroy
	Send,edws{enter}
	return

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Block GUI -----------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

BlockGUI() {
	h  := 60          ; button height
	w  := 80          ; button width
	m0 := 10          ; gap between buttons
	ms := m0 * 2      ; cluster gap
	m1 := w + m0      ; center key spacing
	mn := m1 * 2 + ms ; center spacing between clusters
	
	Gui popupGuis: New, -SysMenu +ToolWindow -Caption
	Gui popupGuis: Margin, 10, 10
	Gui popupGuis: Font,s10 cWhite,Consolas
	Gui popupGuis: Color, Lime, Red
		
	Gui popupGuis: Add, Button, xm+%m1% w%w% h%h% gblock_eqp         ,&g`rEQP
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&x`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&j`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gblock_plu         ,&k`rPLU

	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gblock_ucrf        ,&r`rUC Refr
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&m`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&f`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gblock_stndbrkt    ,&p`rStndBkt

	Gui popupGuis: Add, Button, xm      w%w% h%h% gblock_route       ,&1`rRTG
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gblock_numboxd     ,&c`rNumBox
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&q`r
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% gblock_window      ,&2`rWindow
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gblock_door        ,&i`rDoor
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&`;`r
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% gblock_hinge       ,&3`rHinge
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gblock_earr        ,&e`rEar
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&,`r
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% gblock_tjb         ,&4`rTJoint
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gblock_break       ,&a`rBreak
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gblock_pbp         ,&5`rPktBr

	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% gblock_trash       ,&6`rTrashC
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gblock_refr        ,&h`rRefr
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gblock_dw          ,&7`rDW
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% gblock_fau         ,&.`rFaucet
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gblock_mw          ,&t`rMW
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gblock_printer     ,&8`rPrinter
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% gblock_lkb         ,&'`rLKB
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gblock_e1          ,&s`rE1
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gblock_clt         ,&9`rCL
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% g                  ,&z`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&n`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gblock_tlt         ,&0`rToilet

	Gui popupGuis: Add, Button, xm+%m1% w%w% h%h% gblock_brkt        ,&b`rBracket
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gblock_alt         ,&y`rAlign
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gblock_opn         ,&o`rOpen
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gblock_grain       ,&u`rGrain

	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gblock_ctp         ,&l`rCT PL
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gblock_cts         ,&d`rCT SS
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gblock_ctq         ,&w`rCT QZ
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&v`r
	
	Gui popupGuis: Show, AutoSize xCenter yCenter, popupGuis
	CheckGuiFocus()
	return
}

block_printer:
	Gui %A_Gui%: Destroy
        Send,{Esc}printer{enter}
	return

block_stndbrkt:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}bracketsection{enter}
	}
	else {
		Send,{Esc}standardsection{enter}
	}
	return

block_trash:
	Gui %A_Gui%: Destroy
	Send,{Esc}trash{enter}
	return

block_refr:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}refrplan{enter}
	}
	else {
		Send,{Esc}refrelev{enter}
	}
	return

block_ucrf:
	Gui %A_Gui%: Destroy
	Send,{Esc}refrundercounterelev{enter}
	return

block_dw:
	Gui %A_Gui%: Destroy
	Send,{Esc}dishwashelev{enter}
	return

block_mw:
	Gui %A_Gui%: Destroy
	Send,{Esc}microwaveelev{enter}
	return

block_tlt:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}toiletelev{enter}
	}
	else {
		Send,{Esc}toiletplan{enter}
	}
	return

block_fau:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}faae{enter}
	}
	else {
		Send,{Esc}faaf{enter}
	}
	return

block_ctp:
	Gui %A_Gui%: Destroy
	Send,{Esc}ctp{enter}
	return

block_cts:
	Gui %A_Gui%: Destroy
	Send,{Esc}cts{enter}
	return

block_ctq:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}ctq3{enter}
	}
	else {
		Send,{Esc}ctq2{enter}
	}
	return

block_brkt:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,brktt{enter}
	}
	else {
		Send,brkt{enter}
	}
	return

block_ast:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,astt{enter}
	}
	else {
		Send,ast{enter}
	}
  return

block_alt:
	Gui %A_Gui%: Destroy
	Send,alrt{enter}
	return

block_route:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}cguide{Enter}
	}
	else {
		Send,{Esc}rguide{enter}
	}
	return

block_lkb:
	Gui %A_Gui%: Destroy
	Send,{Esc}lkb{enter}
	return

block_hinge:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}5khngdes{enter}
	}
	else {
		Send,{Esc}hingedes{enter}
	}
	return

block_e1:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}cv1{enter}
	}
	else {
		Send,{Esc}e1{enter}
	}
	return

block_door:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}dooredes{enter}
	}
	else {
		Send,{Esc}doorpdes{enter}
	}
	return

block_window:
	Gui %A_Gui%: Destroy
	Send,{Esc}windowpdes{enter}
	return

block_break:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}brkhorz{enter}
	}
	else {
		Send,{Esc}breakdes{enter}
	}
	return

block_eqp:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}acs{enter}
	}
	else {
		Send,{Esc}eqp{enter}
	}
	return

block_vr:
	Gui %A_Gui%: Destroy
	Send,{Esc}vr{enter}
	return

block_iwt:
	Gui %A_Gui%: Destroy
	Send,{Esc}iwt{enter}
	return

block_wmi:
	Gui %A_Gui%: Destroy
	Send,{Esc}wmi{enter}
	return

block_opn:
	Gui %A_Gui%: Destroy
	Send,{Esc}opn{enter}
	return

block_plu:
	Gui %A_Gui%: Destroy
	Send,{Esc}plu{enter}
	return

block_earr:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}sbd{enter}
	}
	else {
		Send,{Esc}earr{enter}
	}
	return

block_numboxd:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		GoSub,Toggle_Armed
		Send,{Esc}numboxdetailhorz{enter}
	}
	else {
		Send,{Esc}numboxd{enter}
	}
	return

block_grain:
	Gui %A_Gui%: Destroy
	Send,{Esc}grain{Enter}
	return

block_tjb:
	Gui %A_Gui%: Destroy
	Send,{Esc}tjb{enter}
	return

block_pbp:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}pocketboresection{enter}
	}
	else {
		Send,{Esc}pbp{enter}
	}
	return

block_magcatch:
	Gui %A_Gui%: Destroy
	Send,{Esc}mag{enter}
	return

block_keku:
	Gui %A_Gui%: Destroy
	Send,{Esc}keku{enter}
	return

block_clt:
	Gui %A_Gui%: Destroy
	Send,{Esc}clt{Enter}
	return

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Camera GUI ----------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

CameraGUI() {	
	h  := 60          ; button height
	w  := 80          ; button width
	m0 := 10          ; gap between buttons
	ms := m0 * 2      ; cluster gap
	m1 := w + m0      ; center key spacing
	mn := m1 * 2 + ms ; center spacing between clusters

	Gui popupGuis: New, -SysMenu +ToolWindow -Caption
	Gui popupGuis: Margin, 10, 10
	Gui popupGuis: Font,s10 cWhite,Consolas
	Gui popupGuis: Color, Blue, Blue

	Gui popupGuis: Add, Button, xm+%m1% w%w% h%h% g                  ,&g`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gCamera_NW         ,&x`rNW
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gCamera_N          ,&j`rN
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gCamera_NE         ,&k`rNE

	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&r`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&m`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&f`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&p`r

	Gui popupGuis: Add, Button, xm      w%w% h%h% g                  ,&1`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&c`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&q`r
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% g                  ,&2`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gCamera_W          ,&i`rW
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&`;`r
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% g                  ,&3`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gCamera_Top        ,&e`rTop
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&,`r
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% g                  ,&4`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gCamera_E          ,&a`rE
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&5`r

	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% g                  ,&6`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gsnap_reset        ,&h`rReset
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&7`r
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% g                  ,&.`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&t`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&8`r
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% g                  ,&'`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&s`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&9`r
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% g                  ,&z`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&n`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&0`r

	Gui popupGuis: Add, Button, xm+%m1% w%w% h%h% g                  ,&b`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gCamera_SW         ,&y`rSW
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gCamera_S          ,&o`rS
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gCamera_SE         ,&u`rSE

	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&l`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&d`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&w`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&v`r

	Gui popupGuis: Show, AutoSize xCenter yCenter, popupGuis
	CheckGuiFocus()
	return 
}

Camera_NW:
	Gui %A_Gui%: Destroy
	Send,{Esc}cameraIsoNW{Enter}
	return

Camera_N:
	Gui %A_Gui%: Destroy
	Send,{Esc}cameraNorth{Enter}
	return

Camera_NE:
	Gui %A_Gui%: Destroy
	Send,{Esc}cameraIsoNE{Enter}
	return

Camera_W:
	Gui %A_Gui%: Destroy
	Send,{Esc}cameraWest{Enter}
	return

Camera_Top:
	Gui %A_Gui%: Destroy
	Send,{Esc}cameraTop{Enter}
	return

Camera_E:
	Gui %A_Gui%: Destroy
	Send,{Esc}cameraEast{Enter}
	return

Camera_SW:
	Gui %A_Gui%: Destroy
	Send,{Esc}cameraIsoSW{Enter}
	return

Camera_S:
	Gui %A_Gui%: Destroy
	Send,{Esc}cameraSouth{Enter}
	return

Camera_SE:
	Gui %A_Gui%: Destroy
	Send,{Esc}cameraIsoSE{Enter}
	return

snap_reset:
	Gui %A_Gui%: Destroy
	Send,{esc}snapreset{Enter}
	return

snap_square:
	Gui %A_Gui%: Destroy
	Send,{esc}snapsquare{enter}
	return

snap_mid:
	Gui %A_Gui%: Destroy
	Send,{esc}snapmid{enter}
	return

snap_circle:
	Gui %A_Gui%: Destroy
	Send,{esc}snapcircle{enter}
	return

snap_node:
	Gui %A_Gui%: Destroy
	Send,{esc}snapnode{enter}
	return

snap_quadrant:
	Gui %A_Gui%: Destroy
	Send,{esc}snapquadrant{enter}
	return

snap_inter:
	Gui %A_Gui%: Destroy
	Send,{esc}snapintersection{enter}
	return

snap_insert:
	Gui %A_Gui%: Destroy
	Send,{esc}snapinsertion{enter}
	return

snap_perpen:
	Gui %A_Gui%: Destroy
	Send,{esc}snapperpendicular{enter}
	return

snap_tangent:
	Gui %A_Gui%: Destroy
	Send,{esc}snaptangent{enter}
	return

snap_nearest:
	Gui %A_Gui%: Destroy
	Send,{esc}snapnearest{enter}
	return

snap_geocenter:
	Gui %A_Gui%: Destroy
	Send,{esc}snapgeocenter{enter}
	return

snap_appintersect:
	Gui %A_Gui%: Destroy
	Send,{esc}snapapparentinterestion{enter}
	return

snap_extension:
	Gui %A_Gui%: Destroy
	Send,{esc}snapextension{enter}
	return

snap_parallel:
	Gui %A_Gui%: Destroy
	Send,{esc}snapparallel{enter}
	return

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- MV GUI --------------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

MvGUI() {
	h  := 60          ; button height
	w  := 80          ; button width
	m0 := 10          ; gap between buttons
	ms := m0 * 2      ; cluster gap
	m1 := w + m0      ; center key spacing
	mn := m1 * 2 + ms ; center spacing between clusters

	Gui popupGuis: New, -SysMenu +ToolWindow -Caption
	Gui popupGuis: Margin, 10, 10
	Gui popupGuis: Font,s10 cWhite,Consolas
	Gui popupGuis: Color, Blue, Blue

	Gui popupGuis: Add, Button, xm+%m1% w%w% h%h% gMvGUI_desegg      ,&g`rdeseng
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&x`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gMvGUI_bump        ,&j`rBump
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gMvGUI_redraw      ,&k`rRedraw

	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gview_restore      ,&r`rRestore
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&m`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&f`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&p`r

	Gui popupGuis: Add, Button, xm      w%w% h%h% g                  ,&1`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gMvGUI_walls       ,&c`rDraw Walls
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&q`r
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% gMvGUI_reLisp      ,&2`rReLisp
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gMvGUI_section     ,&i`rSection
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gMvGUI_scaleRefr   ,&`;`rScale OS?
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% g                  ,&3`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gMvGUI_2dDims      ,&e`r2D Dims
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&,`r
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% gMvGUI_rename      ,&4`rRename
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gMvGUI_tabs        ,&a`rCPT
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&5`r

	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% gview_lower        ,&6`rLower
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gview_isolate      ,&h`rIsolate
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gview_raise        ,&7`rRaise
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% g                  ,&.`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% gview_bmask        ,&t`rBMask
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&8`r
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% g                  ,&'`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&s`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&9`r
	Gui popupGuis: Add, Button,  x+%ms% w%w% h%h% g                  ,&z`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&n`r
	Gui popupGuis: Add, Button,  x+%m0% w%w% h%h% g                  ,&0`r

	Gui popupGuis: Add, Button, xm+%m1% w%w% h%h% g                  ,&b`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gMvGUI_center      ,&y`rCenter
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gMvGUI_ucs         ,&o`rMod UCS
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&u`r

	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% gview_hide         ,&l`rHide
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&d`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&w`r
	Gui popupGuis: Add, Button,  x+%mn% w%w% h%h% g                  ,&v`r

	Gui popupGuis: Show, AutoSize xCenter yCenter, popupGuis
	CheckGuiFocus()
	return
}

MvGUI_scaleRefr:
	Gui %A_Gui%: Destroy
	Send,{Esc}whatsMyScaleOffset{Enter}
	return

MvGUI_rename:
	Gui %A_Gui%: Destroy
	GoSub,Toggle_Armed
	SetCapsLockState, On
	Send,{Esc}rcl{Enter}
	return

view_isolate:
	Gui %A_Gui%: Destroy
	Send,isolate{Enter}
	return

view_hide:
	Gui %A_Gui%: Destroy
	Send,hideobjects{Enter}
	return

view_restore:
	Gui %A_Gui%: Destroy
	Send,{Esc}unisolate{Enter}
	return

view_raise:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,drwf{Enter}
	}
	else {
		Send,drwa{Enter}
	}
	return

view_lower:
	Gui %A_Gui%: Destroy
	Send,drwb{Enter}
	return

view_bmask:
	Gui %A_Gui%: Destroy
	Send,bmask{Enter}
	return

MvGUI_reLisp:
	Gui %A_Gui%: Destroy
	Send,{Esc}reloadlisp{enter}
	return

MvGUI_center:
	Gui %A_Gui%: Destroy
	Send,ctr{enter}
	return

MvGUI_desegg:
	Gui %A_Gui%: Destroy
	Send,{Esc}desegg{enter}
	return

MvGUI_2dDims:
	Gui %A_Gui%: Destroy
	Send,{Esc}dimelevation{enter}
	return

MvGUI_walls:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}qc2dwall{enter}
	}
	else {
		Send,{Esc}mvdraw2dwalls{enter}
	}
	return

MvGUI_section:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}mvdrawdynamicproductimages{enter}
	}
	else {
		Send,{Esc}mvdrawcrosssection{enter}
	}
	return

MvGUI_ucs:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}rse{enter}
	}
	else {
		Send,{Esc}wse{enter}
	}
	return

MvGUI_redraw:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}regen{enter}
	}
	else {
		Send,{Esc}mvredrawselectedproducts{enter}
	}
	return

MvGUI_tabs:
	Gui %A_Gui%: Destroy
	if GetKeyState("BS") {
		Send,{Esc}ctd{enter}
	}
	else {
		Send,{Esc}cpt{enter}
	}
	return

MvGUI_bump:
	Gui %A_Gui%: Destroy
	Send,mvbump{enter}
	return

; /=================================================================================================================================================/
; /=== Popup GUIs ==================================================================================================================================/
; /=================================================================================================================================================/

#IfWinActive, popupGuis

Esc::
	Suspend,Permit
	Gui popupGuis: Destroy
	return

; /=================================================================================================================================================/
; /=== AutoCAD =====================================================================================================================================/
; /=================================================================================================================================================/

#IfWinActive, Autodesk AutoCAD 2024

a::Send,co{enter}
BS & a::Send,mir{enter}

b::MvGUI()
BS & b:: ; Renaming Utility
	GoSub,Click_Text_Box
	GoSub,Update_Controls
	if CheckWinTitleActive("Enhanced Attribute Editor", 1.5) {
		if (CurrentGUITab = "Doc") or (gui_num_input = "Typ") {

			ControlGetText, focusText, RichEdit20A1, Enhanced Attribute Editor
			txtSplit := StrSplit(focusText)
			startChar := txtSplit[1]
			if startChar contains 0,1,2,3,4,5,6,7,8,9
				isDetail := False	
			else
				isDetail := True
			Send,{Enter}%arch_room_number%
			if (isDetail == False) {
				Send,{Enter}
			}
			else {
				Send,{Space}
			}
			Send,%arch_room_name%{Enter}
			ControlGet,isSkip,checked,,Skip,%GuiName%
			if (isSkip = 1) {
				Send,{Tab}{Enter}
			}
		}
		else if (gui_num_input = "EP") {
			Send,%gui_elev%.
			if (gui_product < 10) {
				Send,0
			}
			Send,%gui_product%{Tab}{enter}
			if CheckWinTitleActive("Autodesk AutoCAD", 1) {
				gui_product := gui_product + 1
			}
			else {
				Send,{Esc}
			}
		}
		else if (gui_num_input = "EE") {
			Sleep,100
			Send,{End}{Left 3}{LShift Down}{Home}{LShift Up}%gui_elev%{Tab}{enter}{Esc}
		}
		else if (gui_num_input = "Sec") { ; renames section, leaves page # alone
			Send,S%gui_product%{Tab}{enter}
			gui_product := gui_product + 1
		}
		else if (gui_num_input = "Pg") {
			Send,%gui_product%{tab}{enter}
			gui_product := gui_product + 1
		}
		else if (gui_num_input = "Blind") {
			Send,%gui_elev%.
			if (gui_product < 10) {
				Send,0
			}
			Send,%gui_product%
			gui_product := gui_product + 1
		}
		else if (gui_num_input = "size") {
			Send,{Tab 3}{Right}!w.5{Tab 2}{Enter}
		}
		GuiControl,,gui_product,%gui_product% ; Updates GUI boxes
	}
	else {
		Send,{Esc}
	}
	return

c::Send,m{enter}
BS & c::Send,mvmove{enter}

d::Send,rot{enter}
BS & d::Send,scar{enter}

e::Send,d{enter} ; Linear dimension
BS & e::Send,dc{enter} ; lin dim follows same plane as previous

f::Send,{esc}mvdrawpartin2d{enter}

g::Send,tr{enter} ; trim
BS & g::Send,pline{enter}

h::LayerGUI()

i::Send,j{enter} ; join
BS & i::Send,x{enter} ; explode

j::Send,e{enter}

k::F8
BS & k::^h

l::Send,mvoverdrivepro{enter} ; AKA Product List

m::Send,mveditdes{enter} ; MV Edit Design Data AKA Spread Sheet
BS & m::Send,mvpartprop{enter} ; open partprops

n::BlockGUI()

o::Send,{Esc}{+}9{enter}
BS & o::Send,{Esc}nextlayout{enter}

q::Send,str{enter} ; stretch
BS & q::Send,ma{enter} ; match attributes

r::Send,mvproductprompts{enter}
BS & r::Send,mvsubassemblyprompts{enter}

s::DimGUI()

t::CameraGUI()

u::Send,{Esc}rect{enter}
BS & u::Send,{Esc}fse{enter}

w::Send,offset{enter} ; offset
BS & w::Send,woff{enter} ; offset 5" for walls

y::Send,{Esc}-9{enter}
BS & y::Send,{Esc}previouslayout{enter} ; cross out block

BS & End:: Send,{Esc}saveall{Enter}

,::Send,{Esc}fe{enter}
BS & ,::Send,{Esc}fb{enter}

F1::Send,mvsubas{enter} ; MV Subassembly Prompts

F2::
	Suspend,Permit
	Send,textedit{enter}
	GoSub,Toggle_Armed
	return

F17:: ; pan viewport
	Suspend,Permit
	Send,{Esc}dpan{enter}
	return

; /=================================================================================================================================================/
; /=== AutoCAD, Product List =======================================================================================================================/
; /=================================================================================================================================================/

#IfWinActive, Product List

F1::
	Suspend,Permit
	Send,{Esc}{AppsKey}{Down}{enter} ; Product Prompts
	return

F3::
	Suspend,Permit
	Send,{Esc}{AppsKey}aa{enter} ; Add Comment
	return

; /=================================================================================================================================================/
; /=== AutoCAD, Edit Formula =======================================================================================================================/
; /=================================================================================================================================================/

#IfWinActive, Edit Formula

Space::Send,_ ; convert white space to US in formula editor

; /=================================================================================================================================================/
; /=== AutoCAD, Edit Design Data ===================================================================================================================/
; /=================================================================================================================================================/

#IfWinActive Edit Design Data ; MV Spreadsheet

F1::
	Suspend,Permit
	BlockInput, MouseMove
	MouseMoveRelativeToWindowBottomRight(600, 50, "Edit Design Data") ; Move to 'Save & Redraw'
	Send,{LButton}
	BlockInput,MouseMoveOff
	return
	
F3::
	Suspend,Permit
	BlockInput, MouseMove
	MouseMoveRelativeToWindowBottomRight(450, 50, "Edit Design Data") ; Move to 'Save & Close'
	Send,{LButton}
	BlockInput,MouseMoveOff
	return

F5::
	Suspend,Permit
	BlockInput, MouseMove
	MouseMoveRelativeToWindowBottomRight(300, 50, "Edit Design Data") ; Move to 'Save, Close, & Redraw'
	Send,{LButton}
	BlockInput, MouseMoveOff
	return

; /=================================================================================================================================================/
; /=== AutoCAD, Drawing Style ======================================================================================================================/
; /=================================================================================================================================================/

#IfWinActive Drawing Style ; MV Redraw Products

2::
	Suspend, Permit
	MouseGetPos, posX, posY
	searchArea := GetWindowDimensions("Drawing Style")
	searchX1 := searchArea[1]
	searchY1 := searchArea[2]
	MouseMove, searchX1, searchY1, 0
	ImageSearch,projectX,projectY,0,0,searchX1,searchY1,*Trans2e2e2e .\util\planDrawings2D.png
	if (ErrorLevel = 2) { ; unable to perform search
		MsgBox, Unable to perform image search. Please verify filepath to image is correct. Terminating.
		MouseMove, posX, posY, 0
	}
	else if (ErrorLevel = 1) { ; unable to locate image
		MsgBox, Unable to locate "2D Plan Drawings". Terminating.
		MouseMove, posX, posY, 0
	}
	else if !ErrorLevel {
		BlockInput, MouseMove
		MouseMove, projectX, projectY, 0
		Send,{LButton}{Enter}
		BlockInput, MouseMoveOff
	}
	return

3::
	Suspend, Permit
	MouseGetPos, posX, posY
	searchArea := GetWindowDimensions("Drawing Style")
	searchX1 := searchArea[1]
	searchY1 := searchArea[2]
	MouseMove, searchX1, searchY1, 0
	ImageSearch,projectX,projectY,0,0,searchX1,searchY1,*Trans2e2e2e .\util\planDrawings3D.png
	if (ErrorLevel = 2) { ; unable to perform search
		MsgBox, Unable to perform image search. Please verify filepath to image is correct. Terminating.
		MouseMove, posX, posY, 0
	}
	else if (ErrorLevel = 1) { ; unable to locate image
		MsgBox, Unable to locate "3D Drawings (Full Machining)". Terminating.
		MouseMove, posX, posY, 0
	}
	else if !ErrorLevel {
		BlockInput, MouseMove
		MouseMove, projectX, projectY, 0
		Send,{LButton}{Enter}
		BlockInput, MouseMoveOff
	}
	return

; /=================================================================================================================================================/
; /=== AutoCAD, Place Product ======================================================================================================================/
; /=================================================================================================================================================/

#IfWinActive, Place Product

Enter::
NumpadEnter::
	Suspend, Permit
	MvClickOkayButton("Place Product")
	return

#IfWinActive, Select Products On Wall 

Enter::
NumpadEnter::
	Suspend, Permit
	MvClickOkayButton("Select Products On Wall")
	return

; /=================================================================================================================================================/
; /=== AutoCAD, Microvellum Projects ===============================================================================================================/
; /=================================================================================================================================================/

#IfWinActive, Microvellum, Projects ; select project window
Enter::
NumpadEnter::
	Suspend,Permit
	searchArea := GetWindowDimensions("Microvellum")
	ImageSearch,projectX,projectY,0,0,searchArea[1],searchArea[2],*Trans2e2e2e .\util\ahk_acad_mvProject.png
	if ErrorLevel {
		return
	}
	else if !ErrorLevel {
		BlockInput, MouseMove
		MouseMove, projectX, projectY+10, 0
		Send,{LButton 2}
		BlockInput, MouseMoveOff
	}
	return

; /=================================================================================================================================================/
; /=== AutoCAD, Microvellum Room ===================================================================================================================/
; /=================================================================================================================================================/

#IfWinActive, Microvellum, Room ; select room window
Enter::
NumpadEnter::
	Suspend,Permit
	searchArea := GetWindowDimensions("Microvellum")
	ImageSearch,projectX,projectY,0,0,searchArea[1],searchArea[2],*Trans2e2e2e .\util\ahk_acad_mvRoom.png
	if ErrorLevel {
		return
	}
	else if !ErrorLevel {
		BlockInput, MouseMove
		MouseMove, projectX, projectY+10, 0
		Send,{LButton 2}
		BlockInput, MouseMoveOff
	}
	return

; /=================================================================================================================================================/
; /=== AutoCAD, Processing Center ==================================================================================================================/
; /=================================================================================================================================================/

#IfWinActive, Processing Center - Work Order

F17:: ; Output print groups
	Suspend,Permit
	BlockInput, MouseMove
	MouseMoveRelativeToWindow(35,35,"Processing Center")
	Send,{LButton}
	Sleep,10
	Send,{Down 5}{Right}{Down}{enter}
	if CheckWinTitleActive("Select Item", 5) {
		MouseMoveRelativeToWindow(40,85,"Select Item")
		Send,desmond_engineering{LButton}
		Sleep,100
		Send,{LButton}
	}
	else {
		MsgBox, Window did not appear
	}
	BlockInput, MouseMoveOff
	return

F16::
	Suspend,Permit
	GoSub,AutomateMachineAssignment
	return

; /=================================================================================================================================================/
; /=== Revu Bluebeam ===============================================================================================================================/
; /=================================================================================================================================================/

#IfWinActive, ahk_exe Revu.exe ; Revu Bluebeam

~^+s:: ; disarms script during saving process to prevent hotkey interference
	armed = 0
	Gui 1:Color,Blue
	GuiControl,Font,Arm
	GuiControl,Font,Float
	Suspend,Toggle
	return

1::Send,!b ; bookmarks

2::Send,!t ; thumbnails

3::Send,!c ; studio

4::Send,!a ; recent files

F15::
	Suspend,Permit
	Send,^+m ; flatten markups
	if CheckWinTitleActive("Flatten Markups", 2)
	{
		Send,{enter}
	}
	else
	{
		MsgBox, Flatten Markups window not found
	}
	return

F16::
	Suspend,Permit
	Send,{Ctrl Down}{Shift Down}h{Ctrl Up}{Shift Up}
	if CheckWinTitleActive("Reduce File Size", 2)
	{
		Send,{Enter}
	}
	if CheckWinTitleActive("Overwrite Existing File", 2)
	{
		Send,{Tab}{Enter}
	}
	if CheckWinTitleActive("Reduce File Size Results", 5)
	{
		Send,{Enter}
	}
	return

F14::
	Suspend,Permit
	searchArea := GetWindowDimensions("ahk_exe Revu.exe")
	searchX1 := searchArea[1]
	searchY1 := searchArea[2]
	topBarHeight := 100
	searchX0 := 0
	popoutBarWidth := 350
	Loop {
		Send,{RAlt Down}u{RAlt Up} ; toggle measurements tab
		Sleep,500
		ImageSearch,trashX,trashY,searchX0,topBarHeight,searchX1,searchY1,*Trans2e2e2e .\util\ahk_bluebeam_trash.png
	} until !ErrorLevel
	BlockInput, MouseMove
	MouseMove, trashX, trashY, 0
	Send,{LButton}
	MouseMove, trashX + 20, trashY + 60, 0
	Sleep,100
	Send,{LButton}
	BlockInput, MouseMoveOff
	Send,{RAlt Down}u{RAlt Up} ; toggle measurements tab
	return

Left::
	Suspend,Permit
	Send,^{Left}
	return

Right::
	Suspend,Permit
	Send,^{Right}
	return

Numpad4::Send,^{Left}

Numpad6::Send,^{Right}

#IFWinActive, Check In

Enter::
	Suspend,Permit
	Send,!h
	return

; /=================================================================================================================================================/
; /=== MS Excel ====================================================================================================================================/
; /=================================================================================================================================================/

#IfWinActive,ahk_exe excel.exe

F15::
	Suspend,Permit
	Send,^+y   ; Sort my jobs by ship
	return

F16::
	Suspend,Permit
	Send,^+u  ; Sort my jobs by release
	return

F17::
	Suspend,Permit
	Send,^+j  ; Resets filters
	return

F9::
	Suspend,Permit
	Send,^+t   ; Highlights selection yellow
	return

F10::
	Suspend,Permit
	Send,^+g   ; Removes highlighting
	return

F18::
	Suspend,Permit
	Send,^5   ; Strike-through text
	return

F12::
	Suspend,Permit
	Send,{Esc 5}!h
	if CheckWinTitleActive("ahk_class Net UI Tool Window Layered", 1) {
		Send,m ; Merge box
		Sleep,100
		Send,m ; Merge cells
	} else {
		Send,{Esc}
		return
	}
	Send,{Esc 5}!h
	if CheckWinTitleActive("ahk_class Net UI Tool Window Layered", 1) {
		Send,w ; line wrap
	} else {
		Send,{Esc}
		return
	}
	return

^!s::Send,{F12}

; /=================================================================================================================================================/
; /=== MS File Explorer ============================================================================================================================/
; /=================================================================================================================================================/

#IfWinActive,ahk_exe explorer.exe

PrintScreen::
	Suspend,Permit
	Send,{AppsKey}
	Sleep,10
	Send,pp{enter}
	return

; /=================================================================================================================================================/
; /=== ShopPak =====================================================================================================================================/
; /=================================================================================================================================================/

#IfWinActive,ahk_class TMainForm

validatePOS:
	sleepLength := 250
	Loop {
		PixelGetColor, curColor, 80, 150, RGB
		if (curColor == "0x0078D7") {
			ImageSearch,xnull,ynull,460,480,640,530, .\util\ahk_shoppak_REDACTED.png
			if (ErrorLevel = 2)
				MsgBox, Could not conduct the search.
			else if (ErrorLevel = 1) {
				GoSub,printPurchaseOrder
			}
			else {
				SPID := WinExist("A")
				Send,!f ; Open 'File' tab
				Sleep,%sleepLength%
				Send,c ; close current PO
				; WinActivate, ShopPak
			}
		}
		else {
			break
		}
	}
	MsgBox, 0, PO Automator, Function Escaped, 0.5 ; It's now okay to rerun
	return

F17::
	Suspend,Permit
	GoSub,validatePOS
	return

; /=================================================================================================================================================/
; /=== ShopPak, Login Window =======================================================================================================================/
; /=================================================================================================================================================/

#IfWinActive, ahk_class TPasswordDlg

BS::
	Suspend,Permit
	FileRead, shoppakPW, ./util/_secret_/shoppak.txt
	Send,%shoppakPW%{enter}
	return

; /=================================================================================================================================================/
; /=== We Have bash At Home ========================================================================================================================/
; /=================================================================================================================================================/

#IfWinActive, ahk_exe powershell.exe

Esc::
	Suspend,Permit
	Send,{Esc}
	SetCapsLockState, Off
	return

#IfWinActive, ahk_exe pwsh.exe

Esc::
	Suspend,Permit
	Send,{Esc}
	SetCapsLockState, Off
	return

; /=================================================================================================================================================/
; /=== General =====================================================================================================================================/
; /=================================================================================================================================================/

#IfWinActive

F24::
	Suspend,Permit
	GoSub,Toggle_Armed
	return

#q::
ScrollLock::
	Suspend,Permit
	GoSub,KB_Float_Toggle
	GuiControl, Choose, Main, |1
	return	

#Enter::
	Suspend,Permit
	If WinExist("ahk_exe pwsh.exe") {
		WinActivate, "ahk_exe pwsh.exe"
	}
	else {
		Run, "C:/Program Files/PowerShell/7/pwsh.exe"
	}
	return

#c::
	Suspend,Permit
	Send,!{F4}
	return

#z::
	Suspend,Permit
	Reload
	
~#1::
~#x::
	Suspend,Permit
	SetCapsLockState Off
	return

~#6::
	Suspend,Permit
	FileRead, shoppakPW, ./util/_secret_/shoppak.txt
	if CheckWinTitleActive("ahk_class TPasswordDlg", 10)
		Send,%shoppakPW%{enter}
	return

NumLock::
	Suspend,Permit
	return

F22::
PrintScreen::
	Suspend,Permit
	GoSub,Open_Tracking
	return

; /=================================================================================================================================================/
; /=== Book of Spells ==============================================================================================================================/
; /=================================================================================================================================================/

::refr::
	Suspend,Permit
	Send,refrigerator{Space}
	return

::refrbo::
	Suspend,Permit
	Send,refrigerator{Enter}by others{Space}
	return

::lazer::
	Suspend,Permit
	Send,laser{Space}
	return

:?:~=::
:?:=~::
	Suspend,Permit
	Send,{RAlt Down}{Numpad2}{Numpad4}{Numpad7}{RAlt Up}{Space} ; almost equal to symbol ≈
	return

:?:x=::
:?:=x::
	Suspend,Permit
	Send,{RAlt Down}{Numpad8}{Numpad8}{Numpad0}{Numpad0}{RAlt Up}{Space} ; not equal to symbol ≠
	return

:?:ddeg::
	Suspend,Permit
	Send,{RAlt Down}{Numpad2}{Numpad4}{Numpad8}{RAlt Up}{Space} ; degree symbol °
	return

:?:ddia::
	Suspend,Permit
	Send,{RAlt Down}{Numpad8}{Numpad9}{Numpad6}{Numpad0}{RAlt Up}{Space} ; diameter symbol Ø
	return

:?:+-::
:?:-+::
	Suspend,Permit
	Send,{RAlt Down}{Numpad2}{Numpad4}{Numpad1}{RAlt Up}{Space} ; plus/minus symbol ±
	return

:?:eaccent::
	Suspend,Permit
	Send,{RAlt Down}{Numpad0}{Numpad2}{Numpad3}{Numpad3}{RAlt Up} ; accented e é
	return

:?:%tm::
	Suspend,Permit
	Send,{RAlt Down}{Numpad0}{Numpad1}{Numpad5}{Numpad3}{RAlt Up}{Space} ; trade mark symbol ™
	return

:?:<=::
:?:=<::
	Suspend,Permit
	Send,{RAlt Down}{Numpad2}{Numpad4}{Numpad3}{RAlt Up}{Space} ; less-than-equal symbol ≤
	return

:?:>=::
:?:=>::
	Suspend,Permit
	Send,{RAlt Down}{Numpad2}{Numpad4}{Numpad2}{RAlt Up}{Space} ; greater-than-equal symbol ≥
	return

::d2ddrawer::
::d2d1::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	SetCapsLockState, Off
	Send,DRAW2DBOX CabinetDoor
	SetCapsLockState, %clState%
	return

::d2d7::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	SetCapsLockState, Off
	Send,DRAW2DBOX OpenShelf
	SetCapsLockState, %clState%
	return

::d2d8::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	SetCapsLockState, Off
	Send,DRAW2DBOX Shelf
	SetCapsLockState, %clState%
	return

::d2ddoor::
::d2d9::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	SetCapsLockState, Off
	Send,DRAW2DDOOR CabinetDoor
	SetCapsLockState, %clState%
	return

::%ng:: ; Microvellum, convert formula to 'draw only' material
	Suspend,Permit
	Send,{Home}{Right}"-"&
	return

::e3ql::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	SetCapsLockState, Off
	Send,Ext 3 Quarters Left
	SetCapsLockState, %clState%
	return

::e3qr::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	SetCapsLockState, Off
	Send,Ext 3 Quarters Right
	SetCapsLockState, %clState%
	return

::e3qb::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	SetCapsLockState, Off
	Send,Ext 3 Quarters Both
	SetCapsLockState, %clState%
	return

:?:%sst::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	SetCapsLockState, Off
	Send,M{!}Counter_Top_SS_Thickness
	SetCapsLockState, %clState%
	return

::r1el::
::1erl::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	Send,Reveal 1 Eighth Left{Enter}
	SetCapsLockState, %clState%
	return

::r1er::
::1err::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	Send,Reveal 1 Eighth Right{Enter}
	SetCapsLockState, %clState%
	return

::r1eb::
::1erb::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	Send,Reveal 1 Eighth Both{Enter}
	SetCapsLockState, %clState%
	return

::os4s::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	Send,Oversized for scribe{Enter}
	SetCapsLockState, %clState%
	return

::os4m::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	Send,Oversized for miter{Enter}
	SetCapsLockState, %clState%
	return

::os4f::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	Send,Oversized for flush trim{Enter}
	SetCapsLockState, %clState%
	return

::sdd::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	Send,See Detail D
	SetCapsLockState, %clState%
	return

::ssfb::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	Send,Solid Surface for Batch{Space} 
	SetCapsLockState, %clState%
	return

::mtodir::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	Send,Material Takeoffs{Enter} 
	SetCapsLockState, %clState%
	return

::%drawtoe%::
	Suspend,Permit
	Send,_drawLeftToe{Tab}1{Tab}=side_thickness_left{Tab}=L{!}toe_kick_height{Tab 2}="-"&L{!}Left_side_material_name{Tab 5}
	Send,draw only{Tab}4{Tab 2}0{Tab}0{Tab}0{Tab}0{Tab}-90{Tab}0{Tab 2}Draw2DBox OpenShelf{Return}{Home}{Left}
	Send,_drawRightToe{Tab}1{Tab}=side_thickness_right{Tab}=L{!}toe_kick_height{Tab 2}="-"&L{!}Right_side_material_name{Tab 5}
	Send,draw only{Tab}3{Tab 2}=Width{Tab}0{Tab}0{Tab}0{Tab}-90{Tab}0{Tab 2}Draw2DBox OpenShelf{Return}
	return

#IfWinActive, Autodesk AutoCAD 2024

::uno::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	SetCapsLockState, Off
	Send,u.n.o.
	SetCapsLockState, %clState%
	return

::nic::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	SetCapsLockState, Off
	Send,N.I.C.
	SetCapsLockState, %clState%
	return

::rdbc::
	Suspend,Permit
	clState := A_StoreCapsLockMode
	SetCapsLockState, Off
	Send,reception desk by custom
	SetCapsLockState, %clState%
	return

; /=================================================================================================================================================/
; /=================================================================================================================================================/
; /=================================================================================================================================================/
