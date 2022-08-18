; =============== S U B	R O U T	I N E =======================================


YM_SetSlideOrKeyRelease:		; CODE XREF: YM1_ParseData+9Cp
					; YM2_ParseData+CAp
		inc	de
		ld	a, (de)		; get parameter
		cp	0FFh
		jr	nz, loc_FAF	; if parameter != $FF
		xor	a		; if parameter = $FF, clear channel byte 1F
		ld	(ix+1Fh), a
		inc	de
		ret
; ---------------------------------------------------------------------------

loc_FAF:				; CODE XREF: YM_SetSlideOrKeyRelease+4j
		cp	81h ; '�'
		jr	c, loc_FBC	; jump if a < 81
		and	7Fh ; ''
		ld	(ix+1Fh), a	; else,	put bits 6-0 in	channel	ram byte 1F
		inc	de
		ret
; End of function YM_SetSlideOrKeyRelease