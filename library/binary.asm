; ***********************************************************************************
; ***********************************************************************************
;
;       Name:       binary.asm
;       Author:     Paul Robson (paul@robsons.org.uk)
;       Purpose:    Core Forth Library : binary operators
;       Date:       23 August 2017.
;
; ***********************************************************************************
; ***********************************************************************************

; ***********************************************************************************
;
;                               add top 2 values
;
; ***********************************************************************************

    align   boundary

word_add:                               ; [[+]]
    exx                                 ; need both registers
    pop     de                          ; values to add
    pop     hl
    add     hl,de                       ; add them.
__libb_pushHLExxAndExit:    
    push    hl                          ; save result
    exx                                 ; fix up registers
    jp      (ix)

; ***********************************************************************************
;
;                           Subtract 2nd value from first
;
; ***********************************************************************************

word_subtract:                          ; [[-]]
    exx                                 ; need both registers
    pop     de                          ; values to add
    pop     hl
__subtractAndSave:    
    and     a                           ; clear carry
    sbc     hl,de                       ; subtract them.
    jr      __libb_pushHLExxAndExit     ; push result and exit

; ***********************************************************************************
;
;                               and top 2 values
;
; ***********************************************************************************

    align   boundary

word_and:                               ; [[and]]
    exx                                 ; need both registers
    pop     de                          ; values to work with
    pop     hl
    ld      a,h                         ; do the operation
    and     d
    ld      h,a
    ld      a,l
    and     e
    ld      l,a
    jr      __libb_pushHLExxAndExit     ; push result and exit

; ***********************************************************************************
;
;                               or top 2 values
;
; ***********************************************************************************

    align   boundary

word_or:                                ; [[or]]
    exx                                 ; need both registers
    pop     de                          ; values to work with
    pop     hl
    ld      a,h                         ; do the operation
    or      d
    ld      h,a
    ld      a,l
    or      e
    ld      l,a
    jr      __libb_pushHLExxAndExit     ; push result and exit

; ***********************************************************************************
;
;                               xor top 2 values
;
; ***********************************************************************************

    align   boundary

word_xor:                               ; [[xor]]
    exx                                 ; need both registers
    pop     de                          ; values to work with
    pop     hl
    ld      a,h                         ; do the operation
    xor     d
    ld      h,a
    ld      a,l
    xor     e
    ld      l,a
    jr      __libb_pushHLExxAndExit     ; push result and exit
