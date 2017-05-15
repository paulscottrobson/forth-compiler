; ****************************************************************************************************
;
; 												Miscellany
;
; ****************************************************************************************************


WORD_Branch:								; <<[br]>>
	ex 	 	de,hl 							; HL now points to the next word
	ld 		e,(hl)							; read into DE
	inc 	hl
	ld 		d,(hl)
	jp 		(ix) 							; and go there.

WORD_BranchZero:
	pop 	hl 								; non destructive test of TOS
	push 	hl
	ld 		a,h 							; branch if zero.
	or 		l
	jr 		z,WORD_Branch
__WORD_BranchFail:							; if non zero
	inc 	de 								; skip over jump address
	inc 	de
	jp 		(ix)

WORD_BranchPositive:
	pop 	hl 								; non destructive test of TOS
	push 	hl
	bit 	7,h 							; if +ve branch
	jr 		z,WORD_Branch
	jr 		__WORD_BranchFail 				; if -ve don't

WORD_Stop:									; <<stop>>
	jr 		WORD_Stop

WORD_RStoDS:								; <<r>>>
	ld 		a,(bc) 							; pop address into HL
	dec 	bc
	ld 		h,a 
	ld 		a,(bc)
	dec 	bc
	ld 		l,a
	push 	hl 								; push on data stack.
	jp 		(ix)

WORD_DStoRS:								; <<>r>>
	pop 	hl 								; get top of data stack
	inc 	bc 								; push on return stack.
	ld 		a,l
	ld 		(bc),a
	inc 	bc
	ld 		a,h
	ld 		(bc),a
	jp 		(ix)

WORD_RDrop:									; <<rdrop>>
	dec 	bc
	dec 	bc
	jp 		(ix)