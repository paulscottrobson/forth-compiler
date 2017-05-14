; ****************************************************************************************************
;
;									Arithmetic and Logic (Binary)
;
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

