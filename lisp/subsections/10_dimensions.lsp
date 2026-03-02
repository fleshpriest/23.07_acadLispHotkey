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

