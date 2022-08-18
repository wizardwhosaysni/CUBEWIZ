; =============== S U B	R O U T	I N E =======================================


YM2_ParseData:				; CODE XREF: UpdateSound+88p
					; UpdateSound+8Ep UpdateSound+B9p
					; UpdateSound+BFp
					; YM2_ParseChannel6Data+15j
		ld	a, (iy+0)	; exactly the same general behaviour as	YM1_ParseData, with access to YM2 instead
		ld	ix, MUSIC_CHANNEL_YM4
		push	af
		add	a, a
		add	a, a
		add	a, a
		add	a, a		; a = 10h * a
		ld	d, a		; d = 10h * a
		add	a, a		; a = 20h * a
		add	a, d		; a = 30h * a
		ld	d, 0
		ld	e, a
		add	ix, de
		ld	a, (CURRENTLY_MANAGING_SFX) 
		or	a
		jr	z, loc_7AE
		ld	de, 01E0h ; '�'  ; point to the right SFX channel data
		add	ix, de

loc_7AE:				; CODE XREF: YM2_ParseData+16j
		pop	af
		ld	c, 0A0h	; '�'
		add	a, c
		ld	(loc_9D7+1), a
		ld	c, 4
		add	a, c
		ld	(loc_9CE+1), a

loc_7BB:				; CODE XREF: YM2_ParseData+170j
		ld	a, (ix+3)
		or	a
		ret	nz
		ld	a, (ix+6)
		cp	(ix+2)
		jr	nz, loc_7D9
		ld	a, (ix+8)
		or	a
		jr	nz, loc_7D9
		ld	b, 28h ; '('    ; YM register : Key on/off
		ld	a, (iy+0)
		add	a, 4
		ld	c, a
		call	YM1_ConditionnalInput

loc_7D9:				; CODE XREF: YM2_ParseData+35j
					; YM2_ParseData+3Bj
		ld	a, (ix+2)
		or	a
		jp	nz, loc_904
		ld	d, (ix+1)
		ld	e, (ix+0)

loc_7E6:				; CODE XREF: YM2_ParseData+A8j
					; YM2_ParseData+B4j YM2_ParseData+C3j
					; YM2_ParseData+CDj YM2_ParseData+D7j
					; YM2_ParseData+E1j YM2_ParseData+EBj
					; YM2_ParseData+F5j YM2_ParseData+FAj
		xor	a
		ld	(ix+0Dh), a
		ld	a, (ix+9)
		ld	(ix+0Ah), a
		ld	a, (de)
		and	0F8h ; '�'
		cp	0F8h ; '�'
		jp	nz, loc_88E
		ld	a, (de)
		cp	0FFh
		jp	nz, setInstrument
		inc	de
		ld	a, (de)
		ld	l, a
		inc	de
		ld	a, (de)
		ld	h, a
		or	l
		jr	nz, loc_838	; jump if FF xx	xx
		ld	a, 1		; else,	end of data for	this channel
		ld	(ix+3),	a
		ld	a, (CURRENTLY_MANAGING_SFX) 
		or	a
		jr	z, loc_834
		ld	bc, 0FE20h	; if an	SFX was	being managed, go back to corresponding	music channel
		add	ix, bc
		ld	a, 0B4h	; '�'   ; YM Register : Stereo / LFO Sensitivity
		;ld	(DAC_REMAINING_LENGTH), ix
		add	a, (iy+0)
		ld	b, a
		ld	c, (ix+1Eh)	; load corresponding music channel stereo setting
		call	YM2_Input
		ld	a, (ix+3)
		or	a
		jr	nz, loc_834
		ld	a, (ix+4)	; if corresponding music channel in use, load its instrument, and return
		jp	YM2_LoadInstrument
; ---------------------------------------------------------------------------

loc_834:				; CODE XREF: YM2_ParseData+84j
					; YM2_ParseData+9Bj
		xor	a
		jp	YM2_LoadInstrument
; ---------------------------------------------------------------------------

loc_838:				; CODE XREF: YM2_ParseData+74j
		ex	de, hl
		jr	loc_7E6
; ---------------------------------------------------------------------------

setInstrument:				; CODE XREF: YM2_ParseData+6Aj
		cp	0FEh ; '�'
		jr	nz, loc_848
		inc	de
		ld	a, (de)
		call	YM2_setChannelInstrument
		inc	de
		jp	loc_7E6
