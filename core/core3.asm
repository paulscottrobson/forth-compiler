CORE_Start:
	ld 		ix,CORE_Return
	jr 		CORE_MainLoop
;
;	Return from subroutine call / execute inline code.
;
CORE_Return:
	pop 	de 											; return from call.
;
;	Main loop. Execute instruction at DE
;
CORE_MainLoop:
	ld 		a,(de) 										; read next instruction, copy into C
	ld 		c,a
	inc 	de
	add 	a,a 										; shift bit 7 into C, A left one.
	jr 		c,CORE_Call 								; if carry set go to call code.
	jr 		z,CORE_DoInline								; if zero (and carry clear), go to inline code.
;
;	Unsigned integer value. $01xx - $7Fxx (represents $0000-$7EFF values). TOS (HL) always points to
;	the high byte.
;
CORE_Integer:
	ld 		a,(de) 										; get the low byte of the integer
	inc 	de
	dec 	hl 											; push on stack
	ld 		(hl),a
	dec 	hl											; push the high byte on the stack
	ld 		(hl),c
	dec 	(hl) 										; converts $01xx to $00xx
	jr 		CORE_MainLoop 								; and go round again
;
;	Call routine ($80-$FF)
;
CORE_Call:
	ld 		a,(de) 										; get call address low in A
	inc 	de 											
	push 	de 											; save return address
	ld 		d,c 										; and put call address in de
	ld 		e,a 										
	jr 		CORE_MainLoop 								; go round again
;
;	Inline code ($00), followed by Z80 assembler, followed by JP (IX)
;	
CORE_DoInline:
	push 	de 											; go to (de) (3 cycles quicker than
	ret 												; two moves and a JP (IY)


;
;	Example definition (DUP)
;
;	defb 	0
;	ld 		b,(hl) 										; read TOS into BC - B is LSB, C is MSB
;	inc 	hl
;	ld 		c,(hl)
; 	dec 	hl
; 	dec 	hl 	 										; write LSB
;	ld 		(hl),c 								
;	dec 	hl 											; write MSB
;	ld 		(hl),b
; 	jp 		(ix) 										; return.
;