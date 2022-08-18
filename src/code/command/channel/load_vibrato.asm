; =============== S U B	R O U T	I N E =======================================


LoadVibrato:				; CODE XREF: YM1_ParseData+A6p
					; YM2_ParseData+D4p
					; PSG_ParseToneData+6Dp
		inc	de		; affects channel ram bytes 09,	0B and 0C
		ld	a, (de)		; get next parameter : $2C
		push	af
		rra
		rra
		rra
		and	1Eh		; keep nibble 1	only, multiplied by 2 -> $04
		ld	hl, pt_PITCH_EFFECTS ; The pitch effects mostly	are vibratos, but also effects that make pitch go up or	down indefinitely
		ld	b, 0
		ld	c, a
		add	hl, bc		; point	to the corresponding pointer
		ld	a, (hl)
		inc	hl
		ld	h, (hl)
		ld	(ix+0Bh), a
		ld	a, h
		ld	(ix+0Ch), a	; channel ram bytes B-C	= 4th pointer
		pop	af
		rla
		and	1Eh		; get nibble 2 only, multiplied	by 2 ->	$18
		jr	z, loc_FEA
		dec	a		; $17

loc_FEA:				; CODE XREF: LoadVibrato+1Dj
		ld	(ix+9),	a
		inc	de
		ret
; End of function LoadVibrato