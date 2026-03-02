; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Global Variables ----------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(setq useCommandLine 1 
    runDebug t)

; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Set ACAD Enviornment ------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(setvar '2dRetainModeLevel 2    ; seemingly undocumented
    'acadLspAsDoc 0             ; controls how ACAD will load the lisp file
    'angDir 1                   ; clockwise rotational values
    'attDia 0                   ; sets insert command to use command prompts
    'autoSnap 55                ; legacy value := 39
    'ceLtScale 1                ; sets object lintype scaling factor
    'cmdEcho 0                  ; suppresses dialouge boxes within commandline
    'constraIntInfer 0          ; this causes unintended line stickage if enabled
    'cursorSize 25              ; sets length of cursor's arms
    'defaultGizmo 3             ; disables gizmo when object selected in 3d visual mode
    'dimAdec 0                  ; disables decimils when displaying angluar dimensions (independant of dimdec)
    'dimAzin 2                  ; supresses trailing zeroes for decimal angular dimensions
    'dimClrD 1                  ; dimension arrow color, red
    'dimClrE 1                  ; dimension extension color, red
    'dimClrT 0                  ; dimension text color, by block
    'dimFrac 2                  ; controls dimension fractional layout
    'dimZin 12                  ; controls dimension zero suppression
    'dynMode 3                  ; contols dynamic input
    'fileTabPreview 0           ; disables dwg preview on tab hover
    'fileTabThumbHover 0        ; disables preloading of drawings on tab mouse hover
    'gridMode 0                 ; disables background grid
    'gripColor 5                ; set color of grips @ unselected
    'gripHot 255                ; set color of grips @ selection
    'gripHover 255              ; set color of grips @ hover
    'highlight 1                ; controls how selected objects are displayed
    'layerEvalCtl 0             ; disables evaluation and notification of new layers
    'layoutRegenCtl 0           ; supresses layout regeneration after first page load, reads from cache after
    'lispInit 0                 ; preservers AutoLISP variables & functions between drawings
    'ltScale 0.375              ; sets line type scale
    'mTextAutoStack 0           ; disables automatic fraction stack on text
    'menuBar 0                  ; toggles menubar "Home, Insert, Annotate, etc" display
    'mirrText 0                 ; retains text orientation through mirroring
    'msLtScale 1                ; model space linetypes scaled by annotation type
    'osMode 14847               ; user snap preferences
    'paletteOpaque 1            ; controls menu opacitiy
    'pdMode 3                   ; controls how point objects are displayed 
    'pickFirst 1                ; allows selection before running commands
    'refPathType 2              ; full file path names by default
    'regenMode 0                ; controls automatice regenerations
    'rememberFolders 1          ; consisitent filepath based on the directory where AutoCAD launched
    'reportError 0              ; if you chose to send or not send the report does it even make a difference?
    'revCloudArcVariance 1      ; adds variances to arc lengths on revc
    'revCloudCreateMode 1       ; defaults to rectangular points
    'rolloverTips 0             ; object hover tooltips
    'sdi 0                      ; single drawing instance
    'selectionCycling 0         ; disables selection dialouge box 
    'snapmode 0                 ; because why do some people even enable this?!
    'textAllCaps 1              ; converts all new TEXT and MTEXT commands to uppercase
    'toolTips 1                 ; controls on hover tooltips  
    'whipThread 3               ; multithreading for regen & redraw
    'wipeoutFrame 2             ; wipeout frame does not appear once plotted.
    'xRefLayer "TITLE"          ; controls layer which xRefs are placed on
    'zoomFactor 10)             ; speed of zoom, default=60

(if runDebug (princ "Init complete\n"))

