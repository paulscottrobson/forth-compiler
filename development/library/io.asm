; ****************************************************************************************************
;
;										Input/Output functions
;
; ****************************************************************************************************

WORD_Emit:									; <<emit>>
	pop 	hl 								; get character to print in L
	call	PrintCharL
	jp 		(ix)

WORD_PrintInteger:							; <<.>>
	pop 	hl
	call 	PrintInteger
	jp 		(ix)

WORD_PrintStack:							; <<.stack>>
	push 	de 								; save DE
	ld 		hl,0  							; get SP into HL
	inc 	hl 								; skip over PUSH DE above
	inc 	hl
	add 	hl,sp
	ld  	a,46h 							; first yellow
	ld 		(__PCAColour),a
__PSLoop:
	ld 		e,(hl) 							; load into DE
	inc 	hl
	ld 		d,(hl)
	inc 	hl
	ex 		de,hl 							; print it
	call 	PrintInteger
	ex 		de,hl
	ld  	a,44h 							; remainder green
	ld 		(__PCAColour),a
	ld 		a,h 							; reached top of stack
	or 		a
	jr 		nz,__PSLoop
	pop 	de 								; restore DE
	ld 		l,13 							; print CR
	call 	PrintCharL
	jp 		(ix)

WORD_ClearScreen:							; <<cls>>
	call 	ClearScreen
	call 	HomeCursor
	jp 		(ix)

WORD_CR:									; <<cr>>
	jp 		(iy)
	defw 	Core_Literal
	defw 	13
	defw 	WORD_Emit
	defw 	Core_Return

; ****************************************************************************************************
;			This is included if io.asm is included, provides direct I/O to Speccy hardware
; ****************************************************************************************************

	include "utils/screen.asm" 				; Screen I/O routines.
