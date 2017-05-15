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

WORD_Rot:									; <<rot>>
	exx
	pop 	hl 								; X3  X1 X2 X3 -> X2 X3 X1
	pop 	de 								; X2 
	pop		bc 								; X1
	push 	de
	push 	hl
	push 	bc
	exx
	jp 		(ix)

WORD_Pick:									; <<pick>>
	exx 		
	pop 	hl 								; get the index off the stack
	add 	hl,sp 							; add stack offset
	ld 		d,(hl) 							; read stack value
	inc 	hl
	ld 		e,(hl)
	push 	de 								; push on the stack
	exx
	jp 		(ix)