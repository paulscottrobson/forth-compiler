; ***********************************************************************************
; ***********************************************************************************
;
;       Name:       system.asm
;       Author:     Paul Robson (paul@robsons.org.uk)
;       Purpose:    Core Forth Library : system words
;       Date:       23 August 2017.
;
; ***********************************************************************************
; ***********************************************************************************

; ***********************************************************************************
;
;  0BR : Branch to the address given in the following two bytes if TOS = 0, drops TOS
;
; ***********************************************************************************

    align   boundary

word_0br:                               ; [[[0BR]]]
    pop     hl                          ; get TOS
    ld      a,h                         ; check if zero
    or      l 
    jr      z,word_Br                   ; if it is execute [BR] unconditional branch
    inc     bc                          ; if non zero skip over branch address    
    inc     bc
    jp      (ix)                        ; exit

; ***********************************************************************************
;
;   BR : Unconditional Branch to the address given in the following two bytes
;
; ***********************************************************************************

    align   boundary

word_Br:                                ; [[[BR]]]
    ld      a,(bc)                      ; read next word in low high order into BC
    ld      l,a                         ; temp store for LSB
    inc     bc                  
    ld      a,(bc)                      ; read MSB
    ld      b,a                         ; put into BC
    ld      c,l                         
    jp      (ix)                        ; exit

; ***********************************************************************************
;
;               Push 2 byte literal in the following 2 bytes on the stack
;
; ***********************************************************************************

    align   boundary

word_literal:                           ; [[[LIT]]]
    ld      a,(bc)                      ; read literal from next byte LSB first
    inc     bc
    ld      l,a
    ld      a,(bc)                      ; then MSB
    inc     bc
    jr      __libs_pushALAndExit

; ***********************************************************************************
;
;                  Push 1 byte literal (0-255) unsigned on the stack
;
; ***********************************************************************************

    align   boundary

word_shortunsignedliteral:              ; [[[USHORTLIT]]]
    ld      a,(bc)                      ; read literal from next byte LSB first
    inc     bc
    ld      l,a
    xor     a                           ; zero A
__libs_pushALAndExit:    
    ld      h,a                         ; put A in H
    push    hl                          ; stack it
    jp      (ix)                        ; and exit.
