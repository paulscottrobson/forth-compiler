
	include 	"sna_header.asm"			; .SNA boot header
	include 	"core4.asm" 				; Forth core (Direct Threaded)
	include 	"library.asm" 				; Basic FORTH words
	include 	"screen.asm" 				; Screen I/O routines.


BootWord:
	jp 			(iy)
	defw 		WORD_ClearScreen
	defw 		WORD_Star
	defw 		WORD_Star
	defw 		WORD_Star
	defw 		WORD_MinusOne
	defw 		WORD_Zero
	defw 		WORD_One
	defw 		Core_Literal
	defw 		0x1234
	defw 		Core_Literal
	defw 		0xF00F
	defw 		WORD_Or	

	defw 		Core_Literal
 	defw 		13
	defw 		Core_Literal
 	defw 		0x4AC7

	defw 		WORD_PrintStack
	defw 		WORD_Drop
	defw 		WORD_Emit
	defw 		WORD_Star
	defw 		WORD_Stop

WORD_Star:
	jp 			(iy)
	defw 		WORD_FT
	defw 		WORD_Emit
	defw 		Core_Return

WORD_FT:
	jp 			(iy)
	defw 		Core_Literal
	defw 		42
	defw 		Core_Return


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
;
;dup:										; <<dup>>
;	pop 	hl
;	push 	hl
;	push 	hl
;	jp		(ix)							; and fix up so HL is the code pointer again and loop
;
;
;
;	Word built up out of other definitions.
;	
;	jp 		(iy)							; identifies as a word from words.
;
;	; first def addr
;	; second def addr
;	;	..
;	;	..
;
;	defw 	Core_Return 					; now we want to go back.
;



