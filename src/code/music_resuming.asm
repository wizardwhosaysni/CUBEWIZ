; =============== S U B	R O U T	I N E =======================================


DeactivateResuming:				
		ld	a, 0FFh
		ld	(RESUMING_DEACTIVATED), a
		ret
; End of function DeactivateResuming


; =============== S U B	R O U T	I N E =======================================


ActivateResuming:				
		ld	a, 0h
		ld	(RESUMING_DEACTIVATED), a
		ret
; End of function DeactivateResuming


; =============== S U B	R O U T	I N E =======================================

;

Save_Music:	
		push	ix
		push	iy
		push	bc			
		push	de	
		ld	a, (YM_TIMER_VALUE)
		ld	(SAVED_YM_TIMER_VALUE), a
		ld	a, (MUSIC_DOESNT_USE_SAMPLES)
		ld	(SAVED_MUSIC_DOESNT_USE_SAMPLES), a
		ld	ix, MUSIC_CHANNEL_YM1
		ld	iy, SAVED_MUSIC_CHANNEL_YM1
		ld	b, 0h
		ld	c, 010h
		ld	d, 0Ah		
Save_Music_Loop:			
		call	Copy_Channel_Data	
		add	ix, bc
		add	iy, bc
		dec	d
		jr	nz, Save_Music_Loop	
		pop	de
		pop	bc		
		pop	iy
		pop	ix
		ret
; End of function Save_Music

; =============== S U B	R O U T	I N E =======================================

;

Resume_Music:		
		
		push	ix
		push	iy	
		push	bc		
		push	de
		
		; save in temporary space

		ld	a, (MUSIC_BANK)
		ld	(TMPCPY_MUSIC_BANK), a
		ld	a, (YM_TIMER_VALUE)
		ld	(TMPCPY_YM_TIMER_VALUE), a
		ld	a, (MUSIC_DOESNT_USE_SAMPLES)
		ld	(TMPCPY_MUSIC_DOESNT_USE_SAMPLES), a
		ld	ix, MUSIC_CHANNEL_YM1
		ld	iy, TMPCPY_MUSIC_CHANNEL_YM1
		ld	b, 0h
		ld	c, 010h
		ld	d, 0Ah		
Tmpcpy_Music_Loop:			
		call	Copy_Channel_Data	
		add	ix, bc
		add	iy, bc
		dec	d
		jr	nz, Tmpcpy_Music_Loop
		
		call	StopMusic				
		
		; resume
		
		xor	a
		ld	a, (SAVED_MUSIC_BANK)
		ld	(MUSIC_BANK), a
		call	LoadAnyBank
		ld	a, (SAVED_MUSIC_DOESNT_USE_SAMPLES)
		ld	(MUSIC_DOESNT_USE_SAMPLES), a
		ld	a, (SAVED_YM_TIMER_VALUE)
		ld	(YM_TIMER_VALUE), a
		call	YM_SetTimer
		ld	a, 010h
		ld	(FADE_IN_PARAMETERS), a
		;ld	a, (FADE_IN_PARAMETERS)	; fade in parameter applied from 68k when a music is loaded. nibble 1 :	fade in	speed. nibble 2	: fade in start	level.
		and	0Fh
		ld	(MUSIC_LEVEL), a ; general output level	for music and SFX type 1, sent from 68k
		xor	a
		ld	(FADE_IN_TIMER), a ; reset fade	in timer	
		ld	ix, SAVED_MUSIC_CHANNEL_YM1
		ld	iy, MUSIC_CHANNEL_YM1
		ld	b, 0h
		ld	c, 010h		
		ld	d, 0Ah
Resume_Music_Loop:			
		call	Copy_Channel_Data	
		add	ix, bc
		add	iy, bc
		dec	d
		jr	nz, Resume_Music_Loop
		
		
		; Copy temporary space into saved space

		ld	a, (TMPCPY_MUSIC_BANK)
		ld	(SAVED_MUSIC_BANK), a
		ld	a, (TMPCPY_YM_TIMER_VALUE)
		ld	(SAVED_YM_TIMER_VALUE), a
		ld	a, (TMPCPY_MUSIC_DOESNT_USE_SAMPLES)
		ld	(SAVED_MUSIC_DOESNT_USE_SAMPLES), a
		ld	ix, TMPCPY_MUSIC_CHANNEL_YM1
		ld	iy, SAVED_MUSIC_CHANNEL_YM1
		ld	b, 0h
		ld	c, 010h
		ld	d, 0Ah		
Tmpcpy_save_Music_Loop:			
		call	Copy_Channel_Data	
		add	ix, bc
		add	iy, bc
		dec	d
		jr	nz, Tmpcpy_save_Music_Loop
		
		; avoid resumed PCM sample while fading in
		ld	a, 0FEh	; '�'
		ld	(NEW_SAMPLE_TO_LOAD), a
		call	DAC_SetNewSample ; play	nothing	!
		xor	a
		ld	(DAC_REMAINING_LENGTH), a
		ld	(DAC_REMAINING_LENGTH+1), a
		ld	(DAC_LAST_OFFSET), a
		ld	(DAC_LAST_OFFSET+1), a
				
		pop	de
		pop	bc		
		pop	iy
		pop	ix
		ret
; End of function Resume_Music

; =============== S U B	R O U T	I N E =======================================


Copy_Channel_Data:				
		push	de	
		ld	d, 010h
Copy_Channel_Data_Loop:
		call	Copy_Byte
		call	Copy_Byte		
		dec	d
		jr	nz, Copy_Channel_Data_Loop
		pop	de
		ret
; End of function Copy_Byte

; =============== S U B	R O U T	I N E =======================================


Copy_Byte:				
		ld	a, (ix)
		ld	(iy), a
		inc	ix
		inc	iy
		ret
; End of function Copy_Byte