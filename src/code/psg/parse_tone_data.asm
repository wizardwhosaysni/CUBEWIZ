; =============== S U B	R O U T	I N E =======================================


PSG_ParseToneData:			; CODE XREF: UpdateSound+9Bp
					; UpdateSound+A1p UpdateSound+A7p

; FUNCTION CHUNK AT 0536 SIZE 0000000D BYTES

		ld	a, (iy+0)	; a = index of currently managed channel
		ld	ix, MUSIC_CHANNEL_PSG1 ; start of PSG channel data
		ld	h, 0
		ld	l, a
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl		; hl = 10h * a
		push	bc
		ld	b, h
		ld	c, l 
		add	hl, hl		; hl = 20h * a
		add	hl, bc		; hl = 30h * a
		pop	bc
		ex	de, hl
		add	ix, de		; ix now points	to concerned channel	
		rrca
		rrca
		rrca			; channel value	now in right place to make a PSG command
		and	60h ; '`'       ; make sure only the two interesting bits are used
		ld	(CURRENT_PSG_CHANNEL), a ; save	channel	number stored in that way
		ld	a, (CURRENTLY_MANAGING_SFX) 
		or	a
		jr	z, loc_C50
		ld	de, 01E0h ; '�'  ; point to the right SFX channel data
		add	ix, de			

loc_C50:				; CODE XREF: PSG_ParseToneData+106j
		ld	a, (ix+3)	; get byte 3 of	channel	data
		or	a
		ret	nz		; return if channel has	nothing	to do
		ld	a, (ix+2)	; get time counter
		or	a
		jp	nz, loc_D3F	; don't jump if it's time to parse next byte
		ld	d, (ix+1)	; if counter = 0, parse	next byte
		ld	e, (ix+0)	; load channel data pointer

loc_C62:				; CODE XREF: PSG_ParseToneData+53j
					; PSG_ParseToneData+5Cj
					; PSG_ParseToneData+66j
					; PSG_ParseToneData+70j
					; PSG_ParseToneData+80j
					; PSG_ParseToneData+8Aj
					; PSG_ParseToneData+94j
					; PSG_ParseToneData+99j
		ld	a, (de)		; get pointed data
		and	0F8h ; '�'
		cp	0F8h ; '�'
		jp	nz, loc_CD2	; if byte is not a command
		ld	a, (de)		; get byte again
		cp	0FFh
		jp	nz, loc_C8B	; if a != FF check other possible command values
		inc	de		; a = FF
		ld	a, (de)
		ld	l, a
		inc	de
		ld	a, (de)
		ld	h, a
		or	l
		jr	nz, PSG_Parse_At_New_Offset ; FF xx xx,	go parse at new	offset xxxx
		ld	a, 1		; FF 00	00, end	of data, mute channel and return
		ld	(ix+3),	a	; byte 3 of channel data = 1
		
					; doubt : if finishing SFX, do I need to update with music data ? like for YM ? We'll see
				
		ld	a, 0Fh
		jp	PSG_SetChannelAttenuation ; concerned channel volume : OFF
; ---------------------------------------------------------------------------

PSG_Parse_At_New_Offset:		; CODE XREF: PSG_ParseToneData+41j
		ex	de, hl
		jr	loc_C62		; get pointed data
; ---------------------------------------------------------------------------

loc_C8B:				; CODE XREF: PSG_ParseToneData+37j
		cp	0FDh ; '�'
		jr	nz, loc_C95
		call	PSG_LoadInstrument
		jp	loc_C62		; get pointed data
; ---------------------------------------------------------------------------

loc_C95:				; CODE XREF: PSG_ParseToneData+57j
		cp	0FCh ; '�'
		jr	nz, loc_C9F
		call	SetRelease
		jp	loc_C62		; get pointed data
; ---------------------------------------------------------------------------

loc_C9F:				; CODE XREF: PSG_ParseToneData+61j
		cp	0FBh ; '�'
		jr	nz, Set_Timer
		call	LoadVibrato
		jp	loc_C62		; get pointed data
; ---------------------------------------------------------------------------

Set_Timer:				; CODE XREF: PSG_ParseToneData+6Bj
		cp	0FAh ; '�'
		jr	nz, loc_CB9
		inc	de
		ld	b, 26h ; '&'    ; YM Register : Timer B value
		ld	a, (de)
		ld	c, a
		inc	de
		call	ApplyYm1Input
		jp	loc_C62		; get pointed data
; ---------------------------------------------------------------------------

loc_CB9:				; CODE XREF: PSG_ParseToneData+75j
		cp	0F9h ; '�'
		jr	nz, loc_CC3
		call	LoadNoteShift
		jp	loc_C62		; get pointed data
; ---------------------------------------------------------------------------

loc_CC3:				; CODE XREF: PSG_ParseToneData+85j
		cp	0F8h ; '�'
		jr	nz, unidentifiedCommand	; Unidentified_Command
		call	ParseLoopCommand
		jp	loc_C62		; get pointed data
