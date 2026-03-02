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
	(LM:open "L:\\Templates\\AutoCad\\BLOCK-lib"))

(defun c:gosink ( / path validInput index value msg userInput) ; open personal plumbing blocks in file explorer
	(setq path "L:/Templates/AutoCad/BLOCK-lib/PLUMBING/SINK/des_sink")
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

