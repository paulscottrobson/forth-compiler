; ****************************************************************************************************
;
;								 Basic FORTH Library, Z80 Assembler
;
; ****************************************************************************************************

;
;	over rot pick
;	1+ 1- 2+ 2- 2* 16* 256* 2/ 16/ 256/ 0= 0- 0< 
;	br bz bpl r> >r rdrop
;
	include "library/binary.asm"
	include "library/unary.asm"
	include "library/constants.asm"
	include "library/stack.asm"
	include "library/io.asm"
	include "library/misc.asm"