; ---------------------------------------------------------------------------

loc_848:				; CODE XREF: YM2_ParseData+ACj
		cp	0FDh ; '�'
		jr	nz, loc_857
		inc	de
		ld	a, (de)
		and	0Fh
		call	YM2_LoadInstrument
		inc	de
		jp	loc_7E6
; ---------------------------------------------------------------------------

loc_857:				; CODE XREF: YM2_ParseData+B9j
		cp	0FCh ; '�'
		jr	nz, loc_861
		call	YM_SetSlideOrKeyRelease
		jp	loc_7E6
; ---------------------------------------------------------------------------

loc_861:				; CODE XREF: YM2_ParseData+C8j
		cp	0FBh ; '�'
		jr	nz, loc_86B
		call	LoadVibrato
		jp	loc_7E6
; ---------------------------------------------------------------------------

loc_86B:				; CODE XREF: YM2_ParseData+D2j
		cp	0FAh ; '�'
		jr	nz, loc_875
		call	YM2_SetStereo
		jp	loc_7E6
; ---------------------------------------------------------------------------

loc_875:				; CODE XREF: YM2_ParseData+DCj
		cp	0F9h ; '�'
		jr	nz, loc_87F
		call	LoadNoteShift
		jp	loc_7E6
; ---------------------------------------------------------------------------

loc_87F:				; CODE XREF: YM2_ParseData+E6j
		cp	0F8h ; '�'
		jr	nz, loc_889
		call	ParseLoopCommand
		jp	loc_7E6
; ---------------------------------------------------------------------------

loc_889:				; CODE XREF: YM2_ParseData+F0j
		inc	de
		inc	de
		jp	loc_7E6
; ---------------------------------------------------------------------------

loc_88E:				; CODE XREF: YM2_ParseData+64j
		ld	a, (de)
		and	7Fh ; ''
		cp	70h ; 'p'
		jp	z, loc_8E8
		add	a, (ix+1Ch)	; index
		ld	l, a
		ld	h, 0
		ld	bc, t_YM_FREQUENCIES ; these words are not pointers, they are the two frequency	bytes to send to YM for	a given	note
		add	hl, hl
		add	hl, bc
		ld	a, (hl)
		dec	hl
		ld	l, (hl)
		ld	h, a		; hl = corresponding word
		ld	b, 0
		ld	c, (ix+1Dh)
		add	hl, bc
		ld	a, (loc_774+1)
		ld	b, a
		ld	c, h
		ld	(ix+12h), c
		ld	a, (ix+1Fh)
		or	a
		jr	nz, loc_8C0
		ld	(ix+0Fh), c
		xor	a
		ld	(ix+12h), a

loc_8C0:				; CODE XREF: YM2_ParseData+126j
		call	YM2_ConditionalInput
		ld	a, (loc_77D+1)	; dynamically changed :	1st frequency register to use corresponding to current channel
		ld	b, a
		ld	c, l
		ld	(ix+11h), c
		ld	a, (ix+1Fh)
		or	a
		jr	nz, loc_8D8
		ld	(ix+0Eh), c
		xor	a
		ld	(ix+11h), a

loc_8D8:				; CODE XREF: YM2_ParseData+13Ej
		call	YM2_ConditionalInput
		ld	b, 28h ; '('    ; YM register : Key on/off
		ld	a, (iy+0)
		add	a, 4
		or	0F0h ; '�'
		ld	c, a
		call	YM1_ConditionnalInput

loc_8E8:				; CODE XREF: YM2_ParseData+102j
		ld	a, (de)
		bit	7, a
		jr	nz, loc_8F2
		ld	a, (ix+7)
		jr	loc_8F7
; ---------------------------------------------------------------------------

loc_8F2:				; CODE XREF: YM2_ParseData+15Aj
		inc	de
		ld	a, (de)
		ld	(ix+7),	a

loc_8F7:				; CODE XREF: YM2_ParseData+15Fj
		ld	(ix+2),	a
		inc	de
		ld	(ix+1),	d
		ld	(ix+0),	e
		jp	loc_7BB
; ---------------------------------------------------------------------------

