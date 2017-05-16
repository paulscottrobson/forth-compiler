; ****************************************************************************************************
; ****************************************************************************************************
;
;										16 x 16 Sprite Routines
;
;	These sprites are simple 16x16 XOR which restore the background attributes from a shadow of 
;	$5800-$5B00 at $5C00-$5F00. It is designed to operate not dissimilarly to the Next ; pure 
; 	XOR sprites can be removed and moved in any order you like.
;
;	There is some self modifying code here - the pointers are all kept in SMC, so is the counter
;	and it is also used to modify the 24 bit shifter.
;
; ****************************************************************************************************
; ****************************************************************************************************
;	
;	IX points to the sprite data, as follows.
;
;	+0 			X position (0-255)
;	+1 			Y position (0-191)
;	+2 			Drawing color (0 = don't do attribute)
;	+3 			Bit 7 : drawn=1, erased=0
;	+4,5 		pointer to 16 bit pixel data, 32 bytes
;	+6,7 		reserved (0)
;
; ****************************************************************************************************
;
;												Draw Sprite
;
; ****************************************************************************************************

DrawSprite:
	ld 		a,(ix+1) 						; get the Y position.
	cp 		192
	ret 	nc 								; if >= 24*8 then exit now.	

	ld  	e, a 							; save in E
	and 	7 								; get the three low bits.
	ld  	h,a 							; goes in H bits 2..0

	ld 		a,e 							; we want bits 7..6 to be in 4..3
	rra 									; in 6..5
	rra 									; in 5..4
	rra										; in 4..3
	and 	018h 							; isolate
	or 		h 								; or with H
	or 		040h 							; set bit 6
	ld 		h,a 							; and copy back.

	ld 		a,e 							; we want bits 5,4,3 to be in slots 7,6,5
	add 	a,a
	add 	a,a
	and 	0E0h
	ld 		l,a 							; save in L

	ld 		a,(ix+0) 						; get X bits 7..3 - 4..0
	rra
	rra
	rra	
	and 	1Fh
	or  	l 								; or into L and write back
	ld  	l,a 							; HL now is the base graphic
	ld 		(__DSLoadScreenAddress+1),hl 	; save it out

; ****************************************************************************************************
;						Copy address of graphic data, self modifying code.
; ****************************************************************************************************

	ld 			l,(ix+4)					; graphic data
	ld 			h,(ix+5)
	ld 			(__DSLoadGraphicData+1),hl

; ****************************************************************************************************
;					Set up the pixel shifter for the 3 LSB of the x coordinate
; ****************************************************************************************************

	ld 		a,(ix+0) 						; x 0-7 pixels
	and 	7
	jr 		z,__DSOffsetDone 				; if zero, the JR will just fall through to register move
	dec 	a
	add 	a,a	
	add 	__DSShiftEntry-__DSShiftAHL-2
__DSOffsetDone:
	ld 		(__DSShiftAHL+1),a 				; set the JR offset.

; ****************************************************************************************************
;   						   S P R I T E     M A I N     L O O P
; ****************************************************************************************************

	ld 			b,16 						; reset the draw counter to 16.
__DSMainLoop:
	push 		bc

; ****************************************************************************************************
;								XOR the graphic data into the screen
; ****************************************************************************************************

__DSLoadGraphicData:
	ld 		hl,0000h 						; pointer to graphic data (modified in-line)
	ld 		d,(hl) 							; read into DE
	inc 	hl
	ld 		e,(hl)
	inc 	hl
	ld 		(__DSLoadGraphicData+1),hl 		; update graphic data pointer

	ex 		de,hl 							; 16 bit now in HL.
	xor  	a 								; 24 bit graphic in AHL

	call 	__DSShiftAHL					; shift it accordingly

	ex 		de,hl 							; now it is in ADE

__DSLoadScreenAddress:
	ld 		hl,0000h						; where we will write on the screen

	xor 	(hl) 							; XOR those three bytes in to the screen
	ld 		(hl),a
	inc 	l
	ld 		a,d
	xor 	(hl)
	ld 		(hl),a
	inc 	l
	ld 		a,e
	xor 	(hl)
	ld 		(hl),a
	dec 	l 								; unpick the increment so HL points to the first byte
	dec 	l

; ****************************************************************************************************
;										Move to the next line down
; ****************************************************************************************************

	call 	__DSHLDown 						; HL Down one line
	ld 		(__DSLoadScreenAddress+1),hl 	; update the screen address.

	pop 	bc 								; restore counter
	ld 		a,h
	cp 		58h								; into attribute memory ?
	jr 		z,__DSExitEarly 				; off bottom of screen, end of sprite draw


	djnz	__DSMainLoop 					; keep going till done all lines, or reached the end of screen memory

__DSExitEarly:
	ld 		a,(ix+3)						; toggle the erased/drawn bit
	xor 	080h
	ld 		(ix+3),a
	ret

; ****************************************************************************************************
;
;		Advance the line address HL down by 1, handles the slightly odd screen arrangement
;
;							If CY clear, then we have changed attribute byte.
;
; ****************************************************************************************************

__DSHLDown:
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

; ****************************************************************************************************
;
;	Shift the 24 bit value AHL left a number of times defined by the x coordinate, set up at the
;	start of the drawing routine.
;
; ****************************************************************************************************

__DSShiftAHL:
	jr 		__DSShiftEntry 					; this jump vector is zero if x % 8 = 0, otherwise it jumps into code below to shift
	ld 		a,h
	ld 		h,l
	ld 		l,0
	ret

__DSShiftEntry:
	add 	hl,hl 							; the JR at __DSShiftEntry jumps into this code.
	adc 	a,a
	add 	hl,hl
	adc 	a,a
	add 	hl,hl
	adc 	a,a
	add 	hl,hl
	adc 	a,a

	add 	hl,hl
	adc 	a,a
	add 	hl,hl
	adc 	a,a
	add 	hl,hl
	adc 	a,a
	ret

; ****************************************************************************************************

TSDraw:
	ld 		ix,testSprite
TSLoop:
	call 	DrawSprite
TSDelay:
	ld 		hl,1000
TSDelay1:
	dec 	hl
	ld 		a,h
	or 		l
	jr 		nz,TSDelay1
	call 	DrawSprite
	inc 	(ix+0)
	inc 	(ix+1)
	ld 		a,(ix+1)
	cp 		160
	jr 		nz,TSLoop
	ld 		(ix+0),64
	ld 		(ix+1),32
	jr 		TSLoop

testSprite:
	defb 	64
	defb 	32	
	defb 	1,0
	defw 	graphicData,0

graphicData:
	defb 	0FFh,0FFh
	defb 	0AAh,0AAh
	defb 	080h,003h
	defb 	080h,007h

	defb 	08Fh,00Fh
	defb 	080h,01Fh
	defb 	0FFh,0E0h
	defb 	002h,000h

	defb 	002h,000h
	defb 	007h,000h
	defb 	080h,001h
	defb 	080h,001h

	defb 	080h,001h
	defb 	080h,001h
	defb 	080h,001h
	defb 	0FFh,0FFh
