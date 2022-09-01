; =============== S U B	R O U T	I N E =======================================


DAC_SetNewSample:			; CODE XREF: YM2_ParseChannel6Data+2Dp
					; YM2_ParseChannel6Data+B7p
		ld	b, a
		ld	a, (CURRENTLY_MANAGING_SFX) ; indicates if an SFX type 2	is being processed, because these ones use extra channel ram areas, to keep current music data for when	SFX is finished
		or	a
		jr	nz, loc_562	; if currently managing	SFX channel ram	data, just set new sample to load
		exx
		push	ix		; otherwise, check if an SFX is	being played, since it has priority
		pop	hl
		ld	bc, 01E3h ; '�'
		add	hl, bc
		ld	a, (hl)		; get "channel not in use" byte for SFX Channel 1
		exx
		or	a
		ret	z		; if SFX Channel 1 in use, return
		ld	a, (FADE_OUT_COUNTER) ;	Counts how many	times the fade out timer reached 0. Fade out stops at value $0C.
		cp	3		; if fade out counter >	3, don't play sample, it would be too loud compared to the other channels
		ret	nc
		ld	a, (MUSIC_LEVEL) ; general output level	for music and SFX type 1, sent from 68k
		cp	0Fh		; if general sound level not at	its max, then don't play sample
		ret	nz

loc_562:				; CODE XREF: DAC_SetNewSample+5j
		ld	a, b
		ld	(NEW_SAMPLE), a	; stores the index of a	new DAC	sample to play
		ret
; End of function DAC_SetNewSample