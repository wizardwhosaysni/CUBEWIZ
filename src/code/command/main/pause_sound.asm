; =============== S U B	R O U T	I N E =======================================


Pause_Sound:				; CODE XREF: Main+8j
		push	hl		; mutes	sound at reception of operation	$FF
		push	de
		xor	a
		ld	(CURRENTLY_MANAGING_SFX), a ; clear
		ld	(CALL_YM2_INSTEAD_OF_YM1), a ; set to $01 when managing	YM4,5,6	channels, to call part 2 of YM
		ld	bc, 407Fh	; set Total Level to smallest amplitude
		ld	d, 4		; 4 loops, one for each	operator of the	3 channels

loc_6B:					; CODE XREF: Pause_Sound+1Cj

					; Conditional input to implement here !

		call	YM_Input
		inc	b
		call	YM_Input
		inc	b
		call	YM_Input
		inc	b
		inc	b
		dec	d
		jr	nz, loc_6B
		ld	a, 1
		ld	(CALL_YM2_INSTEAD_OF_YM1), a ; set to $01 when managing	YM4,5,6	channels, to call part 2 of YM
		ld	bc, 407Fh	; set Total Level to smallest amplitude
		ld	d, 4		; 4 loops, one for each	operator of 3 channels

loc_85:					; CODE XREF: Pause_Sound+36j
		call	YM2_Input
		inc	b
		call	YM2_Input
		inc	b
		call	YM2_Input
		inc	b
		inc	b
		dec	d
		jr	nz, loc_85
		ld	hl, PSG_PORT
		ld	a, 9Fh ; '�'
		ld	(hl), a		; set PSG channel 1 volume to 0
		ld	a, 0BFh	; '�'
		ld	(hl), a		; set PSG channel 2 volume to 0
		ld	a, 0DFh	; '�'
		ld	(hl), a		; set PSG channel 3 volume to 0
		ld	a, 0FFh
		ld	(hl), a		; set PSG noise	channel	volume to 0

loc_A4:					; CODE XREF: Pause_Sound+4Bj
		ld	a, (NEW_COMMAND) ; new operation to process (play music/sfx, fade out	...), sent from	68k
		or	a
		jr	z, loc_A4	; loop as long as there	is no new operation to process
		cp	0FFh
		jr	nz, Update_YM_Instruments ; if next sent operation is not to mute the sound, go	process	it in the main loop
		xor	a		; if next sent operation is to mute the	sound, then ignore it, and also	go back	to main	loop !
		ld	(NEW_COMMAND), a ; new operation to process (play music/sfx, fade out	...), sent from	68k
; End of function Pause_Sound