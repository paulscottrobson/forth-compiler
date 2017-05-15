; ****************************************************************************************************
; ****************************************************************************************************
;
;			Replacement for Spectrums Screen Display Routine, straight 32x24 video display
;
; ****************************************************************************************************
; ****************************************************************************************************

; ****************************************************************************************************
;
;							Print character in L ; all registers preserved.
;
; ****************************************************************************************************

PrintCharL:
	push 	af 								; stack registers
	push 	bc 								
	push 	de
	push 	hl

	ld 		a,l 							; check for CR ?
	cp 		13
	jr		z,__PCLReturn

	ld 		b,0 							; B is the reversing byte
	bit 	7,l 							; if bit 7 set
	jr 		z,__PCANotReverse
	dec 	b 								; B becomes $FF
	res 	7,l 							; drop bit 7
__PCANotReverse:
	ld 		h,0 							; HL to 16 bit
	ld 		de,(__PCAFont)					; DE = Font Base
	add 	hl,hl 							; calc Font Base + char * 8
	add 	hl,hl
	add 	hl,hl
	add 	hl,de
	ex 		de,hl 							; put in DE
	ld 		hl,(__PCAVideoPos) 				; get write address
	push 	hl 								; save for later
_PCALoop:	
	ld 		a,(de) 							; read font char
	xor 	b 								; reverse byte
	ld 		(hl),a 							; write to screen
	inc 	e 								; bump pointers
	inc 	h
	ld 		a,h 							; until done whole row
	and 	7
	jr 		nz,_PCALoop


	ld 		de,(__PCAAttribPos)				; copy colour byte to attribute memory.
	ld 		a,(__PCAColour)
	ld 		(de),a
	inc 	de

	pop 	hl 								; restore original video position to HL
	inc 	l 								; right one
	jr 		nz,__PCANotNewPage 				; if nz don't need new 1/4k page
	ld 		a,h 							; advance to next quarter page
	add 	8
	ld 		h,a 	
	cp 		0x58 							; we only have 3, this is the attribute page
	jr 		nz,__PCANotNewPage
	ld 		h,0x40 							; wrap round to top.
	ld 		d,0x58 							; reset attribute memory pointer
__PCANotNewPage:
	ld 		(__PCAVideoPos),hl 				; update new position in video / attr
	ld 		(__PCAAttribPos),de 			

__PCLExit:
	pop 	hl 								; destack.
	pop 	de
	pop 	bc
	pop 	af
	ret

__PCLReturn: 								; carriage return.
	ld 		l,' '
	call 	PrintCharL
	ld 		a,(__PCAVideoPos)
	and 	31
	jr 		nz,__PCLReturn
	jr 		__PCLExit

; ****************************************************************************************************
;
;									Print HL in hexadecimal
;
; ****************************************************************************************************

PrintInteger:
	push 	hl
	ld 		l,' ' 							; print leading space
	call 	PrintCharL
	pop 	hl
	ld 		a,h
	call 	PrintByteA
	ld 		a,l
	call 	PrintByteA
	ret

; ****************************************************************************************************
;
;									Print Byte in Hexadecimal
;
; ****************************************************************************************************

PrintByteA:
	push 	af 								; save A on stack
	rra 									; shift right 4
	rra
	rra
	rra
	call	__PBANibble 					; print it
	pop 	af 								; restore
__PBANibble:
	or 		0F0h 							; DAA trick
	daa
	add 	a,0A0h
	adc 	a,040h
	push 	hl 								; print character
	ld 		l,a
	call 	PrintCharL
	pop 	hl
	ret

; ****************************************************************************************************
;	
;											Clear Screen
;
; ****************************************************************************************************

ClearScreen:
	push 	hl
	ld 		hl,0x4000 						; fill 4000-57FF with zero
__CLSLoop1:
	ld 		(hl),0

	ld 		(hl),042h

	inc 	hl
	ld 		a,h
	cp 		0x58
	jr		nz,__CLSLoop1
__CLSLoop2:									; fill 5800-5FFF with 7 (white)
	ld 		(hl),7
	inc 	hl
	ld 		a,h
	cp 		0x60
	jr		nz,__CLSLoop2
	ld 		a,1 							; set border to blue.
	out 	(0xFE),a
	pop 	hl
	ret

; ****************************************************************************************************
;
;												Home Cursor
;
; ****************************************************************************************************

HomeCursor:	
	push 	hl
	ld 		hl,0x5800 						; reset attribute pos
	ld 		(__PCAAttribPos),hl
	ld 		h,0x40 							; reset video pos
	ld 		(__PCAVideoPos),hl
	pop 	hl
	ret

__PCAFont: 									; font base here
	defw 	0x3C00
__PCAVideoPos: 								; current video memory pointer.
	defw 	VideoMemory
__PCAAttribPos:								; current attribute pointer
	defw 	AttributeMemory
__PCAColour: 								; current colour to use
	defb 	0x44
