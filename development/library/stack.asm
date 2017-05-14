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

