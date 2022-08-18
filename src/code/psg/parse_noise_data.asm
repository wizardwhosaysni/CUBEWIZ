; =============== S U B	R O U T	I N E =======================================


PSG_ParseNoiseData:			; CODE XREF: UpdateSound+ADp
		ld	a, (iy+0)
		ld	ix, MUSIC_CHANNEL_NOISE
		ld	a, 60h ; '`'
		ld	(CURRENT_PSG_CHANNEL), a ; current PSG channel to process, stored in the right bits ready to be	sent to	PSG
		ld	a, (CURRENTLY_MANAGING_SFX) 
		or	a
		jr	z, loc_E87
		ld	de, 01E0h ; '�'  ; point to the right SFX channel data
		add	ix, de			

loc_E87:				; CODE XREF: PSG_ParseNoiseData+B1j
		ld	a, (ix+3)
		or	a
		ret	nz		; don't parse if channel not in use
		ld	a, (ix+2)
		or	a		; check	note time counter
		jp	nz, loc_F2F	; jump if it's not the end of the note
		ld	d, (ix+1)
		ld	e, (ix+0)	; if it's the end of the note, get data pointer to parse next byte

loc_E99:				; CODE XREF: PSG_ParseNoiseData+45j
					; PSG_ParseNoiseData+4Fj
					; PSG_ParseNoiseData+59j
					; PSG_ParseNoiseData+63j
					; PSG_ParseNoiseData+68j
		ld	a, (de)
		and	0F8h ; '�'
		cp	0F8h ; '�'
		jp	nz, loc_EE6	; jump if parsed byte is not a command
		ld	a, (de)
		cp	0FFh
		jp	nz, loc_EC3	; jump if command is not $FF
		inc	de
		ld	a, (de)
		ld	l, a
		inc	de
		ld	a, (de)
		ld	h, a
		or	l
		jr	nz, loc_EBF	; jump if command is FF	xx xx
		ld	a, 1
		ld	(ix+3),	a	; else,	FF 00 00 : stop	using this channel
		
					; doubt : if finishing SFX, do I need to update with music data ? like for YM ? We'll see
		
		ld	a, 0Fh
		jp	PSG_SetChannelAttenuation
; ---------------------------------------------------------------------------

loc_EBF:				; CODE XREF: PSG_ParseNoiseData+33j
		ex	de, hl
		jp	loc_E99
; ---------------------------------------------------------------------------

loc_EC3:				; CODE XREF: PSG_ParseNoiseData+29j
		cp	0FDh ; '�'
		jr	nz, loc_ECD
		call	PSG_LoadInstrument
		jp	loc_E99
; ---------------------------------------------------------------------------

loc_ECD:				; CODE XREF: PSG_ParseNoiseData+4Aj
		cp	0FCh ; '�'
		jr	nz, loc_ED7
		call	SetRelease
		jp	loc_E99
; ---------------------------------------------------------------------------

loc_ED7:				; CODE XREF: PSG_ParseNoiseData+54j
		cp	0F8h ; '�'
		jr	nz, Unidentified_Command
		call	ParseLoopCommand
		jp	loc_E99
; ---------------------------------------------------------------------------

Unidentified_Command:			; CODE XREF: PSG_ParseNoiseData+5Ej
		inc	de
		inc	de
		jp	loc_E99
; ---------------------------------------------------------------------------

loc_EE6:				; CODE XREF: PSG_ParseNoiseData+23j
		ld	a, (de)
		and	7Fh ; ''
		cp	70h ; 'p'
		jp	z, loc_F0B	; jump if byte = F0 or 70
		push	af		; keep byte without bit	7 : new	note
		ld	a, (ix+1Eh)
		or	a
		jr	z, loc_EFC	; jump if key has not just been	released
		xor	a		; key has just been released
		ld	(ix+12h), a	; reset	instrument relative pointer
		ld	(ix+1Eh), a	; clear	key release indicator

loc_EFC:				; CODE XREF: PSG_ParseNoiseData+78j
		pop	af
		and	7		; just keep bits 2-0
		or	0E0h ; '�'
		ld	(PSG_PORT), a	; transmit feedback and	freqency
		ld	a, (ix+8)
		and	80h ; '�'
		jr	loc_F10
; ---------------------------------------------------------------------------

loc_F0B:				; CODE XREF: PSG_ParseNoiseData+70j
		ld	a, (ix+8)
		or	1

