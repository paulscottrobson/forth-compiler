; ***********************************************************************************
; ***********************************************************************************
;
;       Name:       stack.asm
;       Author:     Paul Robson (paul@robsons.org.uk)
;       Purpose:    Core Forth Library : stack words
;       Date:       23 August 2017.
;
; ***********************************************************************************
; ***********************************************************************************

; ***********************************************************************************
;
;                       ?dup : duplicate TOS if non-zero
;
; ***********************************************************************************

    align   boundary

word_QDup:                              ; [[?dup]]
    pop     hl                          ; examine TOS
    push    hl                          ; don't drop it - just check it.
    ld      a,h                         ; check if zero.
    or      l
    jr      nz,word_Dup                 ; if not, do DUP
    jp      (ix)                        ; otherwise exit.

; ***********************************************************************************
;
;                                   Duplicate TOS
;
; ***********************************************************************************

    align   boundary

word_Dup:                               ; [[dup]]
    pop     hl                          ; get tos
    push    hl                          ; push twice
    push    hl
    jp      (ix)                        ; otherwise exit.

; ***********************************************************************************
;
;                                       Drop TOS
;
; ***********************************************************************************

    align   boundary

word_Drop:                              ; [[drop]]
    pop     hl                          ; dump tos
    jp      (ix)

; ***********************************************************************************
;
;                               Swap top 2 values on stack
;
; ***********************************************************************************

    align   boundary

word_Swap:                              ; [[swap]]
    exx                                 ; alt register set
    pop     de                          ; get values
    pop     hl                      
    push    de                          ; write back in the other order.
    push    hl
__libs_exxAndExit:    
    exx
    jp      (ix)

; ***********************************************************************************
;
;                       Copy 2nd on stack onto top of stack
;
; ***********************************************************************************

    align   boundary

word_Over:                              ; [[over]]
    exx                                 ; alt register set
    pop     de                          ; get values
    pop     hl                      
    push    hl                          ; write back
    push    de
    push    hl                          ; push the 2nd value on top.
    jr      __libs_exxAndExit           ; exx and exit.

; ***********************************************************************************
;
;                           Rotate the top 3 stack values
;
; ***********************************************************************************

    align   boundary

word_Rot:                               ; [[rot]]
    exx
    pop     bc                          ; BC = TOS
    pop     de                          ; DE = 2nd
    pop     hl                          ; HL = 3rd

    push    de                          ; 2nd to the bottom
    push    bc                          ; tos on that
    push    hl                          ; and the 3rd item moves to the top
    exx
    jp      (ix)

; ***********************************************************************************
;
;                           Pick the nth value on the stack
;
; ***********************************************************************************

    align   boundary

word_Pick:                              ; [[pick]]
    exx                                 ; need all registers
    ld      sp,hl                       ; put stack pointer in HL.
    pop     de                          ; this is the index into the stack
    add     hl,de                       ; add 2 x to the stack, now points to low value
    add     hl,de
    ld      e,(hl)                      ; read low byte
    inc     hl
    ld      d,(hl)                      ; read high byte
    push    de                          ; push read value onto the stack
    jr      __libs_exxAndExit           ; exx and exit.
