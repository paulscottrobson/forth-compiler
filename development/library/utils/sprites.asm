; ****************************************************************************************************
; ****************************************************************************************************
;
;										16 x n Sprite Routines
;
;	Sprites can be either simple XOR, Masked AND/XOR or they can preserve their background data.
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
;	+2 			Vertical Size (bits 0..6)
;	+3 			Drawing color (0 = don't do attribute)
;	+4,5 		pointer to 16 bit pixel data 
;	+6,7 		either 0 (not back stored) or pointer to background storage (pointer + 3 x vertical size)
;	+8,9 		either 0 (no mask data) or pointer to mask data, note set to clear background.
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
;						Copy structure details into the self modifying code
; ****************************************************************************************************

	ld 			a,(ix+2)					; vertical size
	and 		7Fh
	ld 			(__DSLoadVerticalCount+1),a

	ld 			l,(ix+4)					; graphic data
	ld 			h,(ix+5)
	ld 			(__DSLoadGraphicData+1),hl

	ld 			l,(ix+6)					; background store
	ld 			h,(ix+7)
	ld 			(__DSLoadStoreAddress+1),hl

	ld 			l,(ix+8)					; mask data
	ld 			h,(ix+9)
	ld 			(__DSLoadMaskAddress+1),hl

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
;								Copy the starting screen position
; ****************************************************************************************************

	ld 		hl,(__DSLoadStoreAddress+1) 	; get where we are copying old screen data to
	ld 		a,h
	or 		l
	jr 		z,__DSMainLoop
	ld 		de,(__DSLoadScreenAddress+1)	; this is where we copy stuff to on the screen
	ld 		(hl),e 							; copy that address into the first 2 bytes of store address
	inc 	hl
	ld 		(hl),d
	inc 	hl
	ld 		(__DSLoadStoreAddress+1),hl 	; write it back

; ****************************************************************************************************
;   						   S P R I T E     M A I N     L O O P
; ****************************************************************************************************

__DSMainLoop:

; ****************************************************************************************************
;						Copy current screen address to storage if it exists
; ****************************************************************************************************

__DSLoadStoreAddress:
	ld 		de,0 							; look at back storage
	ld 		a,d 							; if zero, then we don't copy out.
	or 		e
	jr 		z,__DSMaskGraphicOutline
	ld 		hl,(__DSLoadScreenAddress+1) 	; HL = source DE = target
	ldi 									; copy three bytes. 
	ldi
	ldi
	ld 		(__DSLoadStoreAddress+1),de 	; save the new target address, 3 bytes on.

; ****************************************************************************************************
;						Mask the graphic mask onto the screen, if it is in use
; ****************************************************************************************************

__DSMaskGraphicOutline:

__DSLoadMaskAddress:
	ld 		hl,0 							; mask data address
	ld 		a,h
	or 		l 								; if mask address is zero, then don't do the mask.
	jr 		z,__DSXorGraphic

	ld 		d,(hl) 							; read mask into DE
	inc 	hl
	ld 		e,(hl)
	inc 	hl
	ld 		(__DSLoadMaskAddress+1),hl 		; update the mask data address

	ex 		de,hl 							; 16 bit now in HL.
	xor  	a 								; 24 bit graphic in AHL
	call 	__DSShiftAHL					; shift it accordingly
	ex 		de,hl 							; now it is in ADE

__DSLoadScreenAddress:
	ld 		hl,4A12h						; where we will write on the screen

	cpl 									; mask the ADE bytes - 1's complement each and AND into screen
	and		(hl)
	ld 		(hl),a
	inc 	l
	ld 		a,d
	cpl
	and		(hl)
	ld 		(hl),a
	inc 	l
	ld 		a,e
	cpl
	and 	(hl)
	ld 		(hl),a


; ****************************************************************************************************
;								XOR the graphic data into the screen
; ****************************************************************************************************
__DSXorGraphic:

__DSLoadGraphicData:
	ld 		hl,0 							; pointer to graphic data (modified in-line)
	ld 		d,(hl) 							; read into DE
	inc 	hl
	ld 		e,(hl)
	inc 	hl
	ld 		(__DSLoadGraphicData+1),hl 		; update graphic data pointer

	ex 		de,hl 							; 16 bit now in HL.
	xor  	a 								; 24 bit graphic in AHL

	call 	__DSShiftAHL					; shift it accordingly

	ex 		de,hl 							; now it is in ADE
	ld 		hl,(__DSLoadScreenAddress+1) 	; HL is where it is XORed into.

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
	ld 		a,h
	cp 		58h								; into attribute memory ?
	jr 		z,__DSExitEarly 				; off bottom of screen, end of sprite draw

__DSNoOverflowScreen1
	ld 		(__DSLoadScreenAddress+1),hl 	; update the screen address.

__DSLoadVerticalCount:
	ld 		a,10 							; count of lines to do
	dec 	a 								; decrement and update
	ld 		(__DSLoadVerticalCount+1),a 	
	jr 		nz,__DSMainLoop 				; keep going till done all lines, or reached the end of screen memory
__DSExitEarly:

	ret

; ****************************************************************************************************
;
;		Advance the line address HL down by 1, handles the slightly odd screen arrangement
;
; ****************************************************************************************************

__DSHLDown:
	inc 	h 								; next line down.
	ld 		a,h 							; have we stepped over the border
	and 	7
	ret 	nz

	ld 		a,h 							; fix up three lower bits of high address byte
	sub 	8
	ld 		h,a

	ld 		a,l 							; next block of 8 down, high 3 bits of low address byte
	add 	32
	ld 		l,a
	ret		nc

	ld 		a,h 							; next page down.
	add 	8
	ld 		h,a
	ret

; ****************************************************************************************************
;
;						Repair damage - restore saved screen for sprite at IX
;
; ****************************************************************************************************

__DSRestoreSavedScreen:
	ld 		b,(ix+2)						; set counter
	res 	7,b
	ld 		l,(ix+6)						; get address of data
	ld 		h,(ix+7)
	ld 		a,h 							; return if zero (e.g. no storage)
	or 		l
	ret 	z
	ld 		e,(hl)							; read start address of screen into DE
	inc 	hl
	ld 		d,(hl)
	inc 	hl

__DSRLoop:
	push 	bc
	ldi  									; copy three bytes (HL) to (DE)	
	ldi 
	ldi 
	dec 	de 								; fix up DE 								
	dec 	de
	dec 	de
	ex 		de,hl 							; HL = screen
	call	__DSHLDown	 					; down one line
	ex 		de,hl 							; put back so DE screen HL data

	pop		bc 								; do once for each line
	djnz 	__DSRLoop
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
	ld 		hl,1
TSDelay:
	dec 	hl
	ld 		a,h
	or 		l
	jr 		nz,TSDelay
	call	__DSRestoreSavedScreen
	inc 	(ix+0)
	inc 	(ix+1)
	ld 		a,(ix+0)
	cp 		192
	jr 		nz,TSLoop
	ld 		(ix+0),64
	ld 		(ix+1),32
	jr 		TSLoop

testSprite:
	defb 	64
	defb 	32	
	defb 	10
	defb 	0
	defw 	graphicData
	defw 	backStore
	defw 	maskData

backStore:
	defs 	10*3+2

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

maskData:
	defb 	0FFh,0FFh
	defb 	0FFh,0FFh
	defb 	0FFh,0FFh
	defb 	0FFh,0FFh
	defb 	0FFh,0FFh
	defb 	0FFh,0FFh
	defb 	0FFh,0FFh
	defb 	0FFh,0FFh
	defb 	0FFh,0FFh

