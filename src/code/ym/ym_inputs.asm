; =============== S U B	R O U T	I N E =======================================


YM1_ConditionnalInput:			; CODE XREF: YM2_ParseData+45p
					; YM2_ParseData+154p
		ld	a, (CURRENTLY_MANAGING_SFX) 
		or	a
		jr	nz, ApplyYm1Input	; if currently managing	SFX channel data, then just send data to YM1
		exx
		push	ix		; otherwise, check if an SFX is	being played on	YM4,5,6
		pop	hl
		ld	bc, 01E3h ; '�'
		add	hl, bc
		ld	a, (hl)		; get "channel not in use" byte for SFX Channel 1
		exx
		or	a
		jr	nz, ApplyYm1Input	; don't send data to YM if an SFX is being played, as it has priority over music
		ret
; End of function YM1_ConditionnalInput


; =============== S U B	R O U T	I N E =======================================


ApplyYmInput:				; CODE XREF: Pause_Sound:loc_6Bp
					; Pause_Sound+12p Pause_Sound+16p
					; Main+D5p Main+D9p Main+DDp
		ld	a, (CALL_YM2) ; set to $01 when managing	YM4,5,6	channels, to call part 2 of YM
		or	a
		jr	nz, YM2_ConditionalInput ; if CallYm2InsteadOfYm1 set
		jp	YM1_ConditionnalInput
; End of function YM_Input


; =============== S U B	R O U T	I N E =======================================


ApplyYm1Input:				; CODE XREF: Main+72p Main+151p
					; StopMusic+16p StopMusic+27p
					; StopMusic+38p StopMusic+55p
					; StopMusic+6Cp StopMusic+83p
					; UpdateSound:loc_42Bp
					; YM_LoadTimerB+3j
					; YM1_ConditionnalInput+4j
					; YM1_ConditionnalInput+11j
					; YM1_Input+5j	YM1_ParseData+38p
					; YM1_ParseData:loc_668p
					; YM1_ParseData:loc_680p
					; YM1_ParseData+124p
					; YM1_ParseData+213p
					; YM1_ParseData+21Cp
					; YM1_LoadInstrument+46p
					; YM1_LoadInstrument:loc_A79p
					; YM1_LoadInstrument+92p
					; YM1_LoadInstrument+A0p
					; PSG_ParseToneData+7Dp
					; YM1_SetStereo+11j YM_SetTimer+7p
		ld	a, (YM1_REGISTER) ; the	subroutine sends value c in register b of YM1
		and	80h ; '�'
		jr	nz, ApplyYm1Input	; loop as long as YM2612 busy
		ld	a, b
		ld	(YM1_REGISTER),	a ; write address to part I
		ld	a, c
		ld	(YM1_DATA), a	; write	data to	part I
		ret
; End of function YM1_Input


; =============== S U B	R O U T	I N E =======================================


YM2_ConditionalInput:			; CODE XREF: YM_Input+4j
					; YM2_ParseData:loc_8C0p
					; YM2_ParseData:loc_8D8p
					; YM2_ParseData+243p
					; YM2_ParseData+24Cp
					; YM2_LoadInstrument+51p
					; YM2_LoadInstrument:loc_B32p
					; YM2_LoadInstrument+9Dp
					; YM2_LoadInstrument+ABp
					; YM2_SetStereo+10j
		ld	a, (CURRENTLY_MANAGING_SFX) 
		or	a
		jr	nz, ApplyYm2Input	; if currently managing	SFX channel ram	data, just send	byte to	YM
		exx
		push	ix		; otherwise, first check if an SFX is being played with	YM4,5,6	channels
		pop	hl
		ld	bc, 01E3h ; '�'
		add	hl, bc
		ld	a, (hl)		; get "channel not in use" byte of SFX channel 1
		exx
		or	a		; if SFX currently being played, then don't send data to YM2, as SFX has priority
		ret	z
; End of function YM2_ConditionalInput


; =============== S U B	R O U T	I N E =======================================


ApplyYm2Input:				; CODE XREF: Pause_Sound:loc_85p
					; Pause_Sound+2Cp Pause_Sound+30p
					; Main+15Ap YM2_ConditionalInput+4j
					; YM2_Input+5j	YM2_ParseData+94p
					; YM2_ParseChannel6Data+78p
		ld	a, (YM2_REGISTER)
		and	80h ; '�'
		jr	nz, ApplyYm2Input	; loop as long as YM2612 busy
		ld	a, b
		ld	(YM2_REGISTER),	a ; write address to YM2
		ld	a, c
		ld	(YM2_DATA), a	; write	data to	YM2
		ret
; End of function YM2_Input