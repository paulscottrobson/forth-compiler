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
;	On a stock Spectrum (Fuse) can do about 500 draws/erases a second.
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
;								Draw/Erase main entry points
;	
; ****************************************************************************************************

DrawSprite:
	bit 	7,(ix+3)
	ret 	nz
	jr 		__DSDrawSprite

EraseSprite:
	bit 	7,(ix+3)
	ret 	z
	jr 		__DSDrawSprite

; ****************************************************************************************************
;
;									Draw Sprite Main Code
;
; ****************************************************************************************************

__DSDrawSprite:
	push 	bc 								; save registers
	push 	de
	push 	hl
	ld 		b,(ix+0)						; get the X position
	ld 		c,(ix+1) 						; get the Y position.
	call 	CalculatePixelAndAttrAddress 	; calculate pixel/attribute address
	jr 		nc,__DSPop		 				; off screen

	ld 		(__DSAttributeAddress+1),hl 	; save attribute address
	ld 		(__DSPixelAddress+1),de 		; save pixel address

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

	call 	__DSColourLine 					; colour the first line.

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

__DSPixelAddress:
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

	call 	MovePixelAddressDown 						; HL Down one line
	ld 		(__DSPixelAddress+1),hl 		; update the screen address.

	jr 		c,__DSHNoAttributeDown 			; no attribute change

	push 	hl 								; save HL
	ld 		hl,(__DSAttributeAddress+1) 	; add 32 to attribute address
	ld 		de,32
	add 	hl,de
	ld 		(__DSAttributeAddress+1),hl
	call 	__DSColourLine 					; colour that line
	pop 	hl 								; restore HL

__DSHNoAttributeDown:

	pop 	bc 								; restore counter
	ld 		a,h
	cp 		58h								; into attribute memory ?
	jr 		z,__DSExitEarly 				; off bottom of screen, end of sprite draw


	djnz	__DSMainLoop 					; keep going till done all lines, or reached the end of screen memory

__DSExitEarly:
	ld 		a,(ix+3)						; toggle the erased/drawn bit
	xor 	080h
	ld 		(ix+3),a

__DSPop:
	pop 	hl
	pop 	de
	pop 	bc
	ret

; ****************************************************************************************************
;
;										Colour the current line
;
; ****************************************************************************************************

__DSColourLine:
	
__DSAttributeAddress:
	ld 		hl,0000 						; address to write colour to.
	ld 		a,(ix+2)						; get attribute to write.
	or 		a
	ret 	z

	bit 	7,(ix+3) 						; if bit 7 is set (e.g. we are erasing)
	jr 		nz,__DSCLErase

	ld 		(hl),a 							; write 2 bytes out.
	inc 	hl
	ld 		(hl),a 
	ld 		b,a 							; save in B.
	ld 		a,(ix+0) 						; do not write third attribute out if X mod 8 = 0, fits in two words.
	and 	7
	ret 	z
	inc 	hl 								; do the third attribute byte
	ld 		(hl),b
	ret

__DSCLErase:
	ld 		e,l 							; copy HL to DE
	ld 		d,h
	ld 		a,h 							; copy from $5C00-$5EFF to $5800-$5AFF
	add 	4	
	ld 		h,a
	ldi
	ldi
	ldi
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
;
;								Copy attribute screen to shadow screen
;
; ****************************************************************************************************

CopyAttributeToShadow:
	exx
	ld 		de,05C00h 						; to shadow at $5C00
	ld 		hl,05800h 						; from original at $5800
	ld 		bc,32*24 						; bytes to copy
	ldir 	 								; copy.
	exx
	ret