; ---------------------------------------------------------------------------

unidentifiedCommand:			; CODE XREF: PSG_ParseToneData+8Fj
		inc	de		; Unidentified_Command
		inc	de
		jp	loc_C62		; get pointed data
; ---------------------------------------------------------------------------

loc_CD2:				; CODE XREF: PSG_ParseToneData+31j
		ld	a, (de)		; byte is not a	command
		and	7Fh ; ''
		cp	70h ; 'p'
		jp	z, loc_D1B	; jump if byte = F0 or 70
		push	af		; keep byte without bit	7 : new	note
		ld	a, (ix+1Eh)
		or	a
		jr	z, Set_New_Note	; jump if byte 1E = 0. Byte 1E is set when key has just	been released
		xor	a		; key has just been released
		ld	(ix+12h), a	; reset	instrument relative pointer
		ld	(ix+1Eh), a	; clear	byte 1E
		ld	a, (ix+9)	; reset	vibrato	counter
		ld	(ix+0Ah), a

Set_New_Note:				; CODE XREF: PSG_ParseToneData+A9j
		xor	a
		ld	(ix+0Dh), a	; reset	vibrato	relative pointer
		pop	af		; get back byte	without	bit 7
		add	a, (ix+1Ch)	; add note shift value
		sub	15h
		ld	l, a
		ld	h, 0
		ld	bc, PSG_FREQUENCIES ;	PSG Frequency table, same idea as YM Frequency table but for PSG Tone Channels
		add	hl, hl
		add	hl, bc
		ld	a, (hl)
		inc	hl
		ld	h, (hl)
		ld	l, a		; hl = corresponding frequency
		ld	b, 0
		ld	c, (ix+1Dh)
		srl	c
		add	hl, bc		; add frequency	shift value
		ld	c, l
		ld	(ix+0Eh), c	; keep frequency value to play
		ld	c, h
		ld	(ix+0Fh), c
		ld	a, (ix+8)
		and	80h ; '�'       ; keep only bit 7
		jr	loc_D20
; ---------------------------------------------------------------------------

loc_D1B:				; CODE XREF: PSG_ParseToneData+A1j
		ld	a, (ix+8)	; if byte = F0 or 70
		or	1		; set bit 0

loc_D20:				; CODE XREF: PSG_ParseToneData+E3j
		ld	(ix+8),	a
		ld	a, (de)		; get full byte	again
		bit	7, a
		jr	nz, loc_D2D	; if bit 7 = 1,	set note length
		ld	a, (ix+7)
		jr	loc_D32		; reset	time counter
; ---------------------------------------------------------------------------

loc_D2D:				; CODE XREF: PSG_ParseToneData+F0j
		inc	de
		ld	a, (de)
		ld	(ix+7),	a	; set new note length

loc_D32:				; CODE XREF: PSG_ParseToneData+F5j
		ld	(ix+2),	a	; reset	time counter
		inc	de
		ld	(ix+1),	d	; save offset of next byte to parse
		ld	(ix+0),	e
		jp	loc_C50		; get byte 3 of	channel	data
; ---------------------------------------------------------------------------

loc_D3F:				; CODE XREF: PSG_ParseToneData+23j
		dec	(ix+2)		; decrement counter
		ld	a, (ix+0Ah)
		or	a
		jr	z, Apply_Vibrato ; jump	if vibrato must	be applied
		dec	(ix+0Ah)	; decrement vibrato counter
		xor	a
		jr	loc_D76
; ---------------------------------------------------------------------------

Apply_Vibrato:				; CODE XREF: PSG_ParseToneData+110j
					; PSG_ParseToneData+13Dj
		ld	a, (ix+0Ch)
		ld	h, a
		ld	a, (ix+0Bh)
		ld	l, a
		ld	a, (ix+0Dh)
		ld	b, 0
		ld	c, a
		inc	(ix+0Dh)
		add	hl, bc
		ld	a, (hl)
		cp	81h ; '�'
		jr	nz, loc_D6A
		dec	(ix+0Dh)
		jr	loc_D91		; THIS PART will change	the level depending on the PSG Instrument
; ---------------------------------------------------------------------------

loc_D6A:				; CODE XREF: PSG_ParseToneData+12Dj
		cp	80h ; '�'
		jp	nz, loc_D76
		xor	a
		ld	(ix+0Dh), a
		jp	Apply_Vibrato
; ---------------------------------------------------------------------------

loc_D76:				; CODE XREF: PSG_ParseToneData+116j
					; PSG_ParseToneData+136j
		neg
		ld	c, a
		ld	a, (ix+0Eh)
		ld	l, a
		ld	a, (ix+0Fh)
		ld	h, a
		ld	b, 0
		bit	7, c
		jr	z, loc_D88
		dec	b

loc_D88:				; CODE XREF: PSG_ParseToneData+14Fj
		add	hl, bc
		ld	a, h
		ld	(ix+0Fh), a
		ld	a, l
		ld	(ix+0Eh), a	; now vibrato is applied

