; ****************************************************************************************************
;
;										16 x 16 Sprite Words
;
; ****************************************************************************************************

	include 	"utils/sprites16x16.asm"

WORD_Test:
	push 		ix
	push 		iy
	call 		TSDraw
	pop 		iy
	pop 		ix
	jp 			(ix)

; ****************************************************************************************************

TSDraw:
	call 	CopyAttributeToShadow
	ld 		ix,testSprite
	ld 		hl,1000/2
TSLoop:
	push 	hl
	call 	DrawSprite
	call 	EraseSprite
	ld 		a,(ix+0)
	xor 	32
	ld 		(ix+0),a

	ld 		a,(ix+2)
	xor 	4
	ld 		(ix+2),a
	pop 	hl
	dec 	hl
	ld 		a,h
	or 		l
	jr 		nz,TSLoop
	ret

TSDelay:
	ld 		hl,1000
TSDelay1:
	dec 	hl
	ld 		a,h
	or 		l
	jr 		nz,TSDelay1
	inc 	(ix+0)
	inc 	(ix+1)
	ld 		a,(ix+1)
	cp 		160
	jr 		nz,TSLoop
	ld 		(ix+0),69
	ld 		(ix+1),33
	jr 		TSLoop

testSprite:
	defb 	67
	defb 	35		
	defb 	045h,0
	defw 	graphicData,0

graphicData:
	defb 	0FFh,0FFh
	defb 	0AAh,0AAh
	defb 	080h,003h
	defb 	080h,007h

	defb 	08Fh,00Fh
	defb 	080h,01Fh
	defb 	0FFh,0E0h
	defb 	002h,000h

	defb 	002h,000h
	defb 	007h,000h
	defb 	080h,001h
	defb 	080h,001h

	defb 	080h,001h
	defb 	080h,001h
	defb 	080h,001h
	defb 	0FFh,0FFh

