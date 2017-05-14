; ****************************************************************************************************
; ****************************************************************************************************
;
;													Core v4
;
; ****************************************************************************************************
; ****************************************************************************************************

Core_reset:									; <<reset>>

	ld 		ix,Core_Continue  				; these allow us to do fast jumps in and out of routines.
	ld 		iy,Core_Call 					; also saving a byte on long jumps.

	ld 		sp,<top of number stack> 		; sp is the data stack (works down)
	ld 		bc,<bottom of returns stack> 	; bc is the return stack (works up)
	ld 		hl,<start of word to execute>	; hl is the IP (except when executing Z80 code words)
	
	jr 		Core_Execute

; ****************************************************************************************************
;
;		The JP (IY) at the start of a threaded definition comes here. DE contains
; 		the old address, HL the new one.
;
;		Save the calling address on the stack and execute from HL. Which handily is in HL.
;
; ****************************************************************************************************

Core_Call:
	inc 	hl 								; advance HL over the JP(IY) $FD $E9
	inc 	hl 								; now points to the first definition

	ld 		e,a 							; push DE (old address) on the BC stack.
	inc 	bc 								; unfortunately a Z80 only has one stack, so we have
	ld 		(bc),a 							; to use it for either data *or* return.
	ld 		d,a
	inc 	bc
	ld 		(bc),a

	ex 		de,hl 							; allows us to fall through to execute loop

; ****************************************************************************************************
;
;	Ending a machine code definition comes here (using JP (IX)). We need this exchange
; 	because when running m/c definition DE is the instruction pointer
;
; ****************************************************************************************************

Core_Continue:
	ex 		de,hl 							; if executing code word come back here.

; ****************************************************************************************************
;
;					Main execution entry point. Execute instruction at (DE)
;
; ****************************************************************************************************

Core_Execute:
	ld 		e,(hl)							; read address of next word at HL into DE, LSB first
	inc 	hl
	ld 		d,(hl)
	inc 	hl
	ex 		de,hl 							; swap so when executing code word DE code ptr and so we can 
	jp 		(hl) 							; do this 4 cycle jump

; ****************************************************************************************************
;
;											16 bit literal word
;
; ****************************************************************************************************

WORD_Literal:								; <<.literal>>
	ex 		de,hl 							; HL now contains the IP back again.
	ld 		e,(hl) 							; load next word into DE
	inc 	hl
	ld 		d,(hl)
	inc 	hl
	push 	de 								; push word on data stack
	jr 		Core_Execute 					; and execute without doing the DE/HL swap

; ****************************************************************************************************
;
;												Return word.
;
; ****************************************************************************************************

Example_Return:								; <<;>>
	ld 		a,(bc) 							; pop address into DE.
	inc 	bc
	ld 		d,a 
	ld 		a,(bc)
	inc 	bc
	ld 		e,a
	jp 		(ix) 							; this will put DE -> HL and start executing one level up.

; ****************************************************************************************************
;
;												Examples
;
; ****************************************************************************************************

;
;	Code word (example) DUP. Note that in code words DE is the code pointer.
;	We just go straight in with the machine code. Code words can only use HL as a temporary value
; 	so for things like + use EXX and do it in the alternate set.
;

dup:										; <<dup>>
	pop 	hl
	push 	hl
	push 	hl
	jp		(ix)							; and fix up so HL is the code pointer again and loop


;
;	Word built up out of other definitions.
;	
	jp 		(iy)							; identifies as a word from words.

	; first def addr
	; second def addr
	;	..
	;	..

	defw 	Core_Return 					; now we want to go back.
