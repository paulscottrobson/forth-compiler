; *****************************************************************************************
; *****************************************************************************************
;
;                       SNA Header - variant of the provided example.
;
; *****************************************************************************************
; *****************************************************************************************

#target sna

; *****************************************************************************************
;
;                               saved registers, restored in NMI
;
; *****************************************************************************************

#code HEAD, 0, 27
    defb    $3f             ; i
    defw    0               ; hl'
    defw    0               ; de'
    defw    0               ; bc'
    defw    0               ; af'

    defw    0               ; hl
    defw    0               ; de
    defw    0               ; bc
    defw    0               ; iy
    defw    0               ; ix

    defb    0<<2            ; bit 2 = iff2 (iff1 before nmi) 0=di, 1=ei
    defb    0,0,0           ; r,f,a
    defw    __stackEnd      ; sp
    defb    1               ; irpt mode
    defb    0               ; border color: 0=black ... 7=white

; *****************************************************************************************
;
;                   $4000-$7FFF. Pixel Memory, Attribute Memory, Slow RAM
;
; *****************************************************************************************

#code SLOW_RAM, 0x4000, 0x4000

VideoMemory:
    defs    0x1800
AttributeMemory:
    defs    0x300
EndVideoMemory:
;
;   Boot. We fill video RAM with random stuff just so we know we are working.
;
__bootSNA:
    ld      hl,VideoMemory
__setupAttribute:
    ld      a,r
    ld      (hl),a
    inc     hl
    ld      a,h
    cp      EndVideoMemory/256
    jr      nz,__setupAttribute
    jp      start


; *****************************************************************************************
;
;                            $8000-$FFFF. Non contentious memory
;
; *****************************************************************************************



__stackEnd:   
    defw    __bootSNA

#code FAST_RAM, 0x8000, 0x8000



