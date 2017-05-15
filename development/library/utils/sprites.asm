; ****************************************************************************************************
; ****************************************************************************************************
;
;										16x16 Sprite Routines
;
; ****************************************************************************************************
; ****************************************************************************************************

;
;	+0 			X position
;	+1 			Y position
;	+2 			Vertical Size (bits 0..6)
;	+3 			Drawing color (0 = don't do attribute)
;	+4,5 		pointer to 16 bit pixel data 
;	+6,7 		either 0 (not back stored) or pointer to background storage (pointer + 3 x vertical size)
;	+8,9 		either 0 (no mask data) or pointer to mask data, note set to clear background.
;

DrawSprite:
	ld 		ix,testSprite

	ld 		hl,(__DSLoadScreenAddress+1)
	dec		h 								; temp for checking.
	dec 	h
	ld 		(hl),$FF

__DSMainLoop:

__DSLoadScreenAddress:
	ld 		hl,4A12h

;
;	XOR the graphic data into the screen
;
__DSLoadGraphicData:
	ld 		hl,graphicData 					; pointer to graphic data (modified in-line)
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

	xor 	(hl) 							; XOR those three bytes in.
	ld 		(hl),a
	inc 	l
	ld 		a,d
	xor 	(hl)
	ld 		(hl),a
	inc 	l
	ld 		a,e
	xor 	(hl)
	ld 		(hl),a
	dec 	l 								; unpick the increment
	dec 	l
;
;	Move to the next line down
;
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


Stop:
	jr 		Stop
	ret

;
;	Advance the line down by 1, handles the slightly odd screen arrangement
;
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
;
;	Shift the 24 bit value AHL left a number of times defined by the x coordinate
;
__DSShiftAHL:
	jr 		__DSShiftEntry+2*2
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

testSprite:
	defb 	2
	defb 	4
	defb 	8
	defb 	8

backStore:
	defs 	8*3

graphicData:
	defb 	0FFh,0FFh
	defb 	080h,001h
	defb 	080h,003h
	defb 	080h,007h
	defb 	08Fh,00Fh
	defb 	080h,01Fh
	defb 	0FFh,0E0h
	defb 	002h,000h
	defb 	002h,000h
	defb 	007h,000h

maskData:
	defb 	001h,080h
	defb 	003h,0C0h
	defb 	007h,0E0h
	defb 	00Fh,0F0h
	defb 	01Fh,0F8h
	defb 	03Fh,0FCh
	defb 	07Fh,0FEh
	defb 	0FFh,0FFh
	defb 	001h,080h
	defb 	0FFh,0FFh
