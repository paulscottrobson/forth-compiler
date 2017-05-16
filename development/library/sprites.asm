; ****************************************************************************************************
;
;										16 x 16 Sprite Words
;
; ****************************************************************************************************

WORD_Test:
	push 		bc
	push 		de
	push 		ix
	call 		TSDraw
	pop 		ix
	pop 		de
	pop			bc
	jp 			(ix)

	include 	"utils/sprites16x16.asm"

; ****************************************************************************************************

TSDraw:
	call 	CopyAttributeToShadow
	ld 		ix,testSprite
TSLoop:
	call 	__DSDrawSprite
TSDelay:
	ld 		hl,1000
TSDelay1:
	dec 	hl
	ld 		a,h
	or 		l
	jr 		nz,TSDelay1
	call 	__DSDrawSprite
	inc 	(ix+0)
	inc 	(ix+1)
	ld 		a,(ix+1)
	cp 		160
	jr 		nz,TSLoop
	ld 		(ix+0),64
	ld 		(ix+1),32
	jr 		TSLoop

testSprite:
	defb 	67
	defb 	35		
	defb 	046h,0
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

