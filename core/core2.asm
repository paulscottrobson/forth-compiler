

CORE_MainLoop:
	ld 		a,(bc) 												; read next instruction
	ld 		d,a 												; save in D
	inc 	bc
	add 	a,a 												; shift A left, bit 7 -> C
	jr 		nc,CORE_LowCode 									; 00-7F is low memory code.
;
;	Read 80-FF. A contains this value x 2, D contains the original value
;
	ld 		a,(bc) 												; get low value into A
	inc 	bc	
	push 	bc 													; save return address
	ld 		c,a 												; set up BC with new address 
	ld 		b,d
	jr 		CORE_MainLoop 										; and execute again.
;
;	Read 00-7F. A contains this value x 2. Does a jump to $8000+x * 8, but the stack is 
;	in DE *NOT* HL where it should be. M/C routines should fix this up.
;
CORE_LowCode: 
	ld  	e,a 												; on entry A = low value x 2
	ld 		d,020h 												; DE = low value x 2 + 20h
	ex 		de,hl 												; data stack pointer in DE, $20 <lowx2> in HL
	add 	hl,hl 												; $40 <low x 4> in HL
	add 	hl,hl 												; $80 <low x 8> in HL
	jp 		(hl) 												; execute low code.

;
;	Return 
;
	pop 	bc 													; restore return address
	ex 		de,hl 												; fix up data stack pointer
	jr 		CORE_MainLoop

;
;	2 byte literal push
;
	ex 		de,hl  												; HL is stack again.
	ld 		a,(bc) 												; get MSB
	inc 	bc
	dec 	hl
	ld 		(hl),a
	ld 		a,(bc)
	inc 	bc
	dec 	hl
	ld 		(hl),a
	jr 		CORE_MainLoop
;
;	2 byte constant.
;
	dec 	hl
	ld 		(hl),n
	