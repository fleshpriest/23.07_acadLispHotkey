; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Global Variables ----------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(setq useCommandLine 1 
    runDebug t)

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Set ACAD Enviornment ------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(setvar '2dRetainModeLevel 2    ; seemingly undocumented
    'acadLspAsDoc 0             ; controls how ACAD will load the lisp file
    'angDir 1                   ; clockwise rotational values
    'attDia 0                   ; sets insert command to use command prompts
    'autoSnap 55                ; legacy value := 39
    'ceLtScale 1                ; sets object lintype scaling factor
    'cmdEcho 0                  ; suppresses dialouge boxes within commandline
    'constraIntInfer 0          ; this causes unintended line stickage if enabled
    'cursorSize 25              ; sets length of cursor's arms
    'defaultGizmo 3             ; disables gizmo when object selected in 3d visual mode
    'dimAdec 0                  ; disables decimils when displaying angluar dimensions (independant of dimdec)
    'dimAzin 2                  ; supresses trailing zeroes for decimal angular dimensions
    'dimClrD 1                  ; dimension arrow color, red
    'dimClrE 1                  ; dimension extension color, red
    'dimClrT 0                  ; dimension text color, by block
    'dimFrac 2                  ; controls dimension fractional layout
    'dimZin 12                  ; controls dimension zero suppression
    'dynMode 3                  ; contols dynamic input
    'fileTabPreview 0           ; disables dwg preview on tab hover
    'fileTabThumbHover 0        ; disables preloading of drawings on tab mouse hover
    'gridMode 0                 ; disables background grid
    'gripColor 5                ; set color of grips @ unselected
    'gripHot 255                ; set color of grips @ selection
    'gripHover 255              ; set color of grips @ hover
    'highlight 1                ; controls how selected objects are displayed
    'layerEvalCtl 0             ; disables evaluation and notification of new layers
    'layoutRegenCtl 0           ; supresses layout regeneration after first page load, reads from cache after
    'lispInit 0                 ; preservers AutoLISP variables & functions between drawings
    'ltScale 0.375              ; sets line type scale
    'mTextAutoStack 0           ; disables automatic fraction stack on text
    'menuBar 0                  ; toggles menubar "Home, Insert, Annotate, etc" display
    'mirrText 0                 ; retains text orientation through mirroring
    'msLtScale 1                ; model space linetypes scaled by annotation type
    'osMode 14847               ; user snap preferences
    'paletteOpaque 1            ; controls menu opacitiy
    'pdMode 3                   ; controls how point objects are displayed 
    'pickFirst 1                ; allows selection before running commands
    'refPathType 2              ; full file path names by default
    'regenMode 0                ; controls automatice regenerations
    'rememberFolders 1          ; consisitent filepath based on the directory where AutoCAD launched
    'reportError 0              ; if you chose to send or not send the report does it even make a difference?
    'revCloudArcVariance 1      ; adds variances to arc lengths on revc
    'revCloudCreateMode 1       ; defaults to rectangular points
    'rolloverTips 0             ; object hover tooltips
    'sdi 0                      ; single drawing instance
    'selectionCycling 0         ; disables selection dialouge box 
    'snapmode 0                 ; because why do some people even enable this?!
    'textAllCaps 1              ; converts all new TEXT and MTEXT commands to uppercase
    'toolTips 1                 ; controls on hover tooltips  
    'whipThread 3               ; multithreading for regen & redraw
    'wipeoutFrame 2             ; wipeout frame does not appear once plotted.
    'xRefLayer "TITLE"          ; controls layer which xRefs are placed on
    'zoomFactor 10)             ; speed of zoom, default=60

(if runDebug (princ "Init complete\n"))

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- General -------------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(defun *error* ( msg / )
	(c:snapReset)
	(princ (strcat "error: " msg "\n")))

(defun LM:open ( target / rtn shl ) ; Utility written by Lee Mac, launches an external File Browser window at the specified target
	;; target - [int/str] File, folder or ShellSpecialFolderConstants enum
	(if (and (or (= 'int (type target)) (setq target (findfile target)))
		(setq shl (vla-getinterfaceobject (vlax-get-acad-object) "shell.application")))
		(progn
			(setq rtn (vl-catch-all-apply 'vlax-invoke (list shl 'open target)))
	        (vlax-release-object shl)
	        (if (vl-catch-all-error-p rtn)
				(prompt (vl-catch-all-error-message rtn))
				t))))

(defun LM:str->lst ( str del / pos ) ; By Lee Mac // str [str]: str to process, del [str]: delimiter
    (if (setq pos (vl-string-search del str))
        (cons (substr str 1 pos) (LM:str->lst (substr str (+ pos 1 (strlen del))) del))
        (list str)))

(defun convertStringToList (input / entry output)
	(repeat (setq entry (strlen input))
		(setq output (cons (substr input entry 1) output))
		(setq entry (1- entry)))
	(princ output))

(defun c:reloadLisp ( / mainPath testPath)
	(load "main.lsp" "Error loading primary lisp file"))

(defun c:getDotPairs ( / ent entl ct )
	(setq ent (car (entsel)))
	(setq entl (entget ent))             ; Set entl to association list of last entity.
	(setq ct 0)                          ; Set ct (a counter) to 0.
	(textpage)                           ; Switch to the text screen.
	(princ "\nentget of last entity:")
	(repeat (length entl)                ; Repeat for number of members in list:
		(print (nth ct entl))        ; Output a newline, then each list member.
		(setq ct (1+ ct)))           ; Increments the counter by one.
	(terpri))

(defun c:dumpObjectProperties ( / object file)
	(setq object (car (entsel)) file (open "objectProperties.txt" "w"))
	(write-line (dumpallproperties object 0) file)
	(close file))

(defun rmIndexFromList ( items lst / i ) ; 0-indexing, written by Lee Mac
	; Example: (rmIndexFromList '(0 2) '("A" "B" "C" "D")) --> ("B" "D")
	(setq i -1)
	(vl-remove-if '(lambda ( x ) (member (setq i (1+ i)) items)) lst))

(defun getScaleOffset ( / )
	(princ (* (getvar 'dimScale) (getvar 'dimExe) 2)))

(defun formatDimsForLeader (dim / ) ; format dimensions to be used in leaders
	(rtos dim 5 4))

(defun convertRealToStr ( input / ) ; making this a function because I keep forgetting I need to do this
	(rtos input 2))

(defun LM:ss->ent ( ss / i l ) ; written by Lee Mac
    (if ss
        (repeat (setq i (sslength ss))
            (setq l (cons (ssname ss (setq i (1- i))) l)))))

(defun LM:createdirectory ( dir / ) ; written by Lee Mac
  ; By Lee Mac // dir [str]: directory to create, returns t for successful creation else nil
    ((lambda ( fun )
		((lambda ( lst ) (fun (car lst) (cdr lst)))
        (vl-remove "" (LM:str->lst (vl-string-translate "/" "\\" dir) "\\"))))
        (lambda ( root lst / dir )
            (if lst
                (if (or 
						(vl-file-directory-p (setq dir (strcat root "\\" (car lst))))
						(vl-mkdir dir))
                    (fun dir (cdr lst))))))
    (vl-file-directory-p dir))

(defun display-msg (msg mode / )
	(if (= mode 0)
		(prompt (strcat "\n" msg))
		(alert msg))
	(princ))

(defun UserSelect ( / ) ; pass currently highlighted objects as user selection, if none - prompt user for selection.
	(if (ssget "_I") (ssget "_I") (ssget)))

(defun UserCancel ( / ) ; utility meant to cancel out of partial lisp functions
	(command)(command))

(defun userVerify ( userPrompt / userResponse )
	(setq userResponse (getstring userPrompt))
	(if (equal userResponse "")
		(prin1 t)
		(prin1 nil)))

(defun getMidPoint (p0 p1 / xVal yVal) ; gets 2D midpoint betweeen two points given LIST point
	(setq xVal (/ (+ (car  p0) (car  p1)) 2))
	(setq yVal (/ (+ (cadr p0) (cadr p1)) 2))
	(princ (list xVal yVal)))

(defun c:gobl ( / ) ; open block library in file explorer
	(LM:open "C:/path/to/dir"))

(defun c:gosink ( / path validInput index value msg userInput) ; open personal plumbing blocks in file explorer
	(setq path "C:/path/to/dir")
	(while (vl-file-directory-p path)
		(setq validInput nil) ; reset for each loop
		(setq index (rmIndexFromList '(0 1) (vl-directory-files path)))
		(setq value 1)
		(setq msg "Make a selection:\n00: Open in File Explorer ")
		(foreach entry index
			(progn
			(setq msg (strcat msg "\n" (rtos value 2 0) ": " entry))
			; (setq msg (strcat msg "\n" (if (< value 10) "0") (rtos value 2 0) ": " entry)) ; stringp issues
			; (setq msg (strcat msg "\n" (rtos value 2) ": " entry)) ; Legacy version
			(setq value (+ 1 value))
			)
		)
		(while (not validInput)
			(setq userInput (getint msg))
			(cond
				((= userInput 0) 
					(LM:open path)
					(exit)
				)
				((< userInput 0) (princ "Invalid input"))
				((> userInput (length index)) (princ "Invalid input"))
				(t 
					(setq path (strcat path "/" (nth (- userInput 1) index)))
					(princ (strcat "......debug, path=\n" path "\n.......\n"))
					(setq validInput t)
				)
			)
		)
	)
	(command ".insert" path "explode" "yes" pause "" "" pause))

sinkBlockPrep ( allDeetsLayer / ) ; workflow for preparing sink models for block library
	; allDeetsLayer : expects t or nil (t if combining cutout template w/ sink plan)
	(command-s ".undo" "begin")
	(if allDeetsLayer
		(progn
		(command-s ".chProp" (ssget "_a") "" "color" "byLayer" "")
		(command-s ".chProp" (ssget "_a") "" "_layer" "deets" "")))
	(command-s ".join" (ssget "_a") "")
	(command   ".copybase" pause (ssget "_a") "")
	(command-s ".erase" (ssget "_a") "")
	(command-s ".pasteblock" '(0 0))
	(c:rat)
	(c:zoomout)
	(command-s ".undo" "end"))

(defun c:tcc ( / lst ) ; user defined tcase, when defined here it is callable
	(acet-error-init (list '("cmdecho" 0) t))
	(if (setq lst (acet-tcase-ui t))
		(acet-tcase (car lst) (cadr lst)))
	(acet-error-restore))
 
(defun c:whatsMyScaleOffset ( / )
	(getScaleOffset)(terpri))

(defun c:rr ( / p1 *error*) ; rotate with reference
	(defun *error* (msg)
		(princ msg)(terpri)(exit))
	(command ".rotate" (ssget) "" (setq p1 (getpoint "Rotation origin")) "reference" p1 pause pause))

(defun c:revc ( / ds ) ; draw a revCloud scaled to current dimSty
	; revCloud uses 'object' mode via LISP and this does not seem to be changable
	; for that reason we're going to draw & convert a rectangle 
	(setq ds (/ (getvar 'dimScale) 6)) ; value is arbitrary & seems to look correct across scales
	(command-s ".undo" "begin")
	(command-s ".layer" "set" "hidden" "")
	(command ".rectangle" pause pause)
	(command-s "revCloud" "arc" ds "" "object" (entlast) "no")
	(command-s ".undo" "end"))

(defun c:rat ( / ) ; rip & tear
	(while (command-s ".purge" "blocks" "*" "no")
		(command-s ".purge" "blocks" "*" "no")) ; repeat command until no purgable blocks remain
	(command-s ".audit" "yes")
	(princ "\n\n     RIP\n     AND\n     TEAR\n")(terpri))

(defun c:resetPrefs ( / ) ; reset my preferences
	(c:snapReset)
	(c:fr2dwall))

(defun c:sysvariables ( / ) ; View & edit system variables.
	(command-s "sysVDlg"))

(defun c:dpan ( / ) ; override making pan loop indefinetly
	(while t
		(command ".pan" pause pause)))

(defun c:wt ( / ) ; one hand shortcut for wipeout
	(command-s ".wipeout"))

(defun c:sac ( / samObj filLst) ; select all color (layer)
	(if (setq samObj (entsel "\nSelect object at desired layer > "))
	(progn
		(setq filLst (assoc 8 (entget (car samObj))))
		(sssetfirst nil (ssget "_X" (list filLst))))))

(defun c:scar ( / userSelection scaleOrigin) ; scale with reference, to save a few clicks
	(setq userSelection (ssget))
	(setq scaleOrigin (getpoint "Scaling origin "))
	(command ".scale" userSelection "" scaleOrigin "reference" scaleOrigin pause pause))

(defun c:dv ( / userSelection) ; divide, one handed shortcut. note - overwrites builtin dv(iew) shortcut
	(setq userSelection	(ssget))
	(command ".divide" userSelection pause))

(defun c:caa ( / ) ; references express tool command
	(c:closeallother))

(defun c:sas ( / ) ; references express tool command
	(c:saveall))

(defun c:drwf ( / ) ; bring to front
	(command-s ".drawOrder" "front"))

(defun c:drwb ( / ) ; bring to back
	(command-s ".drawOrder" sel "back"))

(defun c:drwa ( / sel ) ; bring above
	(if (ssget "_I")
		(command ".drawOrder" "above" pause)
		(command ".drawOrder" pause "above" pause)))

(defun c:drwu ( / sel ) ; bring under
	(if (ssget "_I")
		(command ".drawOrder" "below" pause)
		(command ".drawOrder" pause "below" pause)))

(defun c:eqq ( / ) ; apply personal settings to drafting drawing
	(c:sty3-8)
	(c:fr2dwall)
	(c:draftTemplate))

(defun c:egg ( / ) ; apply personal settings to new engineering drawing
	(c:sty1-2)
	(c:fr2dwall)
	(c:engTemplate)
	(c:xx))

(defun c:bmask ( / ss1 i ent input)
	(setq ss1 (ssget '((0 . "MULTILEADER,MTEXT,DIMENSION"))))
	(if ss1
		(progn
			(setq i 0)
			(while (< i (sslength ss1))
				(setq ent (ssname ss1 i))
				(if (= (cdr (assoc 0 (entget ent))) "DIMENSION")
					(progn
						(setq input (abs (- (getpropertyvalue ent "dimtfill") 1)))
						(setpropertyvalue ent "dimtfill" input))
					(progn
						(setq input (abs (- (getpropertyvalue ent "backgroundfill") 1)))
						(setpropertyvalue ent "backgroundfill" input)))
				(setq i (1+ i)))))
	(vl-cmdf ".drawOrder" ss1 "" "f")
	(terpri))

(defun c:dimBMask ( / cnt ent entData newEntData num ss1) ; backfill dimensions
	(setq ss1 (ssget '((0 . "Dimension")))) 
	(setq num (sslength ss1))
	(setq cnt 0)
	(repeat num
		(setq ent (entget (ssname ss1 cnt)))
		(setq entData '((-3 ("ACAD" (1000 . "DSTYLE") (1002 . "{") (1070 . 69) (1070 . 1) (1002 . "}")))))
		(setq newEntData (append ent entData))
		(entmod newEntData)
		(setq cnt (1+ cnt)))
	(vl-cmdf ".drawOrder" ss1 "" "f")
	(terpri))

(defun c:dbf ( / ) ; toggle default backfill / mask of dimensions
	(command-s ".dimtFill" (abs (- (getvar 'dimtFill) 1))))

(defun c:sm ( / ) ; set to current dimstyle by picking an object on desired dimstyle.
	(prompt "\select desired dimstyle...")
	(command-s ".dimStyle" "_r" ""))

(defun c:aqq ( / ) ; appload onehanded shortcut
	(command-s ".appLoad"))

(defun c:+9 ( / ) ; draw infinite line vertical phantom layer
	(command-s ".layer" "set" "d4c46345L3" "")
	(command ".xLine" "v" pause))

(defun c:-9 ( / ) ; draw infinite line horizontal phantom layer
	(command-s ".layer" "set" "d4c46345L3" "")
	(command ".xLine" "h" pause))

(defun c:cxz ( / ) ; one handed shortcut for toggling commandline
	(if (= useCommandLine 1)
		(command-s ".commandLineHide")
		(command-s ".commandLine"))
	(setq useCommandLine (abs (- useCommandLine 1))))

(defun c:woff ( / ) ; offset used for wall default thickness
	(command-s ".offset" 5))

(defun c:ccc ( / ) ; one hand shortcut for closing current tab
	(command-s ".close"))

(defun c:xx ( / p00 p01 p10 p11) ; cross off
	(while t;rue
		(setq p00 (getpoint "First corner"))
		(setq p11 (getpoint "Last corner"))
		(setq p01 (list (car p00) (cadr p11) 0))
		(setq p10 (list (car p11) (cadr p00) 0))
		(command-s ".pline" p00 p11 "")
		(command-s ".pline" p01 p10 "")))

(defun c:ctr ( / *error* sel p00 p01 p10 p11 cen0 cen1) ; centers a selection set against reference bounds
	(defun *error* ( msg / ) (c:snapReset) (princ msg) (terpri))
	(setq sel (if (ssget "_I") (ssget "_I") (ssget)))
	(c:snapSquare)
	(setq cen0 (getMidPoint (getpoint "\nObject(s) to be centered, corner 1") (getpoint "\nObject(s) to be centered, corner 2")))
	(setq cen1 (getMidPoint (getpoint "\nReference for center, corner 1") (getpoint "\nReference for center, corner 2")))
	(c:snapNone)
	(command-s ".move" sel "" cen0 cen1)
	(c:snapReset))
(defun c:gopl ( / ) ; open pic library in file explorer
	(LM:open "C:/path/to/dir"))

(defun c:goof ( / ) ; open order files in file explorer
	(LM:open "C:/path/to/dir"))

(defun c:gowz ( / ) ; Open room name utility
	(display-msg "\nA wizard arrives when they intend, please be patient.\n" 0)
	(LM:open "C:/path/to/file.xyz"))

(defun c:godoc ( / ) ; Open engineer docs utility
	(display-msg "\nA wizard arrives when they intend, please be patient.\n" 0)
	(LM:open "C:/path/to/file.xyz"))

(defun c:INeedAVacation ( / ) ; Vacation request or notice of absence, you decide.
	(LM:open "C:/path/to/file.xyz"))

(defun c:dottedPairReference ( / ) ; reference document for gloabal & local dotted pair organization aka DXF group codes
	(LM:open "https://help.autodesk.com/view/OARX/2024/ENU/?guid=GUID-3F0380A5-1C15-464D-BC66-2C5F094BCFB9"))

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Layers --------------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(setq togglableLayers (list "2d_item" "2d_text" "3d_item" "3d_product" "2d_dim" "2d_hatch" "2d_division" "2D_Solid_Surface" "2d_dimk") 
    3d_layers (list "3d-hwr" "3d_accessory" "3d_base" "3d_cabinet" "3d_cabinet_fe" "3d_cabinetdoor" "3d_cabinetdoorglass" "3d_cabinetdoorrail" "3d_cabinetdoorstile" "3d_cabinetinterior" "3d_ceiling" "3d_countertop" "3d_crown" "3d_die wall part" "3d_diewallinsideface" "3d_diewalloutsideface" "3d_divider" "3d_division" "3d_drawerparts" "3d_endpanel" "3d_faceframe" "3d_faceframerail" "3d_faceframestile" "3d_filler" "3d_furniture" "3d_glass" "3d_hwr" "3d_hwrassociationerror" "3d_kick" "3d_molding" "3d_open_shelf" "3d_opencabinetinterior" "3d_parts" "3d_rchwr" "3d_shelf" "3d_subtop" "3d_toekick" "3d_valance" "3d_wall"))

(defun layerCreation (lyrName color lineType lineWeight / )
	(command-s ".layer" "make"             lyrName "")
	(command-s ".layer" "color" color      lyrName "")
	(command-s ".layer" "LType" lineType   lyrName "")
	(command-s ".layer" "lw"    lineWeight lyrName ""))

(layerCreation "lines"     230 "continuous" "default")
(layerCreation "deets"       2 "continuous" "default")
(layerCreation "green"       3 "continuous" "default")
(layerCreation "tops"        4 "continuous" "default")
(layerCreation "wall"      150 "continuous" "default")
(layerCreation "splash"     30 "continuous" "default")
(layerCreation "cases"       7 "continuous" "default")
(layerCreation "hidden"      8 "hidden"     "default")
(layerCreation "phantom"   230 "phantom2"   "default")
(layerCreation "defpoints"   7 "continuous" "default")
(layerCreation "glass"     111 "continuous" "default")
(layerCreation "dim"         3 "continuous" "default")
(layerCreation "hatch"      11 "continuous" "default")
(layerCreation "wainscot"  230 "phantom2"    1)       
(layerCreation "3D_Wall"   150 "continuous" "default")
(layerCreation "d4c46345L3"  6 "continuous" "default")

(defun c:fr23 ( / ) ; freeze togglable layers
	(foreach layerName togglableLayers (command-s ".layer" "freeze" layerName "")))

(defun c:th23 ( / ) ; thaw togglable layers
	(foreach layerName togglableLayers (command-s ".layer" "thaw" layerName "")))

(defun c:fr3d ( / ) ; freeze my used 3d layers
	(foreach layerName 3d_layers (command-s ".layer" "freeze" layerName "")))

(defun c:th3d ( / ) ; thaw my used 3d layers
	(foreach layerName 3d_layers (command-s ".layer" "thaw" layerName "")))

(defun c:2dwa ( / ) ; toggle 2D walls frozen & thawed status
  (if (= 0 (cdr (assoc 70 (tblsearch "layer" "2d_Wall"))))
	(command-s ".layer" "freeze" "2d_Wall" "")
	(command-s ".layer" "thaw" "2d_Wall" "")))

(defun c:fr2dwall ( / )
	(command-s ".layer" "freeze" "2D_Wall" ""))

(defun c:th2dwall ( / )
	(command-s ".layer" "thaw" "2D_Wall" ""))

(defun c:qc2dwall ( / *error*) ; temporarily thaws 2d walls for elevation drawings
	(defun *error* (msg)
		(c:fr2dwall)
		(princ msg)(princ))
	(c:th2dwall)
	(c:555)
	(c:fr2dwall))

(defun c:111 ( / ) ; solid purple layer
	(command-s ".chProp" (ssget) "" "_layer" "lines" ""))

(defun c:colorPhantom ( / )
	(command-s ".chProp" (ssget) "" "C" 230 ""))

(defun c:222 ( / ) ; solid yellow layer, hardware
	(command-s ".chProp" (ssget) "" "_layer" "deets" ""))

(defun c:colorYellow ( / ) ; change color to yellow
	(command-s ".chProp" (ssget) "" "C" 2 ""))

(defun c:333 ( / ) ; solid green Layer
	(command-s ".chProp" (ssget) "" "_layer" "green" ""))

(defun c:colorGreen ( / ) ; change color to green
	(command-s ".chProp" (ssget) "" "C" 3 ""))

(defun c:444 ( / ) ; solid light blue layer, countertops
	(command-s ".chProp" (ssget) "" "_layer" "tops" ""))

(defun c:colorTops ( / ) ; change color teal
	(command-s ".chProp" (ssget) "" "C" 4 ""))

(defun c:555 ( / ) ; solid blue layer, walls
	(command-s ".chProp" (ssget) "" "_layer" "wall" ""))

(defun c:colorWalls ( / )
	(command-s ".chProp" (ssget) "" "C" 150 ""))

(defun c:666 ( / ) ; solid orange layer, special
	(command-s ".chProp" (ssget) "" "_layer" "splash" ""))

(defun c:colorOrange ( / ) ; change color to orange
	(command-s ".chProp" (ssget) "" "C" 30 ""))

(defun c:777 ( / ) ; solid white layer, casework
	(command-s ".chProp" (ssget) "" "_layer" "cases" ""))

(defun c:colorWhite ( / ) ; change color to white
	(command-s ".chProp" (ssget) "" "C" 7 ""))

(defun c:888 ( / ) ; dashed grey layer, hidden
	(command-s ".chProp" (ssget) "" "_layer" "hidden" ""))

(defun c:colorGrey ( / ) ; change color to grey
	(command-s ".chProp" (ssget) "" "C" 8 ""))

(defun c:999 ( / ) ; dashed purple layer, phantom
	(command-s ".chProp" (ssget) "" "_layer" "phantom" ""))

(defun c:``` ( / ) ; solid invisible layer, defpoints
	(command-s ".chProp" (ssget) "" "_layer" "defpoints" ""))

(defun c:ggg ( / ) ; solid teal layer, glass
	(command-s ".chProp" (ssget) "" "_layer" "glass" ""))

(defun c:colorGlass ( / )
	(command-s ".chProp" (ssget) "" "C" 111 ""))

(defun c:www ( / ) ; phantom layer wainscot 1mm thick
	(command-s ".chProp" (ssget) "" "_layer" "wainscot" ""))

(defun c:bbb ( / ) ; 2D base layer
	(command-s ".chProp" (ssget) "" "_layer" "2d_base" ""))

(defun c:uuu ( / ) ; 2D upper layer
	(command-s ".chProp" (ssget) "" "_layer" "2d_upper" ""))

(defun c:hrd ( / sel ) ; dashed hardware layer
	(setq sel (UserSelect))
	(command-s ".chProp" sel "" "_layer" "hidden" "")
	(command-s ".chProp" sel "" "C" 2 ""))

(defun c:colorRed ( / ) ; change color to red
	(command-s ".chProp" (ssget) "" "C" 1 ""))

(defun c:colorBlue ( / ) ; change color to true blue
	(command-s ".chProp" (ssget) "" "C" 5 ""))

(defun c:colorMagenta ( / ) ; change color to magenta
	(command-s ".chProp" (ssget) "" "color" 6 ""))

(defun c:colorBlack ( / ) ; change color to black
	(command-s ".chProp" (ssget) "" "color" "trueColor" "0,0,0" ""))

(defun c:coloreset ( / ) ; reset color to by layer
	(command-s ".chProp" (ssget) "" "color" "byLayer" ""))

(defun c:colorvanish ( / ) ; change target to defpoints & make match background color
	(command-s ".chProp" (ssget) "" "C" "trueColor" "0,0,0" "layer" "defpoints"))

(defun c:colorHatch ( / ) ; change color to standard hatching color
	(command-s ".chProp" (ssget) "" "C" 11 ""))

(if runDebug (princ "Layers complete\n"))

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Hatching ------------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(defun defaultHatch ( / ) ; reset hatching to defaults  standards expect to use.
	(command-s ".layer" "set" "hatch" "")
	(setvar 'hpname "line")
	(command-s "-hatch" "transparency" 0 "")
	(command-s "-hatch" "advanced" "island" "yes" "" "")
	(setvar 'hpassoc 1)
	(command-s "-hatch" "color" "." "." ""))

(defun vrHatching (insertPoint / hatchScale)
	(defaultHatch)
	(setq hatchScale (* 0.5 (getvar 'dimScale)))
	(command-s "-hatch" "properties" "line" hatchScale 135 "layer" "hatch" insertPoint ""))
	
(defun c:ct0 ( / ) ; hatch walls
	(defaultHatch) 
	(while t
		(command "-hatch" "properties" "line" 12 45 "layer" "wall" pause "")))

(defun c:ct9 ( / *error*) ; hatching for vr boxes
	(defun *error* (msg)
		(c:snapReset)
		(princ))
	(command-s ".osMode" 0)
	(vrHatching (getpoint "Hatch point"))
	(c:snapReset))

(defun c:ctz ( / ) ; hatch VR boxes
	(while t (vrHatching (getpoint "Insert point"))))

(defun c:plyHorz ( / ) ; hatch plywood horizontal
	(defaultHatch)
	(while t (command "-hatch" "properties" "cork" 2 0 "layer" "cases" pause "")))

(defun c:plyVert ( / ) ; hatch plywood vertical
	(defaultHatch)
	(while t (command "-hatch" "properties" "cork" 2 90 "layer" "cases" pause "")))

(defun c:tb0 ( / ) ; hatch tackboard
	(defaultHatch)
	(while t (command "-hatch" "properties" "ar-sand" 2.5 0 "layer" "splash" pause "")))

(defun c:wdz ( / ) ; wood grain hatch
	(defaultHatch)
	(setq hatchScale (* 0.5 (getvar 'dimScale)))
	(while t (command "-hatch" "properties" "htwood24" hatchScale 0 "layer" "splash" pause "")))

(defun c:stnHatch ( / ) ; hatch solid surface stone
	(defaultHatch)
	(while t (command "-hatch" "properties" "ar-conc" 0.125 0 "layer" "tops" pause "")))

(defun c:hl0 ( / ) ; yellow highlight hatching
	(command-s ".layer" "set" "hatch" "")
	(command-s "-hatch" "properties" "solid" "")
	(command-s "-hatch" "transparency" 90 "")
	(command-s "-hatch" "draw" "back" "")
	(command-s "-hatch" "advanced" "style" "ignore" "" "")
	(command-s "-hatch" "advanced" "associativity" "yes" "" "")
	(command-s "-hatch" "color" 51 "")
	(command "-hatch" pause "")
	(command-s ".drawOrder" "last" "" "back")
	(defaultHatch))

(if runDebug (princ "Hatches complete\n"))

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Cameara & Views -----------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(defun cameraMove ( pos / )
    (command-s ".ucs" "w")
    (command-s ".view" pos))

(defun c:zoomout ( / ) ; zoom out to full view
	(command-s ".zoom" "a"))

(defun c:wse ( / *error* ) ; create new ucs & adjusts view rotation
	(defun *error* (msg)
		(c:rse)(princ msg)(terpri)(exit))
	(command ".ucs" pause pause pause)
	(command-s ".plan" "current"))

(defun c:rse ( / ) ; reset ucs to world & straightens view rotation
	(command-s ".ucs" "world")
	(command-s ".plan" "world"))

(defun c:cameraTop ( / ) ; reset view to top down view
	(cameraMove "_top"))

(defun c:cameraNorth ( / ) 
	(cameraMove "back"))

(defun c:cameraEast ( / ) 
	(cameraMove "right"))

(defun c:cameraSouth ( / ) 
	(cameraMove "front"))

(defun c:cameraWest ( / ) 
	(cameraMove "left"))

(defun c:cameraIsoNW ( / ) 
	(cameraMove "nw"))

(defun c:cameraIsoNE ( / ) 
	(cameraMove "ne"))

(defun c:cameraIsoSW ( / ) 
	(cameraMove "sw"))

(defun c:cameraIsoSE ( / ) 
	(cameraMove "se"))

(defun c:z96 ( / ) ; .125"
	(command-s ".zoom" "s" "1/96xp"))

(defun c:z72 ( / )
	(command-s ".zoom" "s" "1/72xp"))

(defun c:z64 ( / ) ; .1875"
	(command-s ".zoom" "s" "1/64xp"))

(defun c:z48 ( / ) ; .25"
	(command-s ".zoom" "s" "1/48xp"))

(defun c:z32 ( / ) ; .375"
	(command-s ".zoom" "s" "1/32xp"))

(defun c:z24 ( / ) ; .5"
	(command-s ".zoom" "s" "1/24xp"))

(defun c:z16 ( / ) ; .75"
	(command-s ".zoom" "s" "1/16xp"))

(defun c:z12 ( / ) ; 1"
	(command-s ".zoom" "s" "1/12xp"))

(defun c:z8 ( / ) ; 1.5"
	(command-s ".zoom" "s" "1/8xp"))

(defun c:z6 ( / ) ; 2
	(command-s ".zoom" "s" "1/6xp"))

(defun c:z4 ( / ) ; 3
	(command-s ".zoom" "s" "1/4xp"))

(defun c:z2 ( / ) ; 6
	(command-s ".zoom" "s" "1/2xp"))

(defun c:z1 ( / ) ; 12
	(command-s ".zoom" "1xp"))

(if runDebug (princ "Dims & views complete\n"))

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Colorbugs -----------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(defun insertColorBug (filepath / insertPoint cl ds) ; function insert color bug
	(setq insertPoint (getpoint) cl (getvar 'cLayer) ds (getvar 'dimScale))
	(command-s ".layer" "set" "dim" "")
	(command-s ".insert" filepath "explode" "yes" insertPoint ds ds "")
	(command-s ".layer" "set" cl ""))

(defun strToColorBug (str / mat fin)
	(setq str (strcase str T)) ; convert to lowercase
	(setq mat (cond
		((wcmatch str "pl#") "pl")
		((wcmatch str "ss#") "ss")
		((wcmatch str "sm#") "sm")
		((wcmatch str "qt#") "qtz")
		((wcmatch str "wv#") "wv")
		((wcmatch str "wd#") "wd")))
	(setq fin (substr str 3)) ; trim finish # from str
	(setq filepath (strcat "colorbug_" mat fin ".dwg")))

(defun c:pl0 ( / ) ; plam blank
	(insertColorBug "colorbug_pl0"))

(defun c:pl1 ( / ) ; plam 1
	(insertColorBug "colorbug_pl1"))

(defun c:pl2 ( / )
	(insertColorBug "colorbug_pl2"))

(defun c:pl2a ( / )
	(insertColorBug "colorbug_pl2a"))

(defun c:pl2b ( / )
	(insertColorBug "colorbug_pl2b"))

(defun c:pl3 ( / )
	(insertColorBug "colorbug_pl3"))

(defun c:pl3a ( / )
	(insertColorBug "colorbug_pl3a"))

(defun c:pl3b ( / )
	(insertColorBug "colorbug_pl3b"))

(defun c:pl4 ( / )
	(insertColorBug "colorbug_pl4"))

(defun c:pl5 ( / )
	(insertColorBug "colorbug_pl5"))

(defun c:pl6 ( / )
	(insertColorBug "colorbug_pl6"))

(defun c:pl7 ( / )
	(insertColorBug "colorbug_pl7"))

(defun c:pl8 ( / )
	(insertColorBug "colorbug_pl8"))

(defun c:pl9 ( / )
	(insertColorBug "colorbug_pl9"))

(defun c:pl10 ( / )
	(insertColorBug "colorbug_pl10"))

(defun c:pl11 ( / )
	(insertColorBug "colorbug_pl11"))

(defun c:pl19 ( / )
	(insertColorBug "colorbug_pl19"))

(defun c:pl20 ( / )
	(insertColorBug "colorbug_pl20"))

(defun c:pl21 ( / )
	(insertColorBug "colorbug_pl21"))

(defun c:pl30 ( / )
	(insertColorBug "colorbug_pl30"))

(defun c:ss0 ( / )
	(insertColorBug "colorbug_ss0"))

(defun c:ss1 ( / )
	(insertColorBug "colorbug_ss1"))

(defun c:ss2 ( / ) 
	(insertColorBug "colorbug_ss2"))

(defun c:ss3 ( / )
	(insertColorBug "colorbug_ss3"))

(defun c:ss4 ( / )
	(insertColorBug "colorbug_ss4"))

(defun c:ss5 ( / )
	(insertColorBug "colorbug_ss5"))

(defun c:ss6 ( / )
	(insertColorBug "colorbug_ss6"))

(defun c:sm1 ( / ) ; SSM-1
	(insertColorBug "colorbug_sm1"))

(defun c:sm2 ( / ) ; SSM-2
	(insertColorBug "colorbug_sm2"))

(defun c:qt1 ( / )
	(insertColorBug "colorbug_qtz1"))

(defun c:qt2 ( / )
	(insertColorBug "colorbug_qtz2"))

(defun c:wv1 ( / ) ; wood veneer
	(insertColorBug "colorbug_wv1"))

(defun c:wd1 ( / ) ; solid wood
	(insertColorBug "colorbug_wd1"))

(if runDebug (princ "Color bugs complete\n"))

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Leaders -------------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(setq typBaseDepth 24 
    typTallDepth 25.25 
    typUpperDepth 14 
    typCTDepth 25.25 
    typSplashHeight 4 
    typValanceHeight 3 
    typFlushSoffit "" 
    leaderUp 0.3732 
    leaderDown -0.345 
    leaderCenter 0)

(defun productLeader (cabValue leaderText xVal yVal useGrain inlineWithColorBug / ; useGrain = t or nil, inlineWithColorBug = t or nil (nil will mirror grain & colorbug across leader)
					p1 p2 cl ds scaleOffset textLen pointDiff textSide xOffset yOffset leaderDim leaderOutput isVert inlineValue gPoint)
	(setq p1 (getpoint "Point, arrow"))
	(setq p2 (getpoint "Point, text"))
	(setq cl (getvar 'cLayer))
	(setq ds (getvar 'dimScale))
	(setq scaleOffset (getScaleOffset))

	(setq leaderDim (if (= cabValue 0) "" (formatDimsForLeader cabValue)))
	(setq textLen (strlen leaderDim))

	(setq pointDiff (- (car p2) (car p1)))
	(setq textSide (/ pointDiff (abs pointDiff)))
	(setq xOffset (* textSide (+ (* textLen 0.446) (* scaleOffset xVal))))
	(setq yOffset (* scaleOffset yVal))
	(setq leaderOutput (strcat leaderDim leaderText))
	(command-s ".layer" "set" "dim" "")
	(command-s ".qleader" p1 p2 "" leaderOutput "")
	(command-s ".insert" (strToColorBug (getstring "Enter a color bug command")) "explode" "yes" p2 ds ds "")
	(command-s ".move" "last" "" '(0 0) (list xOffset yOffset))
	(if useGrain 
		(progn
			(setq isVert (userVerify "Press Enter for vertical, anything else for horizontal."))
			(setq inlineValue (if inlineWithColorBug 1 -1))
			(setq gPoint (if isVert p2 (list (car p2) (+ (cadr p2) (* yOffset inlineValue)))))
			(princ gPoint)
			(command-s ".insert" "grain_bug" gPoint ds ds (if isVert 0 90))
			(command ".move" "last" "" gPoint pause)))
	(command-s ".layer" "set" cl "")(terpri))

(defun c:setBaseDepth ( / userInput)
	(setq userInput (getreal (strcat "Current base depth: " (formatDimsForLeader typBaseDepth) "\nInput new depth:")))
	(if userInput (setq typBaseDepth userInput))
	(c:bst))

(defun c:setTallDepth ( / userInput)
	(setq userInput (getreal (strcat "Current tall depth: " (formatDimsForLeader typTallDepth) "\nInput new depth:")))
	(if userInput (setq typTallDepth userInput))
	(c:tst))

(defun c:setUpperDepth ( / userInput)
	(setq userInput (getreal (strcat "Current upper depth: " (formatDimsForLeader typUpperDepth) "\nInput new depth:")))
	(if userInput (setq typUpperDepth userInput))
	(c:ut))

(defun c:setCtDepth ( / userInput)
	(setq userInput (getreal (strcat "Current countertop depth: " (formatDimsForLeader typCTDepth) "\nInput new depth:")))
	(if userInput (setq typCTDepth userInput))
	(c:cst))

(defun c:setSplashHeight ( / userInput)
	(setq userInput (getreal (strcat "Current splash height: " (formatDimsForLeader typSplashHeight) "\nInput new height:")))
	(if userInput (setq typSplashHeight userInput)))

(defun c:setValanceHeight ( / userInput)
	(setq userInput (getreal (strcat "Current valance height: " (formatDimsForLeader typValanceHeight) "\nInput new height:")))
	(if userInput (setq typValanceHeight userInput))
	(c:lv))

(defun c:bst ( / ) ; leader typical base cabinets
	(productLeader typBaseDepth " DEEP \nBASE CABINETS" 3.69246 leaderUp t nil))

(defun c:tst ( / ) ; leader typical tall cabinets
	(productLeader typTallDepth " DEEP \nTALL CABINETS" 4.2 leaderUp t nil))

(defun c:ut ( / ) ; leader typical upper cabinets
	(productLeader typUpperDepth " DEEP \nUPPER CABINETS" 3.69246 leaderUp t t))

(defun c:cst ( / ) ; leader typical countertop
	(productLeader typCTDepth " DEEP \nCOUNTERTOP" 4.2 leaderUp nil nil))

(defun c:4scs ( / ) ; leader smartclip splash
	(productLeader typSplashHeight " SMARTCLIP\nSPLASH" 3.69246 leaderDown nil nil))

(defun c:4is ( / ) ; leader integral splash
	(productLeader typSplashHeight " INTEGERAL\nSPLASH" 3.69246 leaderDown nil nil))

(defun c:4st ( / ) ; leader typical topset splash
	(productLeader typSplashHeight " TOPSET\nSPLASH" 3.6 leaderDown nil nil))

(defun c:rbt ( / ) ; leader rubber base
	(command-s ".layer" "set" "dim" "")
	(command ".qLeader" pause pause "" "BASE BY OTHERS, \nAS SCHEDULED" ""))

(defun c:pbt ( / ) ; leader plam base
	(productLeader 0 "PLAM\nTOE BASES" 3.26 leaderUp t t))

(defun c:pst ( / ) ; leader soffit
	(productLeader 0 "SOFFIT" 3.5 0 t t))

(defun c:flst ( / ) ; leader flush soffit
	(productLeader 0 "FLUSH\nSOFFIT" 3.2 leaderUp t nil))

(defun c:ast ( / ) ; adjustable shelf
	(command-s ".layer" "set" "dim" "")
	(command ".qLeader" pause pause "" "ADJ. SHELF" ""))

(defun c:astt ( / ) ; adjustable shelf stacked
	(command-s ".layer" "set" "dim" "")
	(command ".qLeader" pause pause "" "ADJ. SHELF" ""))

(defun c:lv ( / *error* p0 p1 lead0 lead1 valHeightStr layLst) ; light valance & leader
	(defun *error* (msg)
		(c:snapReset)
		(foreach item layLst (command-s ".-layer" "thaw" item ""))
		(princ msg)(terpri))
	(setq layLst (list "2D_CABINETDOOR" "2D_DASHDOT"))
	(foreach item layLst (command-s ".-layer" "freeze" item ""))
	(c:snapSquare)
	(setq p0 (getpoint "LV Start")
		  p1 (getpoint "LV End") 
		  lead0 (list (+ (car p0) (/ (- (car p1) (car p0)) 2)) (+ (cadr p0) typValanceHeight)) 
		  lead1 (list (car lead0) (- (cadr lead0) typValanceHeight (getScaleOffset)))
		  valHeightStr (formatDimsForLeader typValanceHeight))
	(c:snapReset)
	(foreach item layLst (command-s ".-layer" "thaw" item ""))
	(command-s ".layer" "set" "hidden" "")
	(command-s ".line" p0 p1 "")
	(command-s ".move" "last" "" "0,0" (strcat "0," valHeightStr))
	(command-s ".layer" "set" "dim" "")
	(command-s ".qLeader" lead0 lead1 "" (strcat valHeightStr " LIGHT \nVALANCE" ) ""))

(defun c:lkt ( / ) ; leader lock
	(command-s ".layer" "set" "dim" "")
	(command ".qLeader" pause pause "" "LOCK, TYP." ""))

(defun c:fb ( / ) ; leader finished bottom
	(command-s ".layer" "set" "dim" "")
	(command ".qLeader" pause pause "" "FB" "")
	(command-s ".mTEdit" "last"))

(defun c:owb ( / )
	(command-s ".layer" "set" "dim" "")
	(command ".qLeader" pause pause "" "ON WALL BRACKETS" ""))

(defun c:owbt ( / )
	(command-s ".layer" "set" "dim" "")
	(command ".qLeader" pause pause "" "ON WALL BRACKETS, TYP" ""))

(defun c:iwb ( / )
	(command-s ".layer" "set" "dim" "")
	(command ".qLeader" pause pause "" "IN WALL BRACKETS" ""))

(defun c:iwbt ( / )
	(command-s ".layer" "set" "dim" "")
	(command ".qLeader" pause pause "" "IN WALL BRACKETS, TYP" ""))

(defun c:qt ( / ) ; hidden text, leader only visible 
	(command ".layer" "set" "dim" "")
	(command ".qLeader" pause pause "" "invisible" "")
	(command ".chProp" "last" "" "C" "T" "0,0,0" "")
	(command ".chProp" "last" "" "layer" "defpoints" "")
	(command ".drawOrder" "last" "" "back"))

(defun c:iwt ( / ) ; leader in wall bracket
	(command-s ".layer" "set" "dim" "")
	(command ".qLeader" pause pause "" "IN-WALL" "SUPPORT" ""))

(if runDebug (princ "Leaders complete\n"))

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Snapping ------------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(defun c:gridSnap ( / ) ; toggle grid snapping
	(setvar 'snapMode (abs (- (getvar 'snapMode) 1))))

(defun c:snapNone ( / ) ; no snap points
	(setvar 'osMode 0))

(defun c:snapReset ( / ) ; snap reset my preferences
	(setvar 'osMode 14847))

(defun c:snapSquare ( / ) ; snap to endpoints
	(setvar 'osMode 1))

(defun c:snapMid ( / ) ; snap only to midpoints
	(setvar 'osMode 2))

(defun c:snapCircle ( / ) ; snap only to center of circle
	(setvar 'osMode 4))

(defun c:snapNode ( / )
	(setvar 'osMode 8))

(defun c:snapQuadrant ( / )
	(setvar 'osMode 16))

(defun c:snapIntersection ( / )
	(setvar 'osMode 32))

(defun c:snapInsertion ( / )
	(setvar 'osMode 64))

(defun c:snapPerpendicular ( / )
	(setvar 'osMode 128))

(defun c:snapTangent ( / )
	(setvar 'osMode 256))

(defun c:snapNearest ( / )
	(setvar 'osMode 512))

(defun c:snapGeoCenter ( / )
	(setvar 'osMode 1024))

(defun c:snapApparentInterestion ( / )
	(setvar 'osMode 2048))

(defun c:snapExtension ( / )
	(setvar 'osMode 4096))

(defun c:snapParallel ( / )
	(setvar 'osMode 8192))

(if runDebug (princ "Snapping complete\n"))

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Blocks --------------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(defun c:wb ( / *error* fileDiaStatus parentDirName referenceFile isPaste cmdMsg lastUsed fileName fileExists updateLastUsed userInput userVerifiesOverwrite userSelection)
			; A copy & paste function which provides the user with an easy way of using AutoCAD drawings saved to their own machine
	(defun *error* (msg)
		(setvar 'fileDia fileDiaStatus)(princ msg)(princ)(exit))
	(setq fileDiaStatus (getvar 'fileDia) 
		  parentDirName (strcat (getenv "appData") "\\acadClipboard") 
		  referenceFile (strcat parentDirName "\\lastUsedDrawing"))
	(if (not (findFile parentDirName))
		(LM:createDirectory parentDirName))
	(while (not (or (= isPaste "C") (= isPaste "V") (= isPaste "D")))
		(setq isPaste (strcase (getString "(C) Copy\n(V) Paste\n(D) Directory "))))
	(cond
		((= isPaste "D") (progn	(LM:open parentDirName)	(exit)))
		((= isPaste "V") (setq isPaste t))
		((= isPaste "C") (setq isPaste nil)))
	(if isPaste
		(progn
			(setq cmdMsg "Enter file name to paste\nLeave blank to repeat last used")
			(while (not fileExists)
				(setq fileExists (findfile (setq fileName (strcat parentDirName "\\" (setq userInput (getString cmdMsg)) ".dwg"))))
				(if (= userInput "")
					(progn
						(setq fileExists (findfile (setq fileName (strcat parentDirName "\\" (read-line (setq lastUsed (open referenceFile "r"))) ".dwg"))))))
				(setq cmdMsg "Error: file does not exist\nEnter file name to paste\nLeave blank to repeat last used"))
			(command ".insert" fileName "explode" "yes" pause "" "" "")
			(setq updateLastUsed (if (= userInput "") nil t)))
		(progn
			(while (not (or userInput (= "" userInput)))
				(setq fileExists (findfile (setq fileName (strcat parentDirName "\\" (setq userInput (getString "File name to save as ")) ".dwg")))))
			(while fileExists
				(while (not (or (= userVerifiesOverwrite "Y") (= userVerifiesOverwrite "N")))
					(setq userVerifiesOverwrite (strcase (getString (strcat "Name already exists, overwrite? (y/n)\n" fileName)))))
				(if (= userVerifiesOverwrite "Y")
					(setq userVerifiesOverwrite t fileExists nil) ; exit while loop
					(setq fileExists (findfile (setq fileName (strcat parentDirName "\\" (getString "File name to save as ") ".dwg"))))))
			(setq userSelection (ssget))
			(sssetfirst nil nil) ; ensure no current selection to sanitize command behaviour
			(setvar 'fileDia 0)
			(if userVerifiesOverwrite
				(command ".wblock" fileName "yes" "" "mode" "retain" pause userSelection "")
				(command ".wblock" fileName       "" "mode" "retain" pause userSelection ""))
			(setvar 'fileDia fileDiaStatus)
			(setq updateLastUsed t)))
	(if updateLastUsed
		(progn
			(setq lastUsed (open referenceFile "w"))
			(write-line userInput lastUsed)
			(close lastUsed))))

(defun c:ptdisp ( / ) ; dynamic paper towel dispenser elev view
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "ptDisp" "explode" "yes" pause "" "" ""))

(defun c:cove ( / ) ; elevation view coved splash block
	(command-s ".layer" "set" "tops" "")
	(command ".insert" "covedSplash" "explode" "yes" pause "" "" ""))

(defun c:ezkick ( / )
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "ezkickSide" "explode" "yes" pause "" "" ""))

(defun c:screwhead ( / ) ; 1/2" Ø Screw head block
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "screwhead" "explode" "yes" pause "" "" ""))

(defun c:kitlockelev ( / ) ; kitlock digital lock elevation view
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "kitlock1000elevView" "explode" "yes" pause "" "" ""))

(defun c:standardsection ( / ) ; dynamic block kv82 standard
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "stndbrkt_kv82standardSection" "explode" "yes" pause "" "" ""))

(defun c:bracketsection ( / ) ; dynamic block kv182 bracket
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "stndbrkt_kv182bracketSection" "explode" "yes" pause "" "" ""))

(defun c:adatemplate ( / ) ; ada cross section template
	(command ".insert" "adaTemplate" "explode" "yes" pause "" "" ""))

(defun c:caster ( / ) ; caster scalable section elev view
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "caster" "explode" "yes" pause "" "" ""))

(defun c:toiletsection ( / ) ; block toilet section view dynamic
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "toiletSectionView" "explode" "yes" pause "" "" ""))

(defun c:printer ( / ds) ; block printer elevation view dynamic
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "printerCopyDynamic" "explode" "yes" pause 1 1 "") 
	(command ".insert" "printerCopyDynamicCallout" "explode" "yes" pause ds ds ""))

(defun c:washer ( / ds) ; block washer elevation view dynamic
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "washer" "explode" "yes" pause "" "" "")
	(command ".insert" "washerCallout" "explode" "yes" pause ds ds ""))

(defun c:dryer ( / ) ; block washer elevation view dynamic
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "dryer" "explode" "yes" pause "" "" "")
	(command ".insert" "dryerCallout" "explode" "yes" pause ds ds ""))

(defun c:arrows ( / ds) ; arrow block straight
	(setq ds (getvar 'dimScale))
	(command ".insert" "arrowStraight" "explode" "yes" pause ds ds pause))

(defun c:arrowc ( / ds) ; arrow block curved
	(setq ds (getvar 'dimScale))
	(command ".insert" "arrowCurved" "explode" "yes" pause ds ds pause)) 

(defun c:cart ( / ) ; rolling cart elev view
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "rollingCartElev" "explode" "yes" pause "" "" 0))

(defun c:pianoHinge ( / ) ; Section View
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "pianoHingeBlock" "explode" "yes" pause "" "" ""))

(defun c:coatHook ( / )
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "coatHooksDynamic" "explode" "yes" pause "" "" ""))

(defun c:refrUnderCounterElev ( / ds origin refrWidth refrHeight) ; elev view undercounter refrigerator 
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "ucrefrigeratordynamic" "explode" "yes" (setq origin (getpoint "Bottom left corner")) "" "" 0)
	(setPropertyValue (entlast) "AcDbDynBlockPropertyDistance1" (setq refrWidth (getreal "U/C refr width")))
	(setPropertyValue (entlast) "AcDbDynBlockPropertyDistance2" (setq refrHeight (getreal "U/C refr height")))
	(command ".insert" "ucrefrcallout" "explode" "yes" pause ds ds 0))

(defun c:coin ( / i logo usrInp) ; Arch Hardware trash medallion
	(command-s ".undo" "begin")
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "medallionArchHardwareDynamic" "explode" "yes" pause "" "" "")
	(setq msg "\nSelect logo to display:\n(T)rash\n(R)ecycling\n(C)ompost\n(B)lank")
	(setq i nil)
	(while (not (or (= usrInp "t") (= usrInp "r") (= usrInp "c") (= usrInp "b")))
		(setq usrInp (strcase (getString msg) t))
		(if (not i)
			(progn
				(setq msg (strcat "\nInput one of the letters in paranthesis\n" msg))
				(setq i t))))
	(cond
		((= usrInp "t") (setq logo "Trash TR"))
		((= usrInp "r") (setq logo "Recycle RL"))
		((= usrInp "c") (setq logo "Compost BCL"))
		((= usrInp "b") (setq logo "Blank")))
	(setPropertyValue (entlast) "AcDbDynBlockPropertyLogoToDisplay" logo)
	(command-s ".undo" "end"))

(defun c:trashDeflectorPlanArch ( / )
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "trashDeflector_ArchR45_plan" "explode" "yes" pause "" "" pause))

(defun c:trashDeflectorElevArch ( / )
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "trashDeflector_ArchR45_elev" "explode" "yes" pause "" "" ""))

(defun c:trashDeflectorSectionArch ( / )
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "trashDeflector_ArchR45_section" "explode" "yes" pause "" "" ""))

(defun c:lateralFilePlan () ; CompX Timberline FF-SK2 hardware, plan view
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "LateralFilePlan" "explode" "yes" pause "" "" ""))

(defun c:lateralFileSection () ; CompX Timberline FF-SK2 hardware, section view
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "LateralFileSection" "explode" "yes" pause "" "" ""))

(defun c:ctp ( / ) ; plines standard laminate countertop section view w/ 4" splash
	(command-s ".layer" "set" "tops" "")
	(command ".insert" "ct_plam_plam" "explode" "yes" pause "" "" ""))

(defun c:cts ( / ) ; plines standard ss countertop w/ 4" splash & 0.25" rad
	(command-s ".layer" "set" "tops" "")
	(command ".insert" "ct_ss_125_025" "explode" "yes" pause "" "" ""))

(defun c:ctq2 ( / ) ; plines standard 2cm qtz ct w/ 4" splash; 1.5" thick
	(command-s ".layer" "set" "tops" "")
	(command ".insert" "ct_qtz_2cm_15" "explode" "yes" pause "" "" ""))

(defun c:ctq3 ( / ) ; plines standard 2cm qtz ct w/ 4" splash; 1.5" thick
	(command-s ".layer" "set" "tops" "")
	(command ".insert" "ct_qtz_3cm_125" "explode" "yes" pause "" "" ""))

(defun c:refrElev ( / ds origin refrWidth refrHeight) ; elev view refrigerator 
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "fridgeelev" "explode" "yes" (setq origin (getpoint "Bottom left point")) "" "" "")
	(setPropertyValue (entlast) "AcDbDynBlockPropertyRefrWidth" (setq refrWidth (getreal "Refrigerator width")))
	(setPropertyValue (entlast) "AcDbDynBlockPropertyRefrHeight" (setq refrHeight (getreal "Refrigerator height")))
	(command ".insert" "fridgecallout" "explode" "yes" pause ds ds ""))

(defun c:refrPlan ( / ds origin refrWidth refrDepth) ; plan view refrigerator 
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "refrdynplanview" "explode" "yes" (setq origin (getpoint "Origin point")) "" "" pause)
	(setPropertyValue (entlast) "AcDbDynBlockPropertyRefrWidth" (setq refrWidth (getreal "Refrigerator width")))
	(setPropertyValue (entlast) "AcDbDynBlockPropertyRefrDepth" (setq refrDepth (getreal "Refrigerator depth")))
	(command ".insert" "fridgecallout" "explode" "yes" pause ds ds ""))

(defun c:dishwashElev ( / ds origin dwHeight dwWidth tPoint) ; elev view dishwasher 
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "dishwasherelevation" "explode" "yes" (setq origin (getpoint "Bottom left of dishwasher")) "" "" "")
	(setPropertyValue (entlast) "AcDbDynBlockPropertyDistance2" (setq dwHeight (getreal "Dishwasher width: "))) ; workssssssssssssss
	(setPropertyValue (entlast) "AcDbDynBlockPropertyDistance1" (setq dwWidth (getreal "Dishwasher height: "))) ; workssssssssssssss
	(setq tPoint 5) ; TODO: math out the geometeric center of block
	(command ".insert" "dishwashercallout" "explode" "yes" pause ds ds ""))

(defun c:microwaveElev ( / ) ; elev view microwave
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "microwaveelev" "explode" "yes" pause "" "" "")
	(command ".insert" "microwavecallout" "explode" "yes" pause ds ds ""))

(defun c:toiletplan ( / ) ; dynamic block toilet
	(command-s ".layer" "set" "wall" "")
	(command ".insert" "planToiletCLR" "explode" "yes" pause "" "" pause)
	(command-s ".layer" "set" "dim" "")
	(command ".qLeader" "near" pause pause "" "ADA CLR" ""))

(defun c:toiletelev ( / ) ; dynamic block toilet
	(command-s ".layer" "set" "wall" "")
	(command ".insert" "dyntoiletelev" "explode" "yes" pause "" "" 0))

(defun c:brkt ( / ) ; block elevation view brackets
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "brktElev" "explode" "yes" pause "" "" "")
	(command-s ".layer" "set" "dim" "")
	(command ".qLeader" "near" pause pause "" "IN-WALL" "BRACKET TYP" ""))

(defun c:brktinv ( / ) ; block elevation view invisible bracket
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "invBrktElev" "explode" "yes" pause "" "" ""))

(defun c:brktt ( / ) ; block plan view bracket
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "brktPlanview" "explode" "yes" pause "" "" pause)
	(command ".move" "last" "" pause pause))

(defun c:brkttinv ( / ) ; block plan view bracket
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "invBrktPlan" "explode" "yes" pause "" "" pause))

(defun c:brktl ( / ) ; block section view bracket
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "brktSectionLeft" "explode" "yes" pause "" "" 0))

(defun c:brktlinv ( / ) ; block section view bracket
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "invBrktSection" "explode" "yes" pause "" "" 0))

(defun c:cv1 ( / ds) ; block ceiling height callout aff
	(setq ds (getvar 'dimScale))
	(setvar "attdia" 1)
	(command-s ".layer" "set" "dim" "")
	(command ".insert" "elev_vif" pause ds ds 0)
	(setvar "attdia" 0))

(defun c:grain ( / ds) ; block grain bug
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "dim" "")
	(command ".insert" "grain_bug" pause ds ds pause))

(defun c:fe ( / ds) ; text insert finished end fe
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "dim" "")
	(command ".insert" "fe" "explode" "yes" pause ds ds 0))

(defun c:plu ( / ) ; block plumbing
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "dynamicPLU" "explode" "yes" pause "" "" pause)
	(command ".move" "last" "" pause pause)
	(setPropertyValue (entlast) "AcDbDynBlockPropertyDistance1" (getreal "Pipes Width")))

(defun c:wmi ( / ds) ; block text white melamine
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "dim" "")
	(command ".insert" "wmi" "explode" "yes" pause ds ds 0))

(defun c:bmi ( / ds) ; block text black melamine
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "dim" "")
	(command ".insert" "bmi" "explode" "yes" pause ds ds 0))

(defun c:2rr ( / ) ; block radius right countertop
	(command ".insert" "2inRad" "explode" "yes" "end" pause 1 "" "" pause))

(defun c:1rr ( / ) ; block radius right 
	(command ".insert" "1inRad" "explode" "yes" "end" pause 1 "" "" pause))

(defun c:acs ( / ds) ; block textbox available clear space
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "dim" "")
	(command ".insert" "acs" "explode" "yes" pause ds ds 0))

(defun c:drain ( / ) ; block drain pipe section view
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "sink_drain" "explode" "yes" pause "" "" 0))

(defun c:trash ( / ) ; block trash can elevation section
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "trashDynamic" "explode" "yes" pause "" "" 0))

(defun c:pps ( / ds) ; Please provide sink model bug
	(setq ds (getvar 'dimScale))
	(command ".insert" "pps" "explode" "yes" pause ds ds 0))

(defun c:e1 ( / ds) ; Elevation / Plan / Section bug label
	(setq ds (getvar 'dimScale))
	(setvar "attdia" 1)
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "elev1" pause ds ds 0)
	(setvar "attdia" 0))

(defun c:vr ( / ds) ; callout box
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "dim" "")
	(command ".insert" "vrboxcentered" "explode" "yes" pause ds ds 0))

(defun c:eqp ( / p1 ds hatchInsertPoint) ; callout equipment
	(setq p1 (getpoint "Insert point") ds (getvar 'dimScale) hatchInsertPoint (list
		(+ (car  p1) (* ds 0.7848))
		(- (cadr p1) (* ds 0.0938))
		0))
	(command-s ".layer" "set" "dim" "")
	(command-s ".insert" "eqp_list" "explode" "yes" p1 ds ds 0))

(defun c:ppl ( / ) ; callout please provide plastic laminate plam
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "dim" "")
	(command ".insert" "plamnote" "explode" "yes" pause ds ds 0))

(defun c:opn ( / ) ; bug for open openings
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "dim" "")
	(command ".insert" "opn_bug" pause ds ds 0))

(defun c:glass ( / ds ) ; Add glass-glare decroative bug
	(setq ds (* 0.75 (getvar 'dimScale)))
	(command ".insert" "glass bug" "explode" "yes" pause ds ds ""))

(defun c:earr ( / ds org ) ; block elevation arrow 
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "dim" "")
	(command-s ".insert" "elev_arrow" "explode" "yes" (setq org (getpoint)) ds ds 0)
	(command ".move" "last" "" org pause))

(defun c:numboxd ( / *error* ) ; block product number box
	; (defun *error* (msg / ) (c:snapReset) (princ msg) (terpri))
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "dim" "")
	(command ".insert" "product_numbox" "explode" "yes" pause ds ds 0))

(defun c:numBoxDetailHorz ( / p1 offsetMult bugName box_xOffset box_yOffset bug_xOffset cl ) ; block product number box & color bug for details
	(setq p1 (getpoint) offsetMult (getvar 'dimScale) cl (getvar 'cLayer))
	(setq bugName (strToColorBug (getstring "Enter a color bug command")))
	(setq box_xOffset (* 0.1875 offsetMult) box_yOffset (* -0.0833 offsetMult) bug_xOffset (* -0.2661 offsetMult))
	(command-s ".layer" "set" "dim" "")
	(command-s ".insert" "product_numbox" p1 offsetMult offsetMult 0)
	(command-s ".move" "last" "" '(0 0) (list box_xOffset box_yOffset)) 
	(command-s ".explode" "last" "")
	(command-s ".insert" bugName "explode" "yes" p1 offsetMult offsetMult 0)
	(command-s ".move" "last" "" '(0 0) (list bug_xOffset 0))
	(command-s ".layer" "set" cl "")
	(terpri))

(defun c:rguide ( / ) ; block routing guide for 2d part editting
	(command ".insert" "route_in_out_guide" "explode" "yes" pause "" "" 0))

(defun c:cguide ( / ) ; block spacing guide for 2d composite drawings
	(command ".insert" "compositeGuide" "explode" "yes" pause "" "" 0))

(defun c:hinge ( / *error*) ; block section view hinges
	(defun *error* (msg)
		(c:snapReset)
		(princ msg)(princ))
	(command-s ".layer" "set" "deets" "")
	(c:snapcircle)
	(command ".insert" "hinge_section" "explode" "yes" pause "" "" 0)
	(c:snapReset))

(defun c:rodCupElev ( / )
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "hardware_rodCup_elev" "explode" "yes" pause "" "" 0))

(defun c:rodCupSection ( / *error*)
	(defun *error* (msg)
		(c:snapReset)
		(princ msg)(princ))
	(command-s ".layer" "set" "deets" "")
	(c:snapcircle)
	(command ".insert" "hardware_rodCup_section" "explode" "yes" pause "" "" 0)
	(c:snapReset))

(defun c:keku ( / *error*) ; block keku clip
	(defun *error* (msg)
		(c:snapReset)
		(princ msg)
		(princ))
	(command-s ".layer" "set" "deets" "")
	(c:snapcircle)
	(command ".insert" "kekuclip" "explode" "yes" pause "" "" 0)
	(c:snapReset))

(defun c:5khng ( / *error*) ; block section view hinges
	(defun *error* (msg)
		(c:snapReset)
		(princ msg)
		(princ))
	(command-s ".layer" "set" "deets" "")
	(c:snapcircle)
	(command ".insert" "5kHinge" "explode" "yes" pause "" "" 0)
	(c:snapReset))

(defun c:grommetFlipTop ( / ) ; mockket 2.5" flip top grommet
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "grommetFlipTop" "explode" "yes" pause 1 1 ""))

(defun c:trashRingPlan ( / ) ; trash ring plan
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "trashRingPlan" "explode" "yes" pause 1 1 ""))

(defun c:trashRingElev ( / ) ; trash ring elev
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "trashRingElev" "explode" "yes" pause 1 1 ""))

(defun c:doorp ( / ) ; block door swing plan view
	(command-s ".layer" "set" "wall" "")
	(command ".insert" "door_plan" "explode" "yes" pause "" "" pause)
	(command-s ".layer" "set" "dim" "")
	(command ".qLeader" pause pause "" "ADA CLR" ""))

(defun c:doore ( / ) ; block door elevation view
	(command-s ".layer" "set" "wall" "")
	(command ".insert" "door_elev" "explode" "yes" pause "" "" 0))

(defun c:doorSlidingPlan ( / ) ; block sliding door plan view
	(command-s ".layer" "set" "wall" "")
	(command ".insert" "SlidingDoor" "explode" "yes" pause "" "" pause))

(defun c:doorPocketPlan ( / ) ; block pocket door plan view
	(command-s ".layer" "set" "wall" "")
	(command ".insert" "PocketDoor" "explode" "yes" pause "" "" pause))

(defun c:windowp ( / ) ; block plan view window
	(command-s ".layer" "set" "wall" "")
	(command ".insert" "window_plan" "explode" "yes" pause "" "" pause))

(defun c:break ( / ) ; block break at 5"
	(command-s ".layer" "set" "wall" "")
	(command ".insert" "breakline" "explode" "yes" pause "" "" pause))

(defun c:brkHorz ( / *error*) ; block break no legs horizontal
	(defun *error* (msg)
		(c:snapReset)
		(princ msg)(princ))
	(c:snapMid)
	(command-s ".layer" "set" "wall" "")
	(command ".insert" "breakline_horz_part" "explode" "yes" pause "" "" pause)
	(c:snapReset))

(defun c:brkvert ( / ) ; block break no legs vertical
	(command-s ".layer" "set" "wall" "")
	(command ".insert" "breakline_vert_part" "explode" "yes" pause "" "" pause))

(defun c:adan ( / ) ; block textbox 28 ada clear note
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "dim" "")
	(command ".insert" "28_ada_note" pause ds ds 0))

(defun c:plums ( / ) ; block textbox plam undermount sink note
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "dim" "")
	(command ".insert" "plam_um_note" "explode" "yes" pause ds ds 0))

(defun c:sinkPrepare ( / )
	(sinkBlockPrep t))

(defun c:cutoutPrepare ( / )
	(sinkBlockPrep nil))

(defun c:s1p ( / ) ; block generic sink plan drop in
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "s1p" pause "" "" pause))

(defun c:s1e ( / ) ; block generic sink elev drop in
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "s1e" pause "" "" 0))

(defun c:s2p ( / ) ; block generic sink plan drop in
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "dynamicSinkDropIn" "explode" "yes" pause 1 1 pause))

(defun c:s2e ( / ) ; block generic sink elev drop in
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "sinkDropInElev" "explode" "yes" pause "" "" 0)
	(setPropertyValue (entlast) "AcDbDynBlockPropertysinkRimWidth" (getreal "Sink Rim Width:")))

(defun c:s3p ( / ) ; block generic sink plan drop in
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "s3p" pause "" "" 0))

(defun c:s3e ( / ) ; block generic sink elev drop in
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "s3e" pause "" "" 0))

(defun c:s4p ( / ) ; block generic sink plan drop in
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "s4p" pause "" "" 0))

(defun c:s4e ( / ) ; block generic sink elev drop in
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "s4e" pause "" "" 0))

(defun c:alrt ( / ) ; block alignment bug
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "dim" "")
	(command ".insert" "alignbug" "explode" "yes" pause ds ds pause))

(defun c:lkb ( / ) ; lockgroup label elevation view
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "dim" "")
	(command ".insert" "lockgroup" pause ds ds ""))

(defun c:tjb ( / ) ; tightjoint bolts plan view
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "tightbolts" "explode" "yes" pause "" "" pause))

(defun c:pbp ( / ) ; pocketbore plan view, dynamic block
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "pocketbore planview" "explode" "yes" pause "" "" pause))

(defun c:pocketBoreSection ( / ) ; pocketbore section view, dynamic block
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "pocketbore_section" "explode" "yes" pause "" "" ""))

(defun c:ftp ( / ) ; gooseneck faucet plan view
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "faucet plan view" pause "" "" pause))

(defun c:fte ( / ) ; gooseneck faucet elevation view
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "faucet elev view" pause "" "" ""))

(defun c:fts ( / ) ; gooseneck faucet section view
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "faucetSection" pause "" "" ""))

(defun c:out2 ( / ) ; electrical outlet 2 port elevation view
	(command ".insert" "out2" pause "" "" 0))

(defun c:out4 ( / ) ; electrical outlet 4 port elevation view
	(command ".insert" "out4" pause "" "" 0))

(defun c:dat2 ( / ) ; data outlet 2 port elevation view
	(command ".insert" "data2" pause "" "" 0))

(defun c:dat4 ( / ) ; data outlet 4 port elevation view
	(command ".insert" "data4" pause "" "" 0))

(defun c:outleft ( / ) ; data outlet side view
	(command ".insert" "outleft" pause "" "" 0))

(defun c:outtop ( / ) ; data outlet plan view
	(command ".insert" "outtop" pause "" "" 0))

(defun c:pullSection ( / ) ; standard pull cross section
	(command ".insert" "pullSection" pause "" "" pause))

(defun c:pullProfile ( / ) ; standard wire pull cross section
	(command ".insert" "pullSectionProfile" "explode" "yes" pause "" "" 0))

(defun c:pullElevDoor ( / doorCorner cabType orientation) ; standard pull elevation view
	(command ".insert" "pullElevDoor" "explode" "yes" pause "" "" ""))

(defun c:335 ( / ) ; CT to 33.5" AFF for ADA drop in sink
	(setq ds (getvar 'dimScale))
	(command-s ".layer" "set" "dim" "")
	(command ".insert" "335sinknote" "explode" "yes" pause ds ds 0))

(defun c:clt ( / ) ; Centerline tag
	(command-s ".layer" "set" "dim" "")
	(setq ds (getvar 'dimScale))
	(command ".insert" "cltag" pause ds ds 0))

(defun c:sbd ( / ) ; Section Bug Dynamic
	(command-s ".layer" "set" "dim" "")
	(setq ds (getvar 'dimScale))
	(command ".insert" "sbd" "explode" "yes" pause ds ds 0))

(defun c:faae ( / ) ; block faucet elevation view
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "faucetElev" "explode" "yes" pause 1 1 0))

(defun c:faaf ( / ) ; block faucet plan view
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "faucetPlan" "explode" "yes" pause 1 1 pause))

(defun c:mag ( / ) ; block magcatch
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "magcatch" "explode" "yes" pause 1 1 0))

(defun c:biscuit ( / ) ; block for wooden biscuit
	(command-s ".layer" "set" "green" "")
	(command ".insert" "biscuit" "explode" "yes" pause 1 1 0))

(defun c:bennetClipElev ( / )
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "bennet_clip_planAndElev" "explode" "yes" pause 1 1 pause))

(defun c:bennetClipSec ( / )
	(command-s ".layer" "set" "deets" "")
	(command ".insert" "bennet_clip_section" "explode" "yes" pause 1 1 pause))

(if runDebug (princ "Blocks complete\n"))

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Dimensions ----------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(defun toggleDimArrows (foobar / currentDseName Input Input2) 
	(foreach foo foobar
		(setq currentDseName (car foobar))
		(setq Input (abs (- (getpropertyvalue CurrentDseName "dimse1") 1)))
		(setq Input2 (abs (- (getpropertyvalue CurrentDseName "dimse2") 1)))
			(setPropertyValue CurrentDseName "dimse1" input)
			(setPropertyValue CurrentDseName "dimse2" input2)))

(defun c:dse ( / multiSel formSel)
	(setq multiSel (ssget))
	(setq formSel (LM:ss->ent multiSel))
	(foreach item formSel
		(toggleDimArrows (list item)))
	(princ))

(defun c:dimElevation ( / *error* layList) ; suppresses problematic layers for 2D elev dimensioning
	(setq layList "2D_CABINETDOOR, 2D_DASHDOT, 2D_DASHED3 2D_OPENCABINETINTERIOR")
	(defun *error* (msg)
		(command-s ".-layer" "thaw" layList "")
		(c:snapReset)
		(princ msg)(terpri)(exit))
	(command-s ".-layer" "freeze" layList "")
	(c:snapSquare)
	(c:d)
	(while t
		(c:dc)))

(defun c:eng ( / selectedDims) ; Sets dims to decimal output plus metric
	(if (ssget "_I") (setq selectedDims (ssget "_I")))
	(setvar 'dimLUnit 2) ; sets decimal notation
	(setvar 'dimDec 4) ; precision level of dims
	(setvar 'dimTih 0) ; dim text alignment (aligned)
	(setvar 'dimAlt 0) ; enable dim alt text
	(if selectedDims (command-s ".dim" "update" selectedDims)))

(defun c:drft ( / selectedDims) ; Sets dims to fractional output
	(if (ssget "_I") (setq selectedDims (ssget "_I")))
	(setvar 'dimLUnit 5)
	(setvar 'dimDec 6)
	(setvar 'dimTih 1)
	(setvar 'dimAlt 0)
	(if selectedDims (command-s ".dim" "update" selectedDims)))

(defun c:d ( / ) ; dimension ortholinear
	(command-s ".layer" "set" "dim" "")
	(command ".dimLinear" pause pause pause)
	(command-s ".dimBreak" "last" ""))

(defun c:dc ( / ) ; dimension continue
	(command-s ".layer" "set" "dim" "")
	(while t;rue	
		(command ".dimContinue" pause "" "")
		(setPropertyValue (entlast) "dimtMove" 0)
		(command-s ".dimBreak" "last" "")))

(defun c:da ( / ) ; dimension aligned
	(command-s ".layer" "set" "dim" "")
	(command ".dimAligned" pause pause pause)
	(command-s ".dimBreak" "last" "")
	(command ".dimEdit" "oblique" "last" "" pause))

(defun c:daa ( / ) ; dimension oblique edit
	(command ".dimEdit" "oblique" (ssget) "" pause))

(defun c:dbb ( / ) ; dimension break
	(command ".dimBreak" (ssget) ""))

(defun c:drad ( / ) ; custom dimradius
	(command-s ".layer" "set" "dim" "")
	(command ".dimRadius" pause))
	
(defun c:darc ( / ) ; custom dimangular
	(command-s ".layer" "set" "dim" "")
	(command ".dimAngular" pause))

(defun c:ed1 ( / )
	(command-s ".dimEdit" "n" "<>"))

(defun c:edm ( / )
	(command-s ".dimEdit" "n" "<> MIN"))

(defun c:edmm ( / )
	(command-s ".dimEdit" "n" "<>\nMIN"))

(defun c:edg ( / )
	(command-s ".dimEdit" "n" "<> GAP"))

(defun c:edgg ( / )
	(command-s ".dimEdit" "n" "<>\nGAP"))

(defun c:ede ( / )
	(command-s ".dimEdit" "n" "<> EQ"))

(defun c:edee ( / )
	(command-s ".dimEdit" "n" "<>\nEQ"))

(defun c:edleg ( / )
	(command-s ".dimEdit" "n" "<> LEG"))

(defun c:edlegg ( / )
	(command-s ".dimEdit" "n" "<>\nLEG"))

(defun c:edk ( / )
	(command-s ".dimEdit" "n" "<> KICK"))

(defun c:eddeck ( / )
	(command-s ".dimEdit" "n" "<> DECK"))

(defun c:eddeckk ( / )
	(command-s ".dimEdit" "n" "<>\nDECK"))

(defun c:edsub ( / )
	(command-s ".dimEdit" "n" "<> SUBTOP"))

(defun c:edsubb ( / )
	(command-s ".dimEdit" "n" "<>\nSUB\nTOP"))

(defun c:edsil ( / )
	(command-s ".dimEdit" "n" "<> SILL"))

(defun c:edsill ( / )
	(command-s ".dimEdit" "n" "<>\nSILL"))

(defun c:edpanel ( / )
  (command-s ".dimEdit" "n" "<> PANEL"))

(defun c:edpanell ( / )
  (command-s ".dimEdit" "n" "<>\nPANEL"))

(defun c:edgap ( / )
	(command-s ".dimEdit" "n" "<> GAP"))

(defun c:edgapp ( / )
	(command-s ".dimEdit" "n" "<>\nGAP"))

(defun c:edsof ( / )
	(command-s ".dimEdit" "n" "<> SOFFIT"))

(defun c:edsoff ( / )
	(command-s ".dimEdit" "n" "<>\nSOFFIT"))

(defun c:edsv ( / ) 
	(command-s ".dimEdit" "n" "<> VIF SOFFIT"))

(defun c:edsvv ( / )
	(command-s ".dimEdit" "n" "<>\nVIF\nSOFFIT"))

(defun c:edov ( / )
	(command-s ".dimEdit" "n" "<> OVERALL"))

(defun c:edovv ( / )
	(command-s ".dimEdit" "n" "<>\nOVER\nALL"))

(defun c:edtyp ( / )
	(command-s ".dimEdit" "n" "<> TYP."))

(defun c:edtypp ( / )
	(command-s ".dimEdit" "n" "<>\nTYP."))

(defun c:edshelf ( / )
	(command-s ".dimEdit" "n" "<> SHELVES"))

(defun c:edshelff ( / )
	(command-s ".dimEdit" "n" "<>\nSHELVES"))

(defun c:edapron ( / )
	(command-s ".dimEdit" "n" "<> APRON"))

(defun c:edapronn ( / )
	(command-s ".dimEdit" "n" "<>\nAPRON"))

(defun c:edt ( / )
	(command-s ".dimEdit" "n" "<> TOP"))

(defun c:edtt ( / )
	(command-s ".dimEdit" "n" "<>\nTOP"))

(defun c:edv ( / )
	(command-s ".dimEdit" "n" "<> VIF"))

(defun c:edvv ( / )
	(command-s ".dimEdit" "n" "<>\nVIF"))

(defun c:edc ( / )
	(command-s ".dimEdit" "n" "<> CLR"))

(defun c:edcc ( / )
	(command-s ".dimEdit" "n" "<>\nCLR"))

(defun c:eds ( / )
	(command-s ".dimEdit" "n" "<> SCRIBE"))

(defun c:edss ( / )
	(command-s ".dimEdit" "n" "<>\nSCRIBE"))

(defun c:edws ( / )
	(command-s ".dimEdit" "n" "<>\nWINDOW\nSILL"))

(defun c:sty1-8( / )
	(command-s ".dimStyle" "r" "1-8")
	(setvar 'dimAdec 0))

(defun c:sty3-16( / )
	(command-s ".dimStyle" "r" "3-16")
	(setvar 'dimAdec 0))

(defun c:sty1-4( / )
	(command-s ".dimStyle" "r" "1-4")
	(setvar 'dimAdec 0))

(defun c:sty3-8( / )
	(command-s ".dimStyle" "r" "3-8")
	(setvar 'dimAdec 0))

(defun c:sty3-8dat( / )
	(command-s ".dimStyle" "r" "3-8 DATUM")
	(setvar 'dimAdec 0))

(defun c:sty1-2( / )
	(command-s ".dimStyle" "r" "1-2")
	(setvar 'dimAdec 0))

(defun c:sty3-4( / )
	(command-s ".dimStyle" "r" "3-4")
	(setvar 'dimAdec 0))

(defun c:sty1( / )
	(command-s ".dimStyle" "r" "1")
	(setvar 'dimAdec 0))

(defun c:sty1-1-2( / )
	(command-s ".dimStyle" "r" "1 1-2")
	(setvar 'dimAdec 0))

(defun c:sty2( / )
	(command-s ".dimStyle" "r" "2")
	(setvar 'dimAdec 0))

(defun c:sty3( / )
	(command-s ".dimStyle" "r" "3")
	(setvar 'dimAdec 0))

(defun c:sty6( / )
	(command-s ".dimStyle" "r" "6")
	(setvar 'dimAdec 0))

(defun c:sty12( / )
	(command-s ".dimStyle" "r" "12")
	(setvar 'dimAdec 0))

(if runDebug (princ "Color bugs complete\n"))

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Pages & Layouts -----------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(defun Get-Layout-List ( / acadObj acDoc acDocLayouts layoutCount loopCount layoutListLocal layoutListSorted layoutName layoutPosition loopCountSorted) ; Created by: Lee Ambrosius
	(setq acadObj (vlax-get-acad-object))
	(setq acDoc (vlax-get-property acadObj 'ActiveDocument))
	(setq acDocLayouts (vlax-get-property acDoc 'Layouts))
	(setq layoutCount (vlax-get-property acDocLayouts 'Count)
		loopCount 0
		layoutListLocal (list)
		layoutListSorted (list))
	(while (> layoutCount loopCount)
		(setq layoutName (vlax-get-property (vlax-invoke-method acDocLayouts 'Item loopCount) 'Name))
		(setq layoutPosition (vlax-get-property (vlax-invoke-method acDocLayouts 'Item loopCount) 'TabOrder))
	(setq layoutListLocal (append layoutListLocal (list (list layoutPosition layoutName))))
	(setq loopCount (1+ loopCount)))
	(setq layoutCountSorted 0) ; Resort listing by TabOrder
	(while (> (length layoutListLocal) (length layoutListSorted))
		(setq loopCountSorted 0)
		(foreach layoutLocation layoutListLocal
		(progn
			(if (and (= (car layoutLocation) (length layoutListSorted)) (= (car layoutLocation) layoutCountSorted))
				(progn
					(setq layoutListSorted (append layoutListSorted (cdr (nth loopCountSorted layoutListLocal))))
					(setq layoutCountSorted (1+ layoutCountSorted))))
       (setq loopCountSorted (1+ loopCountSorted)))))
	layoutListSorted)

(defun tabNotRenamable (tabName / )
	(if (member (getvar "cTab") '("Model" "Cswrk" "Custom Temp"))
		(prin1 t)
		(prin1 nil)))

(defun tabRenameComplete (tabName currentIteration / )
	(if (equal 'INT (type tabName)) ; Verify data type as STR
		(setq tabName (itoa tabName))
		(progn
			(princ "Error: Tab name must be an integer")
			(prin1 nil)
			(exit)))
	(if (member tabName (layoutList)) ; Check if name in layout layoutList
		(if (userVerify "A tab with this name already exists. Press enter to rename both.")
			(command-s ".layout" "rename" tabName (strcat "%_" tabName)) ; rename offending tab
			(progn
				(prin1 nil)
				(exit))) ; user negates changing tabs
		(if (/= currentIteration 0)
			(if (not (userVerify "Press enter to renumber current tab."))
				(exit))))
	(command-s ".layout" "rename" "" tabName)
	(prin1 t)) ; verify process was ran successfully

(defun c:renameAndAttach ( / tabName)
	(setq tabName (strcat (getstring "Elevation number:") "P"))
	(command-s ".layout" "rename" "" tabName)
	(command "xattach" ""))

(defun c:engTemplate ( / ) ; my engineering template
	(command-s ".layout" "_t" "template_engineering.dwt" "000" ""))

(defun c:draftTemplate ( / ) ; personal drafting template
	(command-s ".layout" "_t" "template_drafting.dwt" "x_x_x" ""))

(defun c:customTemplatePage ( / )
    (command-s ".pageSetup" "DWG to PDF.pc3"             ; printer name
               "ANSI full bleed A (8.50 x 11.00 Inches)" ; paper size
               "Inches"                                  ; paper units
               "Landscape"                               ; drawing orientation
               "No"                                      ; plot upside down
               "Extents"                                 ; plot area
               "1:1"                                     ; plot scale
               "Center"                                  ; plot offset
               "Yes"                                     ; apply plot styles
               "std 2024.ctb"                            ; plot style table name
               "Yes"                                     ; Plot w/ lineweights
               "No"                                      ; Scale lineweights
               "No"                                      ; Plot paperspace first
               "No"))                                    ; Hide paperspace objects

(defun c:ctd ( / ) ; delete current layout
	(command-s ".layout" "_d" ""))

(defun c:fse ( / ) ; return to model tab in drawing
	(setvar "ctab" "model"))

(defun c:pgIncrement ( / tabNum currentIteration )
	(setq tabNum (getint "Starting number:") currentIteration 0)
	(while t
		(if (tabNotRenamable tabNum)
			(progn
				(prin1 "Entering Model, Cswrk, & Custom Temp tabs cancel function.")
				(exit)))
		(if (tabRenameComplete tabNum currentIteration)
			(progn
				(setq tabNum (+ 1 tabNum) currentIteration (+ 1 currentIteration))
				(c:nextLayout))
			(progn
				(princ "An error occured while running the function.")
				(exit)))))

(defun c:nextLayout ( / layout-mem-list layout-list layoutLocation) ; Created by: Lee Ambrosius
	(setq layoutLocation 0)
	(setq layout-list (get-layout-list))
	(setq layout-mem-list (member (getvar 'CTAB) layout-list))
	(if layout-mem-list
		(progn
			(setq layoutLocation (- (length layout-list) (length layout-mem-list))))
			(setq layoutLocation (1+ layoutLocation)))
	(if (>= (1+ layoutLocation) (length layout-list))
		(setvar "CTAB" (nth 0 layout-list))
		(setvar "CTAB" (nth (1+ layoutLocation) layout-list))))

(defun c:previouslayout ( / layout-mem-list layout-list layoutLocation) ; Created by: Lee Ambrosius 
	(setq layoutLocation 0)
	(setq layout-list (get-layout-list))
	(setq layout-mem-list (member (getvar 'CTAB) layout-list))
	(if layout-mem-list
		(progn
			(setq layoutLocation (- (length layout-list) (length layout-mem-list))))
			(setq layoutLocation (1- layoutLocation)))
	(if (= layoutLocation 0)
		(setvar "CTAB" (nth (1- (length layout-list)) layout-list))
		(setvar "CTAB" (nth (1- layoutLocation) layout-list))))

(defun c:FirstLayout ( / layout-list layoutLocation) ; Created by: Lee Ambrosius 
	(setvar "CTAB" (nth 1 (get-layout-list))))

(defun c:LastLayout ( / layout-list) ; Created by: Lee Ambrosius 
	(setq layout-list (get-layout-list))
	(setvar "CTAB" (nth (- (length layout-list) 1) layout-list)))

(defun c:rcl ( / ) ; rename current layout
	(command ".layout" "rename" "" pause))

(defun c:cpt ( / layoutList element curTab tabList ) ; copy current layout tab and move right
	(setq tabList (get-layout-list) curTab (getvar 'ctab) layoutList (vl-position curTab tabList))
	(command-s ".layout" "copy" "" "")
	(vlax-for element (vla-get-Layouts (vla-get-activedocument (vlax-get-acad-object)))
	(if (= curTab (vla-get-name element))
		(vla-put-taborder element layoutList)))
	(terpri))

(defun c:cptt ( / ) ; rename & move to new tab
	(setq title (getstring "Enter new tab's name: "))
	(command-s ".layout" "copy" "" title)
	(command-s ".layout" "set" title))

(if runDebug (princ "Dims & views complete\n"))

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Fillets -------------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(defun c:f` ( / ) ; remove arc from lines
	(setvar 'filletrad 0)
	(command-s ".fillet" "multiple"))

(defun c:f`1 ( / ) ; fillet 0.0625" rad
	(setvar 'filletrad 0.0625)
	(command-s ".fillet" "multiple"))

(defun c:f125 ( / ) ; fillet 0.125" rad
	(setvar 'filletrad 0.125)
	(command-s ".fillet" "multiple"))

(defun c:f25 ( / ) ; fillet 0.25" rad
	(setvar 'filletrad 0.25)
	(command-s ".fillet" "multiple"))

(defun c:f5 ( / ) ; fillet 0.5" rad
	(setvar 'filletrad 0.5)
	(command-s ".fillet" "multiple"))

(defun c:f75 ( / ) ; fillet 0.75" rad
	(setvar 'filletrad 0.75)
	(command-s ".fillet" "multiple"))

(defun c:f1 ( / ) ; fillet 1" rad
	(setvar 'filletrad 1)
	(command-s ".fillet" "multiple"))

(defun c:f15 ( / ) ; fillet 1.5" rad
	(setvar 'filletrad 1.5)
	(command-s ".fillet" "multiple"))

(defun c:f2 ( / ) ; fillet 2" rad
	(setvar 'filletrad 2)
	(command-s ".fillet" "multiple"))

(if runDebug (princ "Fillets complete\n"))

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- AutoExecute Commands ------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(vl-load-com)

(command-s "model")
(command-s "vsCurrent" "2dWireframe")

(c:rat)
(c:fr23)

(if (= useCommandLine 1)
    (command-s ".commandLine")
    (command-s ".commandLineHide"))

(if runDebug (princ "\n\tAutorun complete"))
(princ "\n\tFile loaded without errors")(terpri)

; Note: opening the part editor in the following way results in quiet errors & should not be done.
; (if (= "Composite.DWG" (getvar 'dwgName)) (command "mvSinglePartEditor"))

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
