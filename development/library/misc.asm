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

; ****************************************************************************************************
;
;	These routines are (potentially) common to any graphics routines, so are placed here. At the
;
;	present time both are only used by 'Sprite'
;
; ****************************************************************************************************

; ****************************************************************************************************
;
;		Calculate Pixel Address (DE)  Attribute Address (HL) for Pixel (B,C). Return CY=0 if bad 
;
; ****************************************************************************************************

CalculatePixelAndAttrAddress:
	ld 		a,c 							; check Y on screen
	cp 		192
	ret 	nc 								; if >= 24*8 then exit now.	

	and 	7 								; get the three low bits.
	ld  	h,a 							; goes in H bits 2..0

	ld 		a,c 							; we want bits 7..6 to be in 4..3
	rra 									; in 6..5
	rra 									; in 5..4
	rra										; in 4..3

	and 	018h 							; isolate
	or 		h 								; or with H
	or 		040h 							; set bit 6
	ld 		h,a 							; and copy back.

	ld 		a,c 							; we want bits 5,4,3 to be in slots 7,6,5
	add 	a,a
	add 	a,a
	and 	0E0h
	ld 		l,a 							; save in L

	ld 		a,b 							; get X bits 7..3 - 4..0
	rra
	rra
	rra	
	and 	1Fh
	ld 		e,a 							; save X/8 in E

	or  	l 								; or into L and write back
	ld  	l,a 							; HL now is the base graphic
	push 	hl

	ld 		a,(ix+1) 						; get Y
	and 	0F8h							; now (Y / 8) * 8
	ld 		l,a
	ld 		h,0
	add 	hl,hl 						
	add 	hl,hl 							; now (Y / 8) * 32

	ld 		d,058h 							; B = $5800 + (X / 8)
	add 	hl,de
	pop 	de
	scf
	ret

; ****************************************************************************************************
;
;		Advance the line address HL down by 1, handles the slightly odd screen arrangement
;
;							If CY clear, then we have changed attribute byte.
;
; ****************************************************************************************************

MovePixelAddressDown:
	inc 	h 								; next line down.
	ld 		a,h 							; have we stepped over the border
	and 	7
	scf 									; if we haven't, return with CY set.
	ret 	nz

	ld 		a,h 							; fix up three lower bits of high address byte
	sub 	8
	ld 		h,a

	ld 		a,l 							; next block of 8 down, high 3 bits of low address byte
	add 	32
	ld 		l,a
	ret		nc

	ld 		a,h 							; next page down ; also it will clear the carry.
	add 	8
	ld 		h,a
	ret

	