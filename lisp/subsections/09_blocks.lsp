; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Blocks --------------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(defun c:wb ( / *error* fileDiaStatus parentDirName referenceFile isPaste cmdMsg lastUsed fileName fileExists updateLastUsed userInput userVerifiesOverwrite userSelection)
			; A copy & paste function which provides the user with an easy way of using AutoCAD drawings saved to their own machine
	(defun *error* (msg)
		(setvar 'fileDia fileDiaStatus)(princ msg)(princ)(exit))
	(setq fileDiaStatus (getvar 'fileDia) 
		  parentDirName (strcat (getenv "appData") "\\acadClipboardIWP") 
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

