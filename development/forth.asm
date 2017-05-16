; ****************************************************************************************************
;
;									Forth Compiler Runtime
;
; ****************************************************************************************************

	include 	"sna_header.asm"			; .SNA boot header
	include 	"core4.asm" 				; Forth core (Direct Threaded)
	include 	"library.asm" 				; Basic FORTH words including optional text/sprite stuff

BootWord:
	jp 			(iy)
	defw 		WORD_ClearScreen
	defw 		WORD_Star
	defw 		WORD_Test
	defw 		WORD_Star
	defw 		WORD_Stop

WORD_Star:
	jp 			(iy)
	defw 		Core_Literal
	defw 		42
	defw 		WORD_Emit
	defw 		Core_Return

EndOfCode:

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



