; =============== S U B	R O U T	I N E =======================================


StopMusic:				; CODE XREF: Main+Dj Main+65p
					; UpdateSound+56p
		push	hl		; the subroutine sets key off /	mutes channels playing music
		ld	iy, CURRENT_CHANNEL ; indicates	the channel to process,	from a relative	point of view :	YM1, YM2, PSG or SFX channels
		xor	a
		ld	(CALL_YM_PART2), a ; set to $01 when managing	YM4,5,6	channels, to call part 2 of YM
		ld	(iy+0),	a
		ld	ix, MUSIC_CHANNEL_YM1
		call	YM1_LoadInstrument
		ld	bc, 2800h	; YM register :	Key on/off
		call	YM1_ConditionnalInput	; set Key OFF
		inc	(iy+0)
		xor	a
		ld	ix, MUSIC_CHANNEL_YM2
		call	YM1_LoadInstrument
		ld	bc, 2801h	; YM register :	Key on/off
		call	YM1_ConditionnalInput	; set Key OFF
		inc	(iy+0)
		xor	a
		ld	ix, MUSIC_CHANNEL_YM3
		call	YM1_LoadInstrument
		ld	bc, 2802h	; YM register :	Key on/off
		call	YM1_ConditionnalInput	; set Key OFF
		ld	a, 1
		ld	(CALL_YM_PART2), a ; set to $01 when managing	YM4,5,6	channels, to call part 2 of YM
		xor	a
		ld	(iy+0),	a
		ld	a, (SFX_CHANNEL_YM4+CHANNEL_FREE)
		or	a
		jr	z, loc_3B5
		xor	a
		ld	ix, MUSIC_CHANNEL_YM4
		call	YM2_LoadInstrument
		ld	bc, 2804h	; YM register :	Key on/off
		call	YM1_ConditionnalInput

loc_3B5:				; CODE XREF: StopMusic+48j
		inc	(iy+0)
		ld	a, (SFX_CHANNEL_YM5+CHANNEL_FREE)
		or	a
		jr	z, loc_3CC
		xor	a
		ld	ix, MUSIC_CHANNEL_YM5
		call	YM2_LoadInstrument
		ld	bc, 2805h	; YM register :	Key on/off
		call	YM1_ConditionnalInput

loc_3CC:				; CODE XREF: StopMusic+5Fj
		inc	(iy+0)
		ld	a, (SFX_CHANNEL_YM6+CHANNEL_FREE)
		or	a
		jr	z, loc_3E3
		xor	a
		ld	ix, MUSIC_CHANNEL_YM6
		call	YM2_LoadInstrument
		ld	bc, 2806h	; YM register :	Key on/off
		call	YM1_ConditionnalInput
		jr	loc_3E3
		
StopMusic_DAC:				
		xor	a
		ld	(DAC_REMAINING_LENGTH), a
		inc	a
		ld	(DAC_REMAINING_LENGTH+1), a	

loc_3E3:				; CODE XREF: StopMusic+76j

					; doubt : stop SFX or use conditionnal input ?

		ld	hl, PSG_PORT
		ld	a, 9Fh ; '�'
		ld	(hl), a		; set PSG channel 1 volume to 0
		ld	a, 0BFh	; '�'
		ld	(hl), a		; set PSG channel 2 volume to 0
		ld	a, 0DFh	; '�'
		ld	(hl), a		; set PSG channel 3 volume to 0
		ld	a, 0FFh
		ld	(hl), a		; set PSG noise	channel	volume to 0
		ld	hl, MUSIC_CHANNEL_YM1+CHANNEL_FREE ; also pointed once	from 68k, to know if music/sfx is currently being played, I guess
		ld	de, 30h	; ' '   ; value to add to pointer to go to next channel in ram
		ld	b, 0Ah		; loop ten times
		ld	a, 1

loc_3FC:				; CODE XREF: StopMusic+A1j
		ld	(hl), a		; set "Channel not in use" byte
		add	hl, de		; go to	next channel
		djnz	loc_3FC		; loop until PSG Noise Channel.	SFX extra channels are not concerned.
		pop	hl
		ld	de, 0
		xor	a
		ld	(CURRENTLY_FADING_OUT),	a ; set	to 01 when a fade out operation	is being executed
		ld	(FADE_OUT_COUNTER), a ;	Counts how many	times the fade out timer reached 0. Fade out stops at value $0C.
		ld	a, 63h ; 'c'
		ld	(FADE_OUT_TIMER), a ; Starts with fade out length value, decrements at each YM Timer overflow. set to $63 while	loading	music
		ret
; End of function StopMusic