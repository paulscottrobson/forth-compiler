


;
;		BC points to current word
;		DE points to return stack
; 		
; 		00-7F  		call routine at $8000+n * 4
; 		80-FF xx 	call routine in upper memory.
; 


		
		ld 		ix,NextWord 						; we can do the next with JP (IX)
NextWord:
		ld		a,(bc) 								; read first byte.
		add 	a,a 								; shift bit 7 into carry
		jr 		c,CallCode 							; if bit 7 set it is a call.

		inc 	bc 									; skip it
		ld	 	l,a 								; 2 x code into L
		ld 		h,0x80 / 2 							; half of $8000 into H
		add 	hl,hl 								; HL = $8000 + code x 4
		jp 		(hl) 								; go there.

CallCode:
		ld 		a,(bc) 								; read address into HL
		inc 	bc
		ld 		h,a
		ld 		a,(bc)
		inc 	bc
		ld 		l,a
		jp 		(hl)								; and go execute there.