
	include 	"sna_header.asm"			; .SNA boot header
	include 	"core4.asm" 				; Forth core (Direct Threaded)
	include 	"screen.asm" 				; Screen I/O routines.

BootWord:
	jp 			(iy)
	defw 		WORD_ClearScreen
	defw 		WORD_Star
	defw 		WORD_Star
	defw 		WORD_Star
	defw 		WORD_Literal
 	defw 		0x4AC7
	defw 		WORD_PrintInteger
	defw 		WORD_Stop


WORD_Star:
	jp 			(iy)
	defw 		WORD_FT
	defw 		WORD_Emit
	defw 		WORD_Return

WORD_FT:
	jp 			(iy)
	defw 		WORD_Literal
	defw 		42
	defw 		WORD_Return

WORD_Emit:
	pop 	hl 								; get character to print in L
	call	PrintCharL
	jp 		(ix)

WORD_Add:
	exx 
	pop		hl
	pop 	de
	add 	hl,de
	push 	hl
	exx
	jp 		(ix)

WORD_Stop:
	jr 		WORD_Stop

WORD_Dup:
	pop 	hl 								; get TOS and push it back twice
	push 	hl
	push 	hl
	jp 		(ix) 							; return 

WORD_PrintInteger:
	ld 		l,' ' 							; print leading space
	call 	PrintCharL
	pop 	hl
	ld 		a,h
	call 	PrintByteA
	ld 		a,l
	call 	PrintByteA
	jp 		(ix)

WORD_Swap:
	exx 									; use alt register set
	pop 	hl 								; get TOS and push it back twice
	pop 	de
	push 	hl
	push 	de
	exx 
	jp 		(ix) 							; return 

WORD_ClearScreen:
	call 	ClearScreen
	call 	HomeCursor
	jp 		(ix)

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



