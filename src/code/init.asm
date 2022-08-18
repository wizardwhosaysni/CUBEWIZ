; =============== S U B	R O U T	I N E =======================================


init:
		di			; disable interrupts : synchronisation is just based on	YM Timer
		ld	sp, STACK_START	; initialize stack pointer
		ld	a, 0Fh
		ld	(MUSIC_LEVEL), a ; init	music level at max value
		ld	a, 0FFh
		ld	(YM_TIMER_VALUE), a ; init timer value without sending it to YM
		ld	a, 0Fh
		ld	(FADE_IN_PARAMETERS), a	; init fade in parameters : no fade in	 
		call	ActivateResuming
		ld	a, 20h ; ' '    ; load music $20, which is void
		call	Main		; process new operation	$20 to initialize YM and PSG with void data
		ld	a, (DAC_BANK)
		call	LoadAnyBank	; init loaded bank, and	enter the driver's main loop !
; End of function init