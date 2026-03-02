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

