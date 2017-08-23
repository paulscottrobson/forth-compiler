; ***********************************************************************************
; ***********************************************************************************
;
;       Name:       memory.asm
;       Author:     Paul Robson (paul@robsons.org.uk)
;       Purpose:    Core Forth Library : memory access
;       Date:       23 August 2017.
;
; ***********************************************************************************
; ***********************************************************************************

; ***********************************************************************************
;
;                           Read 16 bit word, address TOS
;
; ***********************************************************************************

    align   boundary

word_ReadWord:                          ; [[@]]
    pop     hl                          ; address to read
    ld      a,(hl)                      ; low byte
    inc     hl
    ld      h,(hl)                      ; high byte
    ld      l,a                         ; make word
    push    hl                          ; stack and exit
    jp      (ix)

; ***********************************************************************************
;
;                           Read 8 bit byte, address TOS
;
; ***********************************************************************************

    align   boundary

word_ReadByte:                          ; [[C@]]
    pop     hl                          ; address to read
    ld      l,(hl)                      ; one byte only
    ld      h,0                         ; MSB 0
    push    hl                          ; stack and exit
    jp      (ix)

; ***********************************************************************************
;
;                   Write 16 bit word, address TOS data 2nd
;
; ***********************************************************************************

    align   boundary

word_WriteWord:                         ; [[!]]
    exx                                 ; alt register set
    pop     hl                          ; address to write
    pop     de                          ; data to write
    ld      (hl),e                      ; write LSB
    inc     hl
    ld      (hl),d                      ; write MSB
    jr      __libm_exxAndExit           ; switch registers back and exit

; ***********************************************************************************
;
;                   Write 8 bit byte, address TOS data 2nd
;
; ***********************************************************************************

    align   boundary

word_WriteByte:                         ; [[C!]]
    exx                                 ; alt register set
    pop     hl                          ; address to write
    pop     de                          ; data to write
    ld      (hl),e                      ; write LSB
__libm_exxAndExit:                      ; exit routine, exx and exit where needed.
    exx                                 ; original register set                        
    jp      (ix)    

; ***********************************************************************************
;
;                           Add 2nd word to memory at TOS
;
; ***********************************************************************************

    align   boundary

word_AddStore:                          ; [[+!]]
    exx                                 ; alt register set
    pop     hl                          ; address to write
    pop     de                          ; data to add
    ld      a,e                         ; do LSB
    add     (hl)
    ld      (hl),a                      ; do MSB
    ld      a,d
    adc     (hl)
    ld      (hl),a
    exx                                 ; original set and exit
    jp      (ix)