loc_D91:				; CODE XREF: PSG_ParseToneData+132j
		call	PSG_GetInstrumentPointer ; THIS	PART will change the level depending on	the PSG	Instrument
		ld	b, (hl)		; byte b = 8x or 0x
		bit	7, b
		jr	nz, loc_D9D	; if byte $8x, then it's data end, so just keep applying the same level alteration
		inc	a		; if byte 0x, point to next byte
		ld	(ix+12h), a

loc_D9D:				; CODE XREF: PSG_ParseToneData+161j
		res	7, b		; keep x only
		ld	a, 0Fh
		sub	b
		ld	b, a
		ld	a, (ix+4)
		sub	b		; a = level affected by	instrument
		jr	nc, loc_DAA	; make sure value is at	least 0
		xor	a

loc_DAA:				; CODE XREF: PSG_ParseToneData+171j
		ld	b, a		; put level to apply in	b
		ld	a, (iy+0)
		cp	2
		jr	nz, loc_DB6	; jump if it's PSG Tone 1 or 2 Channels
		ld	a, 0Fh		; if PSG Tone 3	Channel, apply max level
		jr	loc_DB9
; ---------------------------------------------------------------------------

loc_DB6:				; CODE XREF: PSG_ParseToneData+17Aj
		ld	a, (MUSIC_LEVEL) ; general output level	for music and SFX type 1, sent from 68k

loc_DB9:				; CODE XREF: PSG_ParseToneData+17Ej
		add	a, b
		sub	0Fh
		jr	nc, loc_DBF	; make sure level is at	least 0
		xor	a

loc_DBF:				; CODE XREF: PSG_ParseToneData+186j
		ld	(ix+5),	a	; store	level to apply in byte 05
		ld	b, (ix+8)
		ld	a, (ix+2)
		or	a
		jr	z, PSG_Release_Key ; if	counter	= 0, jump to release key part
		bit	7, b
		jr	nz, loc_DF2	; jump if byte 08 bit 7	= 1
		cp	(ix+6)
		jr	nz, loc_DF2	; or if	byte 02	!= byte	06

PSG_Release_Key:			; CODE XREF: PSG_ParseToneData+193j
		ld	a, b
		or	a
		jr	nz, loc_DF2	; leave	if byte	08 != 0
		ld	c, 1
		ld	(ix+1Eh), c	; set byte 1E to "release key" before next note
		or	2
		ld	(ix+8),	a	; byte 08 = $03

loc_DE2:				; CODE XREF: PSG_ParseToneData+1B7j
		call	PSG_GetInstrumentPointer
		ld	a, (hl)
		and	80h ; '�'
		jr	nz, loc_DEF	; increment relative pointer until pointed byte's bit 7 = 1
		inc	(ix+12h)
		jr	loc_DE2
; ---------------------------------------------------------------------------

loc_DEF:				; CODE XREF: PSG_ParseToneData+1B2j
		inc	(ix+12h)	; now byte 12 points to	instrument release data

loc_DF2:				; CODE XREF: PSG_ParseToneData+197j
					; PSG_ParseToneData+19Cj
					; PSG_ParseToneData+1A0j
		ld	a, (FADE_OUT_TIMER) ; Starts with fade out length value, decrements at each YM Timer overflow. set to $63 while	loading	music
		or	a
		jr	nz, Transmit_Data ; transmit Frequency data to PSG
		ld	a, (iy+0)
		cp	2
		jr	z, Transmit_Data ; jump	if currently managing PSG Tone 3 Channel
		ld	a, (ix+4)
		or	a
		jr	z, Transmit_Data ; transmit Frequency data to PSG
		dec	a		; decrement level if currently fading out and fade out timer = 0
		ld	(ix+4),	a

Transmit_Data:				; CODE XREF: PSG_ParseToneData+1C0j
					; PSG_ParseToneData+1C7j
					; PSG_ParseToneData+1CDj
					
					; Conditionnal input to implement here !
					
					
		ld	a, (ix+0Fh)	; transmit Frequency data to PSG
		ld	b, a
		ld	a, (ix+0Eh)
		ld	c, a
		and	0Fh
		ld	h, a
		ld	a, (CURRENT_PSG_CHANNEL) ; current PSG channel to process, stored in the right bits ready to be	sent to	PSG
		or	h
		or	80h ; '�'
		call	PSG_ConditionnalInput	; first	byte of	tone channel frequency command
		ld	a, c
		srl	b
		rra
		srl	b
		rra
		rra
		rra
		and	3Fh ; '?'
		call	PSG_ConditionnalInput	; second byte of tone channel frequency	command
		ld	a, 0Fh		; starting attenuation value
		sub	(ix+5)		; get level to apply
		ld	h, a		; save it
		ld	a, (CURRENT_PSG_CHANNEL) ; get channel number
		or	h		; load saved value
		or	90h ; '�'       ; load attenuation command bits
		call	PSG_ConditionnalInput
		ret
; End of function PSG_ParseToneData