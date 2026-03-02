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

