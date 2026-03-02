; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- AutoExecute Commands ------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(vl-load-com)

(command-s "model")
(command-s "vsCurrent" "2dWireframe")

(c:rat)
(c:fr23)

(if (= useCommandLine 1)
    (command-s ".commandLine")
    (command-s ".commandLineHide"))

(if runDebug (princ "\n\tAutorun complete"))
(princ "\n\tFile loaded without errors")(terpri)

; Note: opening the part editor in the following way results in quiet errors & should not be done.
; (if (= "Composite.DWG" (getvar 'dwgName)) (command "mvSinglePartEditor"))

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
