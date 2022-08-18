; =============== S U B	R O U T	I N E =======================================


PSG_GetInstrumentPointer:		; CODE XREF: PSG_ParseToneData:loc_D91p
					; PSG_ParseToneData:loc_DE2p
					; PSG_ParseNoiseData+B7p
					; PSG_ParseNoiseData:loc_F78p
		ld	a, (ix+11h)
		ld	h, a
		ld	a, (ix+10h)	; bytes	10-11 :	pointer
		ld	l, a
		ld	b, 0
		ld	a, (ix+12h)	; byte 12 : relative pointer to	add to 10-11 pointer
		ld	c, a
		add	hl, bc
		ret
; End of function PSG_GetInstrumentPointer