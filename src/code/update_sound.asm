; =============== S U B	R O U T	I N E =======================================


UpdateSound:				; CODE XREF: Main_Loop+7p
		push	bc		; this is THE subroutine that updates every channel at each YM Timer overflow. Quite important !
		push	de
		push	hl
		
		; This part activates/deactivates DAC on YM6
		
		ld	bc, 2B80h	; bc = enable DAC
		ld	a, (MUSIC_YM6_FM_MODE)
		or	a
		jr	z, loc_42B	; if music uses	DAC samples, enable DAC
		ld	a, (SFX_CHANNEL_YM6+CHANNEL_FREE)
		or	a
		jr	z, loc_42B	; else,	if (0x1503) = 0, then a	DAC sample is played as	an SFX,	so enable DAC
		ld	bc, 2B00h	; else,	disable	DAC

loc_42B:				; CODE XREF: UpdateSound+Aj
					; UpdateSound+10j
		call	YM1_Input	; enable/disable DAC
		
		; This part updates music level with possible fade in parameters
		
		ld	hl, FADE_IN_TIMER ; incremented	at each	YM Timer overflow. When	it corresponds to fade in parameter, increment YM instruments level until max level
		inc	(hl)		; increment counter
		ld	a, (FADE_IN_PARAMETERS)	; fade in parameter applied from 68k when a music is loaded. nibble 1 :	fade in	speed. nibble 2	: fade in start	level.
		rrca			; two circular right rotates
		rrca
		and	3Ch ; '<'       ; just keep nibble 1 * 4
		jr	z, loc_44C
		cp	(hl)
		jr	nz, loc_44C
		xor	a		; if MusicCounter = Nibble 1 * 4 and !=	0
		ld	(hl), a		; clear	MusicCounter
		ld	hl, MUSIC_LEVEL	; general output level for music and SFX type 1, sent from 68k
		ld	a, (hl)
		cp	0Fh
		jr	z, loc_44C
		inc	(hl)		; if music level not 0F, increment it and update YM instruments	levels
		ld	a, (hl)
		cp	0Fh
		jr	z, update_level
		inc	(hl)
		ld	a, (hl)
		cp	0Fh
		jr	z, update_level
		inc	(hl)
		ld	a, (hl)
		cp	0Fh
		jr	z, update_level
		inc	(hl)
update_level:		
		call	YM_UpdateInstrumentsLevels

loc_44C:				; CODE XREF: UpdateSound+23j
					; UpdateSound+26j UpdateSound+30j			
		
		; This part manages fade out and stops music at fade out end
		
		ld	a, (CURRENTLY_FADING_OUT) ; set	to 01 when a fade out operation	is being executed
		or	a
		jr	z, loc_475	; jump unless currently	executing a fade out
		ld	a, (FADE_OUT_TIMER) ; Starts with fade out length value, decrements at each YM Timer overflow. set to $63 while	loading	music
		or	a
		jr	nz, loc_471
		ld	a, (FADE_OUT_LENGTH) ; number of YM Timer overflows to handle before incrementing the fade out counter
		ld	(FADE_OUT_TIMER), a ; Starts with fade out length value, decrements at each YM Timer overflow. set to $63 while	loading	music
		ld	a, (FADE_OUT_COUNTER) ;	Counts how many	times the fade out timer reached 0. Fade out stops at value $0C.
		inc	a
		ld	(FADE_OUT_COUNTER), a ;	increment fade out counter if fade out timer has reached 0
		cp	0Ch
		jr	nz, loc_475	; reload timer B
		call	StopMusic	; if FadeOutCounter = 0Ch, then	stop music because it's the end of a fade out operation
		jp	loc_4DE
; ---------------------------------------------------------------------------

loc_471:				; CODE XREF: UpdateSound+43j
		dec	a
		ld	(FADE_OUT_TIMER), a ; decrement	fade out timer

loc_475:				; CODE XREF: UpdateSound+3Dj
					; UpdateSound+54j
				
		ld	a, (MUSIC_BANK)
		call	LoadBank				
					
		; Start of Music Update	
					
		call	YM_LoadTimerB	; reload timer B
		ld	iy, CURRENT_CHANNEL ; indicates	the channel to process,	from a relative	point of view :	YM1, YM2, PSG or SFX channels
		xor	a
		ld	(CURRENTLY_MANAGING_SFX), a
		ld	(CALL_YM2_INSTEAD_OF_YM1), a ; taking care of YM 1,2,3
		ld	(iy+0),	a
		call	YM1_ParseData
		
		; DAC Byte intermediate transmission
		call	SendDacByte
		
		inc	(iy+0)
		call	YM1_ParseData
		
		; DAC Byte intermediate transmission
		call	SendDacByte
		
		inc	(iy+0)
		call	YM1_ParseData
		
		; DAC Byte intermediate transmission
		call	SendDacByte
		
		ld	a, 1
		ld	(CALL_YM2_INSTEAD_OF_YM1), a ; taking care of YM 4,5,6
		xor	a
		ld	(iy+0),	a
		call	YM2_ParseData
		
		; DAC Byte intermediate transmission
		call	SendDacByte
		
		inc	(iy+0)
		call	YM2_ParseData
		
		; DAC Byte intermediate transmission
		call	SendDacByte
		
		inc	(iy+0)
		call	YM2_ParseChannel6Data
		
		; DAC Byte intermediate transmission
		call	SendDacByte
		
		xor	a
		ld	(iy+0),	a
		call	PSG_ParseToneData
		
		; DAC Byte intermediate transmission
		call	SendDacByte
		
		inc	(iy+0)
		call	PSG_ParseToneData
		
		; DAC Byte intermediate transmission
		call	SendDacByte
			
		inc	(iy+0)
		call	PSG_ParseToneData
		
		; DAC Byte intermediate transmission
		call	SendDacByte
		
		inc	(iy+0)
		call	PSG_ParseNoiseData
		
		; DAC Byte intermediate transmission
		call	SendDacByte
		
		
		; Start of SFX Update
		
		ld	a, SFX_BANK
		call	LoadBank		
		ld	a, 1
		ld	(CURRENTLY_MANAGING_SFX), a
		xor	a
		ld	(CALL_YM2_INSTEAD_OF_YM1), a ; taking care of YM 1,2,3
		ld	(iy+0),	a
		call	YM1_ParseData
		inc	(iy+0)
		call	YM1_ParseData
		inc	(iy+0)
		call	YM1_ParseData
		ld	a, 1
		ld	(CALL_YM2_INSTEAD_OF_YM1), a ; taking care of YM 4,5,6
		xor	a
		ld	(iy+0),	a
		call	YM2_ParseData
		inc	(iy+0)
		call	YM2_ParseData
		inc	(iy+0)
		call	YM2_ParseChannel6Data
		xor	a
		ld	(iy+0),	a
		call	PSG_ParseToneData
		inc	(iy+0)
		call	PSG_ParseToneData		
		inc	(iy+0)
		call	PSG_ParseToneData
		inc	(iy+0)
		call	PSG_ParseNoiseData		
		
		ld	a, 0
		ld	(CURRENTLY_MANAGING_SFX), a

loc_4DE:				; CODE XREF: UpdateSound+59j
		ld	a, (DAC_BANK)
		call	LoadBank
		pop	hl
		pop	de
		pop	bc
		ret
; End of function UpdateSound