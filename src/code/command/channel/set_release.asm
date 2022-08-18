; =============== S U B	R O U T	I N E =======================================


SetRelease:				; CODE XREF: YM2_ParseChannel6Data+8Fp
					; PSG_ParseToneData+63p
					; PSG_ParseNoiseData+56p
		inc	de		; point	to next	byte
		ld	a, (de)		; get next byte

loc_FBC:				; CODE XREF: YM_SetSlideOrKeyRelease+Ej
		ld	c, a
		and	80h ; '�'
		ld	(ix+8),	a	; bit 7	goes to	channel	data byte 8
		ld	a, c
		and	7Fh ; ''
		ld	(ix+6),	a	; bits 6-0 go to channel data byte 6
		inc	de		; point	to next	byte
		ret
; End of function SetRelease