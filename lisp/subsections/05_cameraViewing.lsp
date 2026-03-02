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

