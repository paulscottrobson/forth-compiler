; ****************************************************************************************************
;
;									Arithmetic and Logic (Unary)
;
; ****************************************************************************************************

; abs sgn

WORD_0Minus:								; <<0->>
	exx
	pop 	de
	ld 		hl,0
	xor 	a
	sbc 	hl,de
	push 	hl
	exx 	
	jp 		(ix)

WORD_0Equals:
	pop 	hl 								; <<0=>>
	ld 		a,h
	or 		l
	jr 		z,__UNPushTrue
__UNPushFalse:
	ld 		hl,0
	push 	hl
	jp 		(ix)
__UNPushTrue:
	ld 		hl,0xFFFF
__UNPushHLExit	
	push 	hl
	jp		(ix)

WORD_0LessThan:								; <<0<>>
	pop 	hl
	bit 	7,h
	jr 		nz,__UNPushTrue
	jr 		__UNPushFalse

WORD_Abs:									; <<abs>>
	pop 	hl
	bit 	7,h 							
	jr 		z,__UNPushHLExit 				; if zero push unchanged
	push 	hl
	jr	 	WORD_0Minus 					; otherwise do 0-

WORD_Sgn:									; <<sgn>>
	pop 	hl
	bit 	7,h 							; -ve
	jr 		nz,__UNPushTrue
	ld 		a,h 							; zero
	or 		l
	jr 		z,__UNPushFalse
	ld 		hl,1 							; +ve push 1
	jr 		__UNPushHLExit
	
; ****************************************************************************************************
;
;										Arithmetic Quickies
;
; ****************************************************************************************************

	pop		hl								; <<1+>>
	jr 		__OnePlus

WORD_TwoPlus
	pop		hl								; <<2+>>
	inc 	hl
__OnePlus:	
	inc 	hl
	push 	hl
	jp 		(ix)

	pop		hl								; <<1->>
	jr 		__OneMinus

	pop		hl								; <<1->>
	dec 	hl
__OneMinus:	
	dec 	hl
	push 	hl
	jp 		(ix)

	pop		hl 								; <<2*>>
	jr 		__TwoTimes

	pop 	hl								; <<4*>>
	jr 		__FourTimes

	pop		hl 								; <<16*>>
	add 	hl,hl
	add 	hl,hl
__FourTimes:
	add 	hl,hl
__TwoTimes:	
	add 	hl,hl
	push 	hl
	jp 		(ix)

	pop 	hl 								; <<256*>
	ld	 	h,l
	ld	 	l,0
	push 	hl
	jp 		(ix)

	pop 	hl 								; <<2/>>
	jr 		__TwoDivide	

	pop 	hl 								; <<16/>>

	sra 	h
	rr 		l
	sra 	h
	rr 		l
	sra 	h
	rr 		l

__TwoDivide:
	sra 	h
	rr 		l
	push 	hl
	jp 		(ix)

	pop 	hl								; <<256/>>
	ld	 	l,h
	ld 	 	h,0
	bit 	7,l 							; sign extend
	jr 		z,__ByteDivideNotSigned
	dec 	h
__ByteDivideNotSigned: 	
	push 	hl
	jp 		(ix)
