; =============== S U B	R O U T	I N E =======================================


LoadNoteShift:				; CODE XREF: YM1_ParseData+BAp
					; YM2_ParseData+E8p
					; PSG_ParseToneData+87p
		inc	de
		ld	a, (de)
		and	8Fh ; '�'
		bit	7, a
		jr	z, loc_1029
		or	0F0h ; '�'

loc_1029:				; CODE XREF: LoadNoteShift+6j
		ld	(ix+1Ch), a	; byte 1C = 0x or Fx depending on byte 7 : value of note shift
		ld	a, (de)
		rrca
		rrca
		rrca
		and	0Eh		; just keep bytes 6-5-4	multiplied by 2
		ld	(ix+1Dh), a	; value	of frequeny shift
		inc	de
		ret
; End of function LoadNoteShift