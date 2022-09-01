; =============== S U B	R O U T	I N E =======================================


LoadDacSample:				; CODE XREF: Main_Loop+1Cp
		cp	0FEh ; '�'
		jr	nz, loc_1A0	; if a != FE
		ld	hl, 0C000h	; if a = FE, play nothing
		ld	de, 0		; 0 remaining length, so just stay in the main loop
		ret
; ---------------------------------------------------------------------------

loc_1A0:				; CODE XREF: LoadDacSound+2j
		dec	a		; a is DAC sound index,	starting at 1, so decrement it
		ld	h, 0
		ld	l, a
		add	hl, hl
		add	hl, hl
		add	hl, hl		; hl = 8 * a, so each DAC sound	entry uses 8 bytes
		ld	bc, PCM_SAMPLE_ENTRIES
		add	hl, bc		; hl now points	to the right entry
		ld	a, (hl)		; get byte 0 : time period used
		inc	hl		; ignore byte 1	!
		inc	hl		; point	to byte	2 : bank to load
		ld	(DacLoop+1), a	; change loop number to	change DAC play	time period
		ld	a, (hl)		; get byte 2
		ld	(DAC_BANK), a ; save byte 2
		inc	hl		; ignore byte 3	!
		inc	hl
		ld	e, (hl)
		inc	hl
		ld	d, (hl)		; de = bytes 5-4 : sound length
		inc	hl
		ld	a, (hl)		; 7th byte
		inc	hl
		ld	h, (hl)		; 8th byte
		ld	l, a		; hl = bytes 7-6 : sound data pointer
		xor	a
		ld	(NEW_SAMPLE), a	; clear	to say that DAC	sound is now loaded
		ld	a, (DAC_BANK)
		call	LoadBank	; loads	bank 0x1E0000 or 0x1E8000
		ret
; End of function LoadDacSound