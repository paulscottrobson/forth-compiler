; ***********************************************************************************
; ***********************************************************************************
;
;       Name:       library.asm
;       Author:     Paul Robson (paul@robsons.org.uk)
;       Purpose:    Core Forth Library : main file.
;       Date:       23 August 2017.
;
; ***********************************************************************************
; ***********************************************************************************

    org     0x8000

boundary = 4


; = > < >= <= <> (not initially)
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
    jp      (ix)                        ; and exit.; ***********************************************************************************
; ***********************************************************************************
;
;       Name:       constants.asm
;       Author:     Paul Robson (paul@robsons.org.uk)
;       Purpose:    Core Forth Library : constants
;       Date:       23 August 2017.
;
; ***********************************************************************************
; ***********************************************************************************


coreconst macro #value
	ld 		l,#value					; [[#value]]
	jr 		__libc_const
	endm

	coreconst 1 						; constants that are run fast and compact.
	coreconst 2 						; any here (and 0/-1) won't use literal words
	coreconst 3
	coreconst 4
	coreconst 5
	coreconst 8
	coreconst 10
	coreconst 16
	coreconst 100

__libc_const:
	ld 		h,0 						; HL now constant
	push 	hl 							; push on stack
	jp 		(ix) 						; exit
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
    jr      __libb_pushHLExxAndExit     ; push result and exit; ***********************************************************************************
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
    jp      (ix); ***********************************************************************************
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
    jp      (ix); ***********************************************************************************
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
    jp      (ix); ***********************************************************************************
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