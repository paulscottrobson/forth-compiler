; *****************************************************************************************
;
;		$00 		<code> 			inline code
;		$01-$7F 	<byte>			15 bit unsigned value from $0000 - $7E00 (the MSB is reduced by 1)
;		$80-$FF 	<byte> 			call a routine at this address (in fast memory)
;
;		BC 		top of stack value
;		DE 		work register
;		HL 		threaded code pointer
; 		IX 		data stack. IX+0 (low), IX+1 (high) is the 2nd stack value, grows down so IX+2,IX+3 is
;	 			the third stack value.
;		SP 		return addresses pushed here.
;
; *****************************************************************************************


; *****************************************************************************************
;
;				Return from a routine, pop the return address off the stack.
;
; *****************************************************************************************

CORE_Return:
	pop 	hl 													; pop return address off the stack.

; *****************************************************************************************
;
;									Main execution Loop
;
; *****************************************************************************************

CORE_MainLoop:
	ld 		a,(hl) 												; get the next command
	inc 	hl 													; bump over it.
	or 		a 													; if $00, then execute in line.
	jz 		CORE_ExecuteInLine
	jp		p,CORE_UnsignedInteger 								; if $01-$7F then an unsigned integer
;
;	Call routine. Gets the address ($8000-$FFFF), pushes return address on stack and executes
;	from new address.
;
	ld 		e,(hl) 												; get the LSB
	inc 	hl
	push 	hl 													; save return address on stack.
	mov 	l,e 												; set HL to point to that address
	mov 	h,a 										
	jr 		CORE_MainLoop

; *****************************************************************************************
;
;	Execute in line from (DE). It will do a RETURN when you do a ret instruction in Z80 code.
;
;	It is primarily for all-Z80 instructions. The sequence 00 C9 is 'Return' (e.g. ;)
;
; *****************************************************************************************

CORE_ExecuteInLine:
	ld 		de,CORE_Return 										; push CORE_Return on stack so come back here
	push 	de
	jp 		(hl) 												; and execute the code from then on.

; *****************************************************************************************
;
;	Push an unsigned integer on the stack. The old TOS value in BC is saved on the stack, and
;	the new value, is put in BC. 
;
; *****************************************************************************************

CORE_PushUnsigned:
	dec 	ix													; push the old TOS value onto the stack
	dec 	ix	
	ld 		(ix+0),c
	ld 		(ix+1),b
	dec 	a 	
	ld 		b,a 												; and put as MSB in B
	ld 		a,(hl) 												; get LSB
	inc 	hl
	ld 		c,a 												; and put as LSB in C
	jr 		CORE_MainLoop 										; do the next word.

