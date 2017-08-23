; ***********************************************************************************
; ***********************************************************************************
;
;       Name:       conditional.asm
;       Author:     Paul Robson (paul@robsons.org.uk)
;       Purpose:    Core Forth Library : conditional operators, true and false
;       Date:       23 August 2017.
;
; ***********************************************************************************
; ***********************************************************************************

; ***********************************************************************************
;
;                               check if TOS = 0
;
; ***********************************************************************************

    align   boundary

word_0Equal:                            ; [[0=]]
    pop     hl                          ; get value
__util_testzero:    
    ld      a,h                         ; check if zero
    or      l
    jr      z,word_ConstMinus1          ; if is, return -1
    jr      word_ConstZero

; ***********************************************************************************
;
;                               check if TOS < 0
;
; ***********************************************************************************

    align   boundary

word_0Less:                             ; [[0<]]
    pop     hl                          ; get value
    bit     7,h                         ; check sign bit
    jr      nz,word_ConstMinus1         ; if is set, return -1
    jr      word_ConstZero

; ***********************************************************************************
;
;                               check if TOS > 0
;
; ***********************************************************************************

    align   boundary

word_0Greater:                          ; [[0>]]
    pop     hl                          ; get value
    bit     7,h                         ; check sign bit
    jr      nz,word_ConstZero           ; if is set, return 0 as it's negative
    ld      a,h                         ; if not check if zero
    or      l
    jr      z,word_ConstZero            ; if it is, return 0.
    jr      word_ConstMinus1            ; return -1 as > 0

; ***********************************************************************************
;
;                               -1 constant also true
;
; ***********************************************************************************

    align   boundary

word_ConstMinus1:                       ; [[-1]]
word_true:                              ; [[true]]
    ld      hl,-1
    push    hl
    jp      (ix)

; ***********************************************************************************
;
;                               0 constant also false
;
; ***********************************************************************************

    align   boundary

word_ConstZero:                         ; [[0]]
word_false:                             ; [[false]]
    ld      hl,0
    push    hl
    jp      (ix)
