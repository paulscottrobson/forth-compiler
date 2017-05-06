
    include "sna_header.asm"

start:
    ld  b,0
loop2:
    ld  hl,0x4000
    ld  de,0x5800
loop1:
    ld      a,b
    ld      (hl),a
    ld      (de),a
    inc     e
    inc     l    
    jr nz,     loop1
    inc     h
    inc     d
    ld      a,h
    cp      0x58
    jr      nz,loop1
    ld      c,0
wait1:
    dec     c
    jr      nz,wait1
    inc     b
    jp      loop2
    
