; =============== S U B	R O U T	I N E =======================================


Update_YM_Instruments:			; CODE XREF: Pause_Sound+4Fj
					; Update_YM_Level+9j
		call	YM_UpdateInstrumentsLevels
		pop	de
		pop	hl
		pop	af
		jp	MainLoop	; go back to main loop
; End of function Update_YM_Instruments


; =============== S U B	R O U T	I N E =======================================


YM_UpdateInstrumentsLevels:		; CODE XREF: Update_YM_Instrumentsp
					; UpdateSound+33p
					
					; new workflow yet to implement :
					; for each of the 10 channels, update SFX channel instrument in priority over music instrument
					; 
					
		ld	iy, CURRENT_CHANNEL ; indicates	the channel to process,	from a relative	point of view :	YM1, YM2, PSG or SFX channels
		xor	a
		ld	(CALL_YM_PART2), a ; set to $01 when managing	YM4,5,6	channels, to call part 2 of YM
		ld	(iy+0),	a
		ld	ix, MUSIC_CHANNEL_YM1 ;	get channel data area
		ld	a, (ix+4)	; get channel level
		call	YM1_LoadInstrument ; reload instrument to load the new level
		inc	(iy+0)
		ld	ix, MUSIC_CHANNEL_YM2
		ld	a, (ix+4)
		call	YM1_LoadInstrument
		inc	(iy+0)
		ld	ix, MUSIC_CHANNEL_YM3
		ld	a, (ix+4)
		call	YM1_LoadInstrument
		xor	a
		ld	(iy+0),	a
		ld	a, 1
		ld	(CALL_YM_PART2), a ; set to $01 when managing	YM4,5,6	channels, to call part 2 of YM
		ld	ix, MUSIC_CHANNEL_YM4
		ld	a, (ix+4)
		call	YM2_LoadInstrument
		inc	(iy+0)
		ld	ix, MUSIC_CHANNEL_YM5
		ld	a, (ix+4)
		call	YM2_LoadInstrument
		ld	ix, MUSIC_CHANNEL_YM6
		ld	a, (ix+4)
		call	YM2_LoadInstrument
		xor	a
		ret
; End of function YM_UpdateInstrumentsLevels


; =============== S U B	R O U T	I N E =======================================


UpdateYmLevel:			; CODE XREF: Main+17j
		push	hl
		push	de
		ld	hl, MUSIC_LEVEL	; general output level for music and SFX type 1, sent from 68k
		ld	a, (hl)
		and	0Fh
		ld	(hl), a
		jp	Update_YM_Instruments
		ld	a, (DAC_BANK)
		jp	LoadBank
; End of function Update_YM_Level