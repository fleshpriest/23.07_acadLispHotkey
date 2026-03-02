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

