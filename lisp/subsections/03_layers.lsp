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

(layerCreation "lines"     230 "continuous" "default") ; 111 Lines Layer
(layerCreation "deets"       2 "continuous" "default") ; 222 Deets Layer
(layerCreation "green"       3 "continuous" "default") ; 333 Green Layer
(layerCreation "tops"        4 "continuous" "default") ; 444 Tops Layer
(layerCreation "wall"      150 "continuous" "default") ; 555 Wall Layer
(layerCreation "splash"     30 "continuous" "default") ; 666 Special Layer
(layerCreation "cases"       7 "continuous" "default") ; 777 Cases Layer
(layerCreation "hidden"      8 "hidden"     "default") ; 888 Hidden Layer
(layerCreation "phantom"   230 "phantom2"   "default") ; 999 Phantom Layer
(layerCreation "defpoints"   7 "continuous" "default") ; ``` Defpoints Layer
(layerCreation "glass"     111 "continuous" "default") ; ggg Glass Layer
(layerCreation "dim"         3 "continuous" "default") ; ddd Dim Layer
(layerCreation "hatch"      11 "continuous" "default") ; hhh Hatch Layer
(layerCreation "wainscot"  230 "phantom2"    1)        ; www Wainscot Layer
(layerCreation "3D_Wall"   150 "continuous" "default") ;     Blue 3D Walls
(layerCreation "d4c46345L3"  6 "continuous" "default") ;     My sketch layers

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

(defun c:colorPhantom ( / ) ; change color to IWP Phantom layer 999 & 111
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

(defun c:colorWalls ( / ) ; IWP wall color off-blue 555
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