loc_F10:				; CODE XREF: PSG_ParseNoiseData+8Ej
		ld	(ix+8),	a
		ld	a, (de)		; get full byte	again
		bit	7, a
		jr	nz, loc_F1D	; if bit 7 is set, next	byte is	note length to apply
		ld	a, (ix+7)
		jr	loc_F22		; reset	time counter
; ---------------------------------------------------------------------------

loc_F1D:				; CODE XREF: PSG_ParseNoiseData+9Bj
		inc	de
		ld	a, (de)
		ld	(ix+7),	a	; set new note length

loc_F22:				; CODE XREF: PSG_ParseNoiseData+A0j
		ld	(ix+2),	a	; reset	time counter
		inc	de
		ld	(ix+1),	d	; point	to next	byte to	parse
		ld	(ix+0),	e
		jp	loc_E87
; ---------------------------------------------------------------------------

loc_F2F:				; CODE XREF: PSG_ParseNoiseData+15j
		dec	(ix+2)		; decrement time counter
		call	PSG_GetInstrumentPointer ; affect level	depending on PSG Instrument used
		ld	b, (hl)		; byte b = 8x or 0x
		bit	7, b
		jr	nz, loc_F3E	; if byte $8x, then it's data end, so just keep applying the same level alteration
		inc	a		; if byte 0x, point to next byte
		ld	(ix+12h), a

loc_F3E:				; CODE XREF: PSG_ParseNoiseData+BDj
		res	7, b		; keep x only
		ld	a, 0Fh
		sub	b
		ld	b, a
		ld	a, (ix+4)
		sub	b		; a = level affected by	instrument
		jr	nc, loc_F4B	; make sure value is at	least 0
		xor	a

loc_F4B:				; CODE XREF: PSG_ParseNoiseData+CDj
		ld	b, a
		ld	a, (MUSIC_LEVEL) ; apply music level
		add	a, b
		sub	0Fh
		jr	nc, loc_F55	; make sure level is at	least 0
		xor	a

loc_F55:				; CODE XREF: PSG_ParseNoiseData+D7j
		ld	(ix+5),	a	; keep level value
		ld	b, (ix+8)
		ld	a, (ix+2)
		or	a
		jr	z, Release_Key	; if counter = 0, jump to release key part
		bit	7, b
		jr	nz, loc_F88	; jump if byte 08 bit 7	= 1
		cp	(ix+6)
		jr	nz, loc_F88	; or if	byte 02	!= byte	06

Release_Key:				; CODE XREF: PSG_ParseNoiseData+E4j
		ld	a, b
		or	a
		jr	nz, loc_F88	; leave	if byte	08 != 0
		ld	c, 1
		ld	(ix+1Eh), c	; set byte 1E to "release key" before next note
		or	2
		ld	(ix+8),	a	; byte 08 = $03

loc_F78:				; CODE XREF: PSG_ParseNoiseData+108j
		call	PSG_GetInstrumentPointer
		ld	a, (hl)
		and	80h ; '�'
		jr	nz, loc_F85	; increment relative pointer until pointed byte's bit 7 = 1
		inc	(ix+12h)
		jr	loc_F78
; ---------------------------------------------------------------------------

loc_F85:				; CODE XREF: PSG_ParseNoiseData+103j
		inc	(ix+12h)	; now byte 12 points to	instrument release data

loc_F88:				; CODE XREF: PSG_ParseNoiseData+E8j
					; PSG_ParseNoiseData+EDj
					; PSG_ParseNoiseData+F1j
		ld	a, (FADE_OUT_TIMER) ; Starts with fade out length value, decrements at each YM Timer overflow. set to $63 while	loading	music
		or	a
		jr	nz, Transmit_Attenuation
		ld	a, (ix+4)
		or	a
		jr	z, Transmit_Attenuation
		dec	a		; decrement level if currently fading out and fade out timer = 0
		ld	(ix+4),	a

Transmit_Attenuation:			; CODE XREF: PSG_ParseNoiseData+111j
					; PSG_ParseNoiseData+117j
					
					; Conditional input to implement here !
					
		ld	a, 0Fh
		sub	(ix+5)		; get sound level and invert it	to get sound attenuation
		or	0F0h ; '�'      ; add attenuation command bits
		call	PSG_ConditionnalInput	; transmit attenuation
		ret
; End of function PSG_ParseNoiseData