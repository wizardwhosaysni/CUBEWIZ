; =============== S U B	R O U T	I N E =======================================


Main_Loop:				
					; Update_YM_Instruments+6j  <---- still need to figure out the exact purpose of this way to return to main loop

		; This part updates sequential sound at each YM Timer overflow
					
		ld	a, (YM1_REGISTER) 
		and	2		
		jr	z, Dac_Loop	; jump as long as there	is no timer overflow
		ld	a, d
		ld	(DAC_REMAINING_LENGTH), a
		ld	a, e
		ld	(DAC_REMAINING_LENGTH+1), a		
		ld	a, h
		ld	(DAC_LAST_OFFSET), a
		ld	a, l
		ld	(DAC_LAST_OFFSET+1), a
		call	UpdateSound	; This is the entry point to the big sound update process, which causes a large plateau in DAC sound.
		ld	a, (DAC_LAST_OFFSET)
		ld	h, a		
		ld	a, (DAC_LAST_OFFSET+1)
		ld	l, a	
		ld	a, (DAC_REMAINING_LENGTH)
		ld	d, a		
		ld	a, (DAC_REMAINING_LENGTH+1)
		ld	e, a	
		jp	loc_34

		; This part loops a number of times varying according to DAC rate
Dac_Loop:				
		ld	b, 5		; loop parameter is dynamically	changed	to adjust time period of a DAC sound
loc_32:			
		djnz	$		; loop b times before checking things to do

		; This part checks for a new command to process 
loc_34:					
		ld	a, (NEW_OPERATION)
		or	a		
		call	nz, Main ; This is the entry point to load a new command

		; This part checks for a new DAC sample to load
		
		ld	a, (NEW_SAMPLE_TO_LOAD)
		or	a		
		call	nz, LoadDacSound
		
		; This part checks if there is DAC data to send to YM
		
		ld	a, d		; check	remaining sound	length
		or	e
		jr	z, Main_Loop	; if remaining length =	0, then	it's end of DAC sample, or it's because sample $FE has been loaded at initialization
		
		; This part transmits DAC Data
		
		ld	b, 2Ah ; '*'    ; YM Register : DAC data
		ld	c, (hl)		; get next DAC sample byte. It's 8-bit PCM
		inc	hl

loc_4A:					
		ld	a, (YM1_REGISTER)
		and	80h ; '�'
		jr	nz, loc_4A	; loop as long as YM busy
		ld	a, b
		ld	(YM1_REGISTER),	a
		ld	a, c
		ld	(YM1_DATA), a	; transmit DAC Data
		dec	de		; decrement remaining sound length to play
		jp	Main_Loop	; End of the driver's main loop !
; End of function Main_Loop