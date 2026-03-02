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
               "IWP 2024.ctb"                            ; plot style table name
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

