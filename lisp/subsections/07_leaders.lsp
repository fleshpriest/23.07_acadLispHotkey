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