loc_904:				; CODE XREF: YM2_ParseData+4Cj
		dec	(ix+2)
		ld	b, (ix+12h)
		ld	c, (ix+11h)
		ld	a, b
		or	c
		jr	z, loc_988
		ld	a, (ix+0Fh)
		ld	h, a
		ld	a, (ix+0Eh)
		ld	l, a
		push	bc
		push	hl
		or	a
		sbc	hl, bc
		ld	a, h
		ld	(TEMP_FREQUENCY), a ; temp space to store frequency values when	YM data	is parsed
		jr	nc, loc_92C
		ld	b, 0
		ld	c, (ix+1Fh)
		jp	loc_934
; ---------------------------------------------------------------------------

loc_92C:				; CODE XREF: YM2_ParseData+191j
		ld	b, 0FFh
		ld	a, (ix+1Fh)
		neg
		ld	c, a

loc_934:				; CODE XREF: YM2_ParseData+198j
		pop	hl
		add	hl, bc
		pop	bc
		push	hl
		or	a
		sbc	hl, bc
		ld	a, (TEMP_FREQUENCY) ; temp space to store frequency values when	YM data	is parsed
		xor	h
		bit	7, a
		pop	hl
		jr	nz, loc_97B
		push	hl
		ld	a, h
		and	7
		ld	h, a
		ld	(TEMP_FREQUENCY), hl ; temp space to store frequency values when YM data is parsed
		ld	bc, 4D4h
		or	a
		sbc	hl, bc
		jr	c, loc_95A
		ld	bc, 596h
		jp	loc_96E
; ---------------------------------------------------------------------------

loc_95A:				; CODE XREF: YM2_ParseData+1C1j
		ld	hl, (TEMP_FREQUENCY) ; temp space to store frequency values when YM data is parsed
		ld	bc, 26Ah
		or	a
		sbc	hl, bc
		jr	nc, loc_96B
		ld	bc, 0FA6Ah
		jp	loc_96E
; ---------------------------------------------------------------------------

loc_96B:				; CODE XREF: YM2_ParseData+1D2j
		ld	bc, 0

loc_96E:				; CODE XREF: YM2_ParseData+1C6j
					; YM2_ParseData+1D7j
		pop	hl
		add	hl, bc
		ld	a, h
		ld	(ix+0Fh), a
		ld	a, l
		ld	(ix+0Eh), a
		jp	loc_988
; ---------------------------------------------------------------------------

loc_97B:				; CODE XREF: YM2_ParseData+1B1j
		ld	(ix+0Fh), b
		ld	(ix+0Eh), c
		xor	a
		ld	(ix+11h), a
		ld	(ix+12h), a

loc_988:				; CODE XREF: YM2_ParseData+17Ej
					; YM2_ParseData+1E7j
		ld	a, (ix+0Ah)
		or	a
		jr	z, loc_994
		dec	(ix+0Ah)
		xor	a
		jr	loc_9BD
; ---------------------------------------------------------------------------

loc_994:				; CODE XREF: YM2_ParseData+1FBj
					; YM2_ParseData+229j
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
		jr	nz, loc_9B1
		dec	(ix+0Dh)
		xor	a
		jr	loc_9BD
; ---------------------------------------------------------------------------

loc_9B1:				; CODE XREF: YM2_ParseData+218j
		cp	80h ; '�'
		jp	nz, loc_9BD
		xor	a
		ld	(ix+0Dh), a
		jp	loc_994
; ---------------------------------------------------------------------------

loc_9BD:				; CODE XREF: YM2_ParseData+201j
					; YM2_ParseData+21Ej
					; YM2_ParseData+222j
		ld	c, a
		ld	a, (ix+0Eh)
		ld	l, a
		ld	a, (ix+0Fh)
		ld	h, a
		ld	b, 0
		bit	7, c
		jr	z, loc_9CD
		dec	b

loc_9CD:				; CODE XREF: YM2_ParseData+239j
		add	hl, bc

loc_9CE:				; DATA XREF: YM2_ParseData+27w
		ld	b, 0
		ld	c, h
		ld	(ix+0Fh), c
		call	YM2_ConditionalInput

loc_9D7:				; DATA XREF: YM2_ParseData+21w
		ld	b, 0
		ld	c, l
		ld	(ix+0Eh), c
		call	YM2_ConditionalInput
		ld	a, (CURRENTLY_MANAGING_SFX) 
		or	a
		ret	nz
		ld	a, (FADE_OUT_TIMER) ; Starts with fade out length value, decrements at each YM Timer overflow. set to $63 while	loading	music
		or	a
		ret	nz
		ld	a, (ix+4)
		jp	YM2_LoadInstrument
; End of function YM2_ParseData