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

    include     "system.asm"
    include     "constants.asm"
    include     "unary.asm"
    include     "binary.asm"    
    include     "memory.asm"
    include     "rstack.asm"
    include     "conditional.asm"    
    include     "stack.asm"

; = > < >= <= <> (not initially)
; sp@ * 
