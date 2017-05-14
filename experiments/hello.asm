
    include "sna_header.asm"

start:
    ld      b,0x80
loop2:
    jr      loop2
    ld      hl,0x4000
loop1:
    ld      a,b
    ld      (hl),a
    inc     l    
    jr nz,  loop1
    inc     h
    ld      a,h
    cp      0x58
    jr      nz,loop1
    ld      c,0
wait1:
    dec     c
    jr      nz,wait1
    inc     b
    jp      loop2
    
