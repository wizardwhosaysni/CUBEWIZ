

MuteSound:
		push	hl
		push	de

		xor	a
		ld	(PROCESSING_SFX), a
		ld	(CALL_YM_PART2), a
		ld	bc, 407Fh	; set Total Level to smallest amplitude
		ld	d, 4		; 4 loops, one for each	operator of the	3 channels
$$ym1VolumeDownLoop:
		call	ApplyYmInput
		inc	b
		call	ApplyYmInput
		inc	b
		call	ApplyYmInput
		inc	b
		inc	b
		dec	d
		jr	nz, $$ym1VolumeDownLoop

		ld	a, 1
		ld	(CALL_YM_PART2), a
		ld	bc, 407Fh	; set Total Level to smallest amplitude
		ld	d, 4		; 4 loops, one for each	operator of 3 channels
$$ym2VolumeDownLoop:
		call	ApplyYm2Input
		inc	b
		call	ApplyYm2Input
		inc	b
		call	ApplyYm2Input
		inc	b
		inc	b
		dec	d
		jr	nz, $$ym2VolumeDownLoop

		ld	hl, PSG_PORT
		ld	a, 9Fh
		ld	(hl), a		; set PSG channel 1 volume to 0
		ld	a, 0BFh
		ld	(hl), a		; set PSG channel 2 volume to 0
		ld	a, 0DFh
		ld	(hl), a		; set PSG channel 3 volume to 0
		ld	a, 0FFh
		ld	(hl), a		; set PSG noise	channel	volume to 0

$$waitNextCommandLoop:	
		ld	a, (NEW_COMMAND)
		or	a
		jr	z, $$waitNextCommandLoop
		cp	0FFh
		jr	nz, Update_YM_Instruments ; if next sent operation is not to mute the sound, go	process	it in the main loop
		xor	a		; if next sent operation is to mute the	sound, then ignore it before going back to main loop
		ld	(NEW_COMMAND), a
