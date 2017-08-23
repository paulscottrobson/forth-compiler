; ***********************************************************************************
; ***********************************************************************************
;
;       Name:       rstack.asm
;       Author:     Paul Robson (paul@robsons.org.uk)
;       Purpose:    Core Forth Library : return stack words
;       Date:       23 August 2017.
;
; ***********************************************************************************
; ***********************************************************************************

; ***********************************************************************************
;
;                                       Return from call
;
; ***********************************************************************************

    align   boundary

word_Return:                            ; [[;]]
    ld      a,(de)                      ; pop DE stack to BC
    ld      c,a                         ; LSB first
    inc     de
    ld      a,(de)                      ; then MSB
    ld      b,a
    jp      (ix)    

; ***********************************************************************************
;
;                       Move top of return stack to data stack
;
; ***********************************************************************************

    align   boundary

word_returnToData:                      ; [[R>]]
    ld      a,(de)                      ; pop DE stack to HL
    ld      l,a                         ; LSB first
    inc     de
    ld      a,(de)                      ; MSB second
    ld      h,a
    inc     de
    push    hl                          ; push on data stack
    jp      (ix)                        ; exit

; ***********************************************************************************
;
;                               Drop top of return stack
;
; ***********************************************************************************

    align   boundary

word_dropReturn:                        ; [[RDROP]]
    inc     de                          ; pop 2 bytes off.
    inc     de
    jp      (ix)                        ; exit

; ***********************************************************************************
;
;                       Mote top of data stack to return stack
;
; ***********************************************************************************

    align   boundary

word_dataToReturn:                      ; [[>R]]
    pop     hl                          ; value to save
    dec     de                          ; MSB first
    ld      a,h
    ld      (de),a
    dec     de                          ; LSB second
    ld      a,l
    ld      (de),a
    jp      (ix)
