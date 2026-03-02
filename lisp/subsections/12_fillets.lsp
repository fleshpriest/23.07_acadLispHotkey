; /-------------------------------------------------------------------------------------------------------------------------------------------------/
; /--- Fillets -------------------------------------------------------------------------------------------------------------------------------------/
; /-------------------------------------------------------------------------------------------------------------------------------------------------/

(defun c:f` ( / ) ; remove arc from lines
	(setvar 'filletrad 0)
	(command-s ".fillet" "multiple"))

(defun c:f`1 ( / ) ; fillet 0.0625" rad
	(setvar 'filletrad 0.0625)
	(command-s ".fillet" "multiple"))

(defun c:f125 ( / ) ; fillet 0.125" rad
	(setvar 'filletrad 0.125)
	(command-s ".fillet" "multiple"))

(defun c:f25 ( / ) ; fillet 0.25" rad
	(setvar 'filletrad 0.25)
	(command-s ".fillet" "multiple"))

(defun c:f5 ( / ) ; fillet 0.5" rad
	(setvar 'filletrad 0.5)
	(command-s ".fillet" "multiple"))

(defun c:f75 ( / ) ; fillet 0.75" rad
	(setvar 'filletrad 0.75)
	(command-s ".fillet" "multiple"))

(defun c:f1 ( / ) ; fillet 1" rad
	(setvar 'filletrad 1)
	(command-s ".fillet" "multiple"))

(defun c:f15 ( / ) ; fillet 1.5" rad
	(setvar 'filletrad 1.5)
	(command-s ".fillet" "multiple"))

(defun c:f2 ( / ) ; fillet 2" rad
	(setvar 'filletrad 2)
	(command-s ".fillet" "multiple"))

(if runDebug (princ "Fillets complete\n"))

