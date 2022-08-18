		align 020h
        		
USELESS_BYTE:	db 0			; DATA XREF: Main+62w
					; YM1_SetStereo:loc_1016r
					; YM1_SetStereo+2Bw
					; incremented each time	new stereo byte	has bit	0 set to 1, but	actually has no	effect on sound. Useless !
CURRENT_PSG_CHANNEL:db 0		; DATA XREF: PSG_ParseToneData-6FDr
					; PSG_ParseToneData+17w
					; PSG_ParseToneData+1DEr
					; PSG_ParseToneData+1FBr
					; PSG_ParseNoiseData+9w
					; current PSG channel to process, stored in the	right bits ready to be sent to PSG
CURRENT_CHANNEL:db 0			; DATA XREF: YM_UpdateInstrumentsLevelso
					; StopMusic+1o	UpdateSound+62o
					; indicates the	channel	to process, from a relative point of view : YM1, YM2, PSG or SFX channels
					; set to 01 when a fade	out operation is being executed
CURRENTLY_MANAGING_SFX:		db 0
CALL_YM2_INSTEAD_OF_YM1:db 0		; DATA XREF: Pause_Sound+6w
					; Pause_Sound+20w
					; YM_UpdateInstrumentsLevels+5w
					; YM_UpdateInstrumentsLevels+35w
					; Main+CFw StopMusic+6w StopMusic+3Dw
					; UpdateSound+6Aw UpdateSound+81w
					; YM_Inputr
					; set to $01 when managing YM4,5,6 channels, to	call part 2 of YM
CURRENTLY_MANAGING_SFX_TYPE_2:db 0	; DATA XREF: Pause_Sound+3w
					; YM_UpdateInstrumentsLevels+5Fw
					; UpdateSound+67w UpdateSound+B2w
					; YM1_ConditionnalInputr
					; YM2_ConditionalInputr
					; DAC_SetNewSample+1r
					; YM2_ParseData+12r YM2_ParseData+80r
					; YM2_ParseData+24Fr
					; YM2_LoadInstrument+6r
					; YM2_ParseChannel6Data+4r
					; YM2_ParseChannel6Data+64r
					; indicates if an SFX type 2 is	being processed, because these ones use	extra channel ram areas, to keep current music data for	when SFX is finished
		db    0
		db    0
TEMP_FREQUENCY:	dw 0			; DATA XREF: YM1_ParseData+15Ew
					; YM1_ParseData+17Ar
					; YM1_ParseData+188w
					; YM1_ParseData:loc_700r
					; YM2_ParseData+18Ew
					; YM2_ParseData+1AAr
					; YM2_ParseData+1B8w
					; YM2_ParseData:loc_95Ar
					; temp space to	store frequency	values when YM data is parsed
TEMP_REGISTER:	db 0			; DATA XREF: YM1_LoadInstrument+50w
					; YM1_LoadInstrument+66r
					; YM2_LoadInstrument+5Bw
					; YM2_LoadInstrument+71r
					; temp place to	keep a register	value when an YM instrument is loaded
					