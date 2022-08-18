; =============== S U B	R O U T	I N E =======================================


YM2_LoadInstrument:			; CODE XREF: YM_UpdateInstrumentsLevels:loc_FAp
					; YM_UpdateInstrumentsLevels+4Cp
					; YM_UpdateInstrumentsLevels+56p
					; YM_UpdateInstrumentsLevels+6Fp
					; YM_UpdateInstrumentsLevels+82p
					; StopMusic+4Fp StopMusic+66p
					; StopMusic+7Dp YM2_ParseData+A0j
					; YM2_ParseData+A4j YM2_ParseData+BFp
					; YM2_ParseData+25Cj
					; YM2_ParseChannel6Data+84j
		push	af
		ld	a, YM_INSTRUMENTS_BANK
		call	LoadAnyBank
		pop	af
		ld	(ix+4),	a
		ld	a, (CURRENTLY_MANAGING_SFX) 
		or	a
		jr	z, loc_AB6
		ld	a, (ix+4)
		jr	loc_AC6
; ---------------------------------------------------------------------------

loc_AB6:				; CODE XREF: YM2_LoadInstrument+Aj
		ld	a, (FADE_OUT_COUNTER) ;	Counts how many	times the fade out timer reached 0. Fade out stops at value $0C.
		add	a, 0Fh
		ld	h, a
		ld	a, (MUSIC_LEVEL) ; general output level	for music and SFX type 1, sent from 68k
		add	a, (ix+4)
		sub	h
		jr	nc, loc_AC6
		xor	a

loc_AC6:				; CODE XREF: YM2_LoadInstrument+Fj
					; YM2_LoadInstrument+1Ej
		push	de
		push	af
		ld	a, (ix+10h)	; same as in YM1 version of subroutine,	load instrument	index etc...
		ld	l, a
		ld	h, 0
		ld	d, h
		ld	e, l
		add	hl, hl
		add	hl, hl
		push	hl
		add	hl, de
		ld	d, h
		ld	e, l
		add	hl, hl
		add	hl, hl
		add	hl, de
		pop	de
		add	hl, de
		ld	de, YM_INSTRUMENTS_BANK_OFFSET
		add	hl, de
		push	hl
		ld	de, 1Ch
		add	hl, de
		ld	a, (hl)
		and	7
		ld	(ix+5),	a
		pop	hl
		ld	a, (iy+0)
		add	a, 30h ; '0'
		ld	b, 4

loc_AF2:				; CODE XREF: YM2_LoadInstrument+59j
		push	bc
		ld	b, a
		ld	c, (hl)
		push	af
		call	YM2_ConditionalInput
		pop	af
		inc	hl
		add	a, 4
		pop	bc
		djnz	loc_AF2
		ld	(TEMP_REGISTER), a ; temp place	to keep	a register value when an YM instrument is loaded
		pop	af
		push	hl
		ld	d, 0
		ld	e, a
		ld	hl, t_YM_LEVELS
		ld	b, e
		add	hl, de
		ld	c, (hl)
		ld	e, (ix+5)
		ld	hl, t_SLOTS_PER_ALGO
		add	hl, de
		ld	d, (hl)
		ld	a, (TEMP_REGISTER) ; temp place	to keep	a register value when an YM instrument is loaded
		pop	hl
		ld	b, 4

loc_B1C:				; CODE XREF: YM2_LoadInstrument+95j
		push	bc
		ld	b, a
		push	af
		rr	d
		jr	nc, loc_B31
		ld	a, 7Fh ; ''
		sub	(hl)
		add	a, c
		ld	c, a
		cp	7Fh ; ''
		jr	c, loc_B2E
		ld	c, 7Fh ; ''

loc_B2E:				; CODE XREF: YM2_LoadInstrument+85j
		jp	loc_B32
; ---------------------------------------------------------------------------

loc_B31:				; CODE XREF: YM2_LoadInstrument+7Cj
		ld	c, (hl)

loc_B32:				; CODE XREF: YM2_LoadInstrument:loc_B2Ej
		call	YM2_ConditionalInput
		pop	af
		inc	hl
		add	a, 4
		pop	bc
		djnz	loc_B1C
		ld	b, 14h

loc_B3E:				; CODE XREF: YM2_LoadInstrument+A5j
		push	bc
		ld	b, a
		ld	c, (hl)
		push	af
		call	YM2_ConditionalInput
		pop	af
		inc	hl
		add	a, 4
		pop	bc
		djnz	loc_B3E
		add	a, 10h
		ld	b, a
		ld	c, (hl)
		call	YM2_ConditionalInput
		pop	de
		ld	a, (CURRENTLY_MANAGING_SFX)
		or	a
		jr	nz, smeuuh1		
		ld	a, (MUSIC_BANK)
		jr	smeuuh2
smeuuh1:
		ld	a, SFX_BANK
smeuuh2:		
		call	LoadAnyBank
		ret
; End of function YM2_LoadInstrument