; ****************************************************************************************************
;
;						Constants, quicker and shorter versions of .literal
;
; ****************************************************************************************************

ConstantWord macro value
	ld 		hl,&value 						; <<&value>>
	push 	hl
	jp 		(ix)
	endm
;
;	If you use these (which the compiler does automatically) it saves two bytes over .literal [n]
;	and also is several cycles quicker, because it doesn't fetch the value. A similar system is
;	used for variables/arrays/constants as these are all 6 bytes long (same as .literal [n] return)
;
	ConstantWord 	-1
	ConstantWord 	0	
	ConstantWord 	1
	ConstantWord 	2
	ConstantWord 	4
	ConstantWord 	8
	ConstantWord 	10
	ConstantWord 	16
	ConstantWord 	100
	ConstantWord 	256

