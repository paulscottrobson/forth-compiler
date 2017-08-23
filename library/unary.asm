; ***********************************************************************************
; ***********************************************************************************
;
;       Name:       unary.asm
;       Author:     Paul Robson (paul@robsons.org.uk)
;       Purpose:    Core Forth Library : unary operators
;       Date:       23 August 2017.
;
; ***********************************************************************************
; ***********************************************************************************

; ***********************************************************************************
;
;							Add 1 to the Top of the Stack
;
; ***********************************************************************************

    align   boundary

word_add1:                              ; [[1+]]
    pop     hl 
__libu_incHLAndPush:
    inc     hl
    jr      __libu_pushHLExit

; ***********************************************************************************
;
;							Add 2 to the Top of the Stack
;
; ***********************************************************************************

    align   boundary

word_add2:                              ; [[2+]]
    pop     hl 
    inc     hl
    jr      __libu_pushHLExit

; ***********************************************************************************
;
;						Subtract 1 from the Top of the Stack
;
; ***********************************************************************************

    align   boundary

word_sub1:                              ; [[1-]]
    pop     hl 
__libu_decHLAndPush:    
    dec     hl
    jr      __libu_pushHLExit

; ***********************************************************************************
;
;						Subtract 2 from the Top of the Stack
;
; ***********************************************************************************

    align   boundary

word_sub2:                              ; [[2-]]
    pop     hl 
    dec     hl
    jr      __libu_pushHLExit

; ***********************************************************************************
;
;						Shift left / Double the Top of the Stack
;
; ***********************************************************************************

    align   boundary

word_shiftleft:                         ; [[2*]]
    pop     hl 
    add     hl,hl
    jr      __libu_pushHLExit

; ***********************************************************************************
;
;				Arithmetic shift right / Halve the Top of the Stack
;
; ***********************************************************************************

    align   boundary

word_shiftright:                        ; [[2/]]
    pop     hl 
    sra     h 							; shift h right into carry
    rr      l 							; rotate l right from carry
__libu_pushHLExit:
    push    hl 							; push on stack and exit
    jp      (ix)

; ***********************************************************************************
;
;							Negate the top of the stack.
;
; ***********************************************************************************

    align   boundary

word_negate:                            ; [[0-]]
    exx                                 
    pop     de                          ; values to subtract
    xor 	a 							; clear A and carry
    ld 		l,a 						; use that to zero HL
    ld 		h,a
    sbc 	hl,de 						; calculate 0-value
    push    hl 							; push on stack and exit
    jp      (ix)

