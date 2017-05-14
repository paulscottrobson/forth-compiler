; ****************************************************************************************************
; ****************************************************************************************************
;
;										Basic FORTH Library
;
; ****************************************************************************************************
; ****************************************************************************************************

; ****************************************************************************************************
;									Arithmetic and Logic (Binary)
; ****************************************************************************************************

WORD_Add:									; <<+>>
	exx 
	pop		hl
	pop 	de
	add 	hl,de
	push 	hl
	exx
	jp 		(ix)

WORD_Subtract: 								; <<->>
	exx 
	pop 	de
	pop 	hl
	xor 	a
	sbc 	hl,de
	push 	hl
	exx 	
	jp 		(ix)

WORD_And:									; <<and>>
	exx
	pop 	de
	pop 	hl
	ld 		a,h 							; do MSB
	and 	d
	ld 		h,a
	ld 		a,l 							; do LSB
	and 	e
__WORD_Logic_Exit:
	ld 		l,a 							
	push 	hl
	exx
	jp 		(ix)

WORD_Xor:									; <<xor>>
	exx
	pop 	de
	pop 	hl
	ld 		a,h 							; do MSB
	xor 	d
	ld 		h,a
	ld 		a,l 							; do LSB
	xor 	e
	jr 		__WORD_Logic_Exit

WORD_Or:									; <<or>>
	exx
	pop 	de
	pop 	hl
	ld 		a,h 							; do MSB
	or 		d
	ld 		h,a
	ld 		a,l 							; do LSB
	or 		e
	jr 		__WORD_Logic_Exit

; ****************************************************************************************************
;						Constants, quicker and shorter versions of .literal
; ****************************************************************************************************

WORD_MinusOne:								; <<-1>>
	ld 		hl,-1
	push 	hl
	jp 		(ix)

WORD_Zero:
	ld 		hl,0 							; <<0>>
	push 	hl
	jp 		(ix)

WORD_One:									; <<1>>
	ld 		hl,1
	push 	hl
	jp 		(ix)

WORD_Two:									; <<2>>
	ld 		hl,2
	push 	hl
	jp 		(ix)

WORD_Four:									; <<4>>
	ld 		hl,4
	push 	hl
	jp 		(ix)

WORD_Eight:									; <<8>>
	ld 		hl,8
	push 	hl
	jp 		(ix)

WORD_Ten:									; <<10>>
	ld 		hl,10
	push 	hl
	jp 		(ix)

; ****************************************************************************************************
;									Arithmetic and Logic (Unary)
; ****************************************************************************************************

; ****************************************************************************************************
;										  Stack Manipulation
; ****************************************************************************************************

WORD_Dup:									; <<dup>>
	pop 	hl 								; get TOS and push it back twice
	push 	hl
	push 	hl
	jp 		(ix) 							; return 

WORD_Drop:									; <<drop>>
	pop 	hl
	jp 		(ix)

WORD_Swap:									; <<swap>>
	exx 									; use alt register set
	pop 	hl 								; get TOS and push it back twice
	pop 	de
	push 	hl
	push 	de
	exx 
	jp 		(ix) 							; return 

; ****************************************************************************************************
;											Output functions
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
__PSLoop:
	ld 		e,(hl) 							; load into DE
	inc 	hl
	ld 		d,(hl)
	inc 	hl
	ex 		de,hl 							; print it
	call 	PrintInteger
	ex 		de,hl
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

; ****************************************************************************************************
; 												Miscellany
; ****************************************************************************************************

WORD_Stop:									; <<stop>>
	jr 		WORD_Stop
