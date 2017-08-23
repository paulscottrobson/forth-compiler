; ***********************************************************************************
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

