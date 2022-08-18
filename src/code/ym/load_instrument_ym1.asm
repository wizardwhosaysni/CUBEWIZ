; =============== S U B	R O U T	I N E =======================================


YM1_LoadInstrument:			; CODE XREF: YM_UpdateInstrumentsLevels+12p
					; YM_UpdateInstrumentsLevels+1Fp
					; YM_UpdateInstrumentsLevels+2Cp
					; StopMusic+10p StopMusic+21p
					; StopMusic+32p YM1_ParseData+76j
					; YM1_ParseData+91p YM1_ParseData+227j
		push	af
		ld	a, YM_INSTRUMENTS_BANK
		call	LoadAnyBank
		pop	af
		ld	(ix+4),	a	; a is the total level of the instrument
		ld	a, (CURRENTLY_MANAGING_SFX) 
		or	a
		jr	z, loc_nimp3
		ld	a, (ix+4)
		jr	loc_A0D
; ---------------------------------------------------------------------------
		
loc_nimp3:		
		ld	a, (FADE_OUT_COUNTER) ;	Counts how many	times the fade out timer reached 0. Fade out stops at value $0C.
		add	a, 0Fh
		ld	h, a
		ld	a, (MUSIC_LEVEL) ; general output level	for music and SFX type 1, sent from 68k
		add	a, (ix+4)
		sub	h
		jr	nc, loc_A0D
		xor	a		; put level to 0

loc_A0D:				; CODE XREF: YM1_LoadInstrument+13j
		push	de
		push	af
		ld	a, (ix+10h)	; load instrument index
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
		add	hl, de		; hl now points	to the first byte of the instrument to load
		push	hl
		ld	de, 1Ch		; get algorithm	byte
		add	hl, de
		ld	a, (hl)
		and	7		; only keep algo bits
		ld	(ix+5),	a	; store	algo value
		pop	hl		; get back instrument start offset
		ld	a, (iy+0)	; get currently	managed	channel	value
		add	a, 30h ; '0'    ; register value for detune/multiple
		ld	b, 4		; loop 4 times

loc_A39:				; CODE XREF: YM1_LoadInstrument+4Ej
		push	bc
		ld	b, a		; YM Register :	detune/multiple
		ld	c, (hl)
		push	af
		call	YM1_ConditionnalInput
		pop	af
		inc	hl
		add	a, 4
		pop	bc
		djnz	loc_A39
		ld	(TEMP_REGISTER), a ; store register value : 40h
		pop	af
		push	hl
		ld	d, 0
		ld	e, a
		ld	hl, t_YM_LEVELS
		ld	b, e
		add	hl, de
		ld	c, (hl)		; put corresponding value in c
		ld	e, (ix+5)	; get Algo
		ld	hl, t_SLOTS_PER_ALGO
		add	hl, de
		ld	d, (hl)		; put corresponding value in d
		ld	a, (TEMP_REGISTER) ; temp place	to keep	a register value when an YM instrument is loaded
		pop	hl
		ld	b, 4		; loop 4 times

loc_A63:				; CODE XREF: YM1_LoadInstrument+8Aj
		push	bc
		ld	b, a		; YM Register :	Total level
		push	af
		rr	d
		jr	nc, loc_A78	; if rotated bit = 0, then use original	instrument level
		ld	a, 7Fh ; ''    ; else, the operator is a slot, so use channel level
		sub	(hl)		; instrument's operator total level value
		add	a, c
		ld	c, a
		cp	7Fh ; ''
		jr	c, loc_A75	; if result > 7F, then put 7F, since it's the max value
		ld	c, 7Fh ; ''

loc_A75:				; CODE XREF: YM1_LoadInstrument+7Aj
		jp	loc_A79
; ---------------------------------------------------------------------------

loc_A78:				; CODE XREF: YM1_LoadInstrument+71j
		ld	c, (hl)		; get instrument's operator level

loc_A79:				; CODE XREF: YM1_LoadInstrument:loc_A75j
		call	YM1_ConditionnalInput
		pop	af
		inc	hl
		add	a, 4
		pop	bc
		djnz	loc_A63
		ld	b, 14h		; loop 20d times, so 5 * 4 operators, so from 50h to A0h

loc_A85:				; CODE XREF: YM1_LoadInstrument+9Aj
		push	bc
		ld	b, a		; YM Register :	Rate scalling /	Attack rate, First decay rate /	Amplitude modulation ...
		ld	c, (hl)		; ... Secondary	decay rate, Secondary amplitude	/ Release rate,	SSG-EG
		push	af
		call	YM1_ConditionnalInput
		pop	af
		inc	hl
		add	a, 4
		pop	bc
		djnz	loc_A85
		add	a, 10h
		ld	b, a		; YM Register :	Feedback / Algorithm
		ld	c, (hl)
		call	YM1_ConditionnalInput
		pop	de
		ld	a, (CURRENTLY_MANAGING_SFX)
		or	a
		jr	nz, smeuuh3		
		ld	a, (MUSIC_BANK)
		jr	smeuuh4
smeuuh3:
		ld	a, SFX_BANK
smeuuh4:		
		call	LoadAnyBank
		ret
; End of function YM1_LoadInstrument