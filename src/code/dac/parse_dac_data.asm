; =============== S U B	R O U T	I N E =======================================


YM2_ParseChannel6Data:			; CODE XREF: UpdateSound+94p
					; UpdateSound+C5p
		ld	ix, MUSIC_CHANNEL_YM6
		ld	a, (CURRENTLY_MANAGING_SFX) 
		or	a
		jr	z, loc_B68
		ld	de, 01E0h ; '�'  ; if we are currently managing an SFX using the 3 extra RAM areas, point to the right area
		add	ix, de
		jr	loc_B6F		; then don't even check if it uses DAC samples ... so for that kind of SFX, always use DAC ?
; ---------------------------------------------------------------------------

loc_B68:				; CODE XREF: YM2_ParseChannel6Data+8j
		ld	a, (MUSIC_DOESNT_USE_SAMPLES)
		or	a	
		jp	nz, YM2_ParseData ; jump to classic parsing subroutine if channel 6 is not in DAC mode

loc_B6F:				; CODE XREF: YM2_ParseChannel6Data+Fj
					; YM2_ParseChannel6Data+D3j
		ld	a, (ix+3)	; check	with byte 3 if channel 3 has something to do or	not
		or	a
		ret	nz		
		ld	a, (ix+6)	; check	if time	counter	02 has reached key release value 06
		cp	(ix+2)
		jr	nz, loc_B87	; check	if it's time to parse new data or not yet
		ld	a, (ix+8)	; check	if "don't release key" byte 08 is set
		or	a
		jr	nz, loc_B87	; don't jump if byte 02 = byte 06 and byte 08 = 0
		ld	a, 0FEh	; '�'
		call	DAC_SetNewSample ; play	nothing	!

loc_B87:				; CODE XREF: YM2_ParseChannel6Data+23j
					; YM2_ParseChannel6Data+29j
		ld	a, (ix+2)	; check	if it's time to parse new data or not yet
		or	a
		jp	nz, loc_C2D	; if it's not end of sample play, decrement counter and return
		ld	d, (ix+1)	; get data pointer
		ld	e, (ix+0)

parseByte:				; CODE XREF: YM2_ParseChannel6Data+89j
					; YM2_ParseChannel6Data+92j
					; YM2_ParseChannel6Data+9Cj
					; YM2_ParseChannel6Data+A6j
					; YM2_ParseChannel6Data+ABj
		ld	a, (de)		; get data to parse
		and	0F8h ; '�'

loc_B97:
		cp	0F8h ; '�'
		jp	nz, loc_C05	; jump if it's not a command
		ld	a, (de)		; else,	parse command
		cp	0FFh
		jp	nz, setKeyRelease ; jump if command is not FF
		inc	de		; if command is	FF, parse next bytes
		ld	a, (de)
		ld	l, a
		inc	de
		ld	a, (de)
		ld	h, a
		or	l
		jr	nz, parseAtNewOffset ; jump when it's FF xx xx, meaning "parse from new offset xxxx"
		ld	a, 1		; else,	you have FF 00 00, so end parsing and mute channel
		ld	(ix+3),	a
		ld	a, (MUSIC_DOESNT_USE_SAMPLES)
		or	a
		jr	z, return_BDE	; if music uses	DAC samples, return
		ld	a, (CURRENTLY_MANAGING_SFX) 
		or	a
		jr	z, return_BDE	; if it's not managing an SFX, return
		ld	bc, 0FE20h	; go back to YM	Channel	6 area
		add	ix, bc
		ld	a, 0B4h	; '�'   ; YM Register : Stereo / LFO Sensitivity
		add	a, (iy+0)
		ld	b, a

loc_BCC:
		ld	c, (ix+1Eh)
		call	YM2_Input	; set stereo
		ld	a, (ix+3)
		or	a
		jr	nz, return_BDE	; return if channel has	nothing	to do
		ld	a, (ix+4)
		jp	YM2_LoadInstrument ; else, load	note and return
; ---------------------------------------------------------------------------

return_BDE:				; CODE XREF: YM2_ParseChannel6Data+62j
					; YM2_ParseChannel6Data+68j
					; YM2_ParseChannel6Data+7Fj
		ret
; ---------------------------------------------------------------------------

parseAtNewOffset:			; CODE XREF: YM2_ParseChannel6Data+52j
		ex	de, hl
		jr	parseByte	; get data to parse
; ---------------------------------------------------------------------------

setKeyRelease:				; CODE XREF: YM2_ParseChannel6Data+48j
		cp	0FCh ; '�'
		jr	nz, setStereo
		call	SetRelease
		jp	parseByte	; get data to parse
; ---------------------------------------------------------------------------

setStereo:				; CODE XREF: YM2_ParseChannel6Data+8Dj
		cp	0FAh ; '�'
		jr	nz, loopCommand
		call	YM2_SetStereo
		jp	parseByte	; get data to parse
; ---------------------------------------------------------------------------

loopCommand:				; CODE XREF: YM2_ParseChannel6Data+97j
		cp	0F8h ; '�'
		jr	nz, ifCommandUnidentified
		call	ParseLoopCommand
		jp	parseByte	; get data to parse
; ---------------------------------------------------------------------------

ifCommandUnidentified:			; CODE XREF: YM2_ParseChannel6Data+A1j
		inc	de
		inc	de
		jp	parseByte	; get data to parse
; ---------------------------------------------------------------------------

loc_C05:				; CODE XREF: YM2_ParseChannel6Data+42j
		ld	a, (de)		; parsed byte is not a command
		and	7Fh ; ''

loc_C08:
		cp	70h ; 'p'
		jp	z, loc_C11	; if byte is F0	or 70
		inc	a		; else,	it's a new sample index : bits 6-0 + 1
		call	DAC_SetNewSample

loc_C11:				; CODE XREF: YM2_ParseChannel6Data+B3j
		ld	a, (de)
		bit	7, a		; if bit 7 = 1,	then next byte is sample play length
		jr	nz, loc_C1B	; get sample play length byte
		ld	a, (ix+7)	; else,	load current sample play length
		jr	loc_C20		; restart counter with sample play length value
; ---------------------------------------------------------------------------

loc_C1B:				; CODE XREF: YM2_ParseChannel6Data+BDj
		inc	de		; get sample play length byte
		ld	a, (de)
		ld	(ix+7),	a	; set new sample play length

loc_C20:				; CODE XREF: YM2_ParseChannel6Data+C2j
		ld	(ix+2),	a	; restart counter with sample play length value
		inc	de
		ld	(ix+1),	d	; point	to next	byte to	parse
		ld	(ix+0),	e
		jp	loc_B6F		; go back to the beginning of subroutine
; ---------------------------------------------------------------------------

loc_C2D:				; CODE XREF: YM2_ParseChannel6Data+34j
		dec	(ix+2)		; if it's not end of sample play, decrement counter and return
		ld	a, (FADE_OUT_TIMER) ; Starts with fade out length value, decrements at each YM Timer overflow. set to $63 while	loading	music
		or	a
		ret	nz		; return in any	way !
		ret
; End of function YM2_ParseChannel6Data