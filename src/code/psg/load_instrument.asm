; =============== S U B	R O U T	I N E =======================================


PSG_LoadInstrument:			; CODE XREF: PSG_ParseToneData+59p
					; PSG_ParseNoiseData+4Cp
		inc	de		; load psg instrument x	at level y
		ld	a, (de)
		ld	c, a
		and	0Fh		; keep only nibble 2 : instrument level
		ld	b, a
		ld	a, (iy+0)
		cp	2		; if it's PSG Tone 3 Channel
		jr	z, loc_E5E	; load instrument level
		ld	a, (CURRENTLY_FADING_OUT) ; set	to 01 when a fade out operation	is being executed
		or	a
		jr	nz, loc_E61	; don't jump if 0, so load new level

loc_E5E:				; CODE XREF: PSG_LoadInstrument+Bj
		ld	(ix+4),	b	; if it's PSG Tone 3 channel, keep nibble 2 in byte 04

loc_E61:				; CODE XREF: PSG_LoadInstrument+11j
		ld	a, c		; get back full	byte
		rra
		rra
		rra
		rra
		and	0Fh		; get psg instrument index
		inc	de
		ld	h, 0
		ld	l, a
		add	hl, hl
		ld	bc, pt_PSG_INSTRUMENTS ; The PSG instruments only affect the channel level
		add	hl, bc
		ld	c, (hl)
		inc	hl
		ld	b, (hl)
		ld	(ix+10h), c	; get instrument pointer
		ld	(ix+11h), b
		ret
; End of function PSG_LoadInstrument