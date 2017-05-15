; ****************************************************************************************************
;
;										  Stack Manipulation
;
; ****************************************************************************************************

WORD_Dup:									; <<dup>>
	pop 	hl 								; get TOS and push it back twice
	push 	hl
	push 	hl
	jp 		(ix) 							; return 

WORD_Drop:									; <<drop>>
	pop 	hl
	jp 		(ix)

WORD_Swap:									; <<swap>>
	exx 									; use alt register set
	pop 	hl 								; get TOS and push it back twice
	pop 	de
	push 	hl
	push 	de
	exx 
	jp 		(ix) 							; return 

WORD_Over:									; <<over>>
	exx 						
	pop 	hl 								; tos
	pop 	de 								; tos 2
	push 	de 								; push back
	push 	hl
	push 	de 								; with tos 2 on top
	exx
	jp 		(ix)