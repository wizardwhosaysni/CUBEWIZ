; =============== S U B	R O U T	I N E =======================================


YM1_ParseData:				; CODE XREF: UpdateSound+70p
					; UpdateSound+76p UpdateSound+7Cp
		ld	a, (iy+0)	; iy : channel to process
		ld	ix, MUSIC_CHANNEL_YM1
		push	af
		add	a, a		; THIS PART just inits iy, ix, and frequency registers
		add	a, a
		add	a, a
		add	a, a		; a = 10h * a
		ld	d, a		; d = 10h * a
		add	a, a		; a = 20h * a
		add	a, d		; a = 30h * a
		ld	d, 0
		ld	e, a
		add	ix, de		; point	to appropriate channel ram data
		ld	a, (CURRENTLY_MANAGING_SFX) 
		or	a
		jr	z, loc_nimp
		ld	de, 01E0h ; '�'  ; point to the right SFX channel data
		add	ix, de
loc_nimp:				
		pop	af
		ld	c, 0A0h	; '�'
		add	a, c		; A0 + channel number :	first input address of frequency  register
		ld	(loc_77D+1), a	; parameter directly moved to code in ram !
		ld	c, 4
		add	a, c		; (0x77E) + 4 :	second input address of	frequency register
		ld	(loc_774+1), a	; parameter directly moved to code in ram !

loc_586:				; CODE XREF: YM1_ParseData+140j
		ld	a, (ix+3)	; THIS PART checks if the channel actually has to be used or not
		or	a
		ret	nz		; if byte 3 = 1, do nothing with this channel
		ld	a, (ix+6)	; THIS PART seems to check if it's time to release key or not yet
		cp	(ix+2)
		jr	nz, loc_5A2	; if bytes 2 !=	byte 6,	then it's not yet the end of note
		ld	a, (ix+8)	; if byte 2 = byte 6, end of note counter, check byte 8
		or	a
		jr	nz, loc_5A2	; if byte 8 != 0
		ld	b, 28h ; '('    ; so if (byte 2 = byte 6) and (byte 8 = 0), set key off
		ld	a, (iy+0)	; concerned channel
		ld	c, a
		call	YM1_ConditionnalInput	; set key OFF

loc_5A2:				; CODE XREF: YM1_ParseData+2Aj
					; YM1_ParseData+30j
		ld	a, (ix+2)	; THIS PART checks if it's time to parse new music data or not yet (I think)
		or	a
		jp	nz, loc_6AA	; if byte 2 != 0
		ld	d, (ix+1)
		ld	e, (ix+0)	; get ROM offset of next byte to parse

Parsing_Start:				; CODE XREF: YM1_ParseData+7Aj
					; YM1_ParseData+86j YM1_ParseData+95j
					; YM1_ParseData+9Fj YM1_ParseData+A9j
					; YM1_ParseData+B3j YM1_ParseData+BDj
					; YM1_ParseData+C7j YM1_ParseData+CCj
		xor	a		; THIS PART checks if parsed byte is a command or a parameter
		ld	(ix+0Dh), a	; clear	vibrato	relative pointer
		ld	a, (ix+9)
		ld	(ix+0Ah), a	; load time counter before vibrato
		ld	a, (de)		; get pointed byte in rom
		and	0F8h ; '�'      ; keep only bits 7-3
		cp	0F8h ; '�'
		jp	nz, loc_636	; if kept bits of pointed byte != F8, so if data byte is not a command
		ld	a, (de)		; else,	value of pointed rom byte is a command
		cp	0FFh
		jp	nz, Set_Instrument ; if	pointed	byte !=	FF, go test other possible command values
		inc	de		; if pointed rom byte =	FF, then get next two bytes
		ld	a, (de)		; THIS PART handles an FF command
		ld	l, a
		inc	de
		ld	a, (de)
		ld	h, a
		or	a
		jr	nz, YM1_Parse_At_New_Offset ; if second	byte !=	0, we have FF xx xx, so	go parse from new offset xxxx
		ld	a, l
		or	a
		jr	z, loc_5D7	; if we	have FF	00 00, then mute channel because there is nothing else to do
		ld	(NEW_COMMAND), a ; else, we have FF xx 00, so	put first byte in 0x1FFF to process operation xx

loc_5D7:				; CODE XREF: YM1_ParseData+6Bj
		ld	a, 1		; THIS PART mutes the channel because it has nothing to	play
		ld	(ix+3),	a	; channel data byte 3 =	1
		ld	a, (CURRENTLY_MANAGING_SFX) 
		or	a
		jr	z, loc_nimp2
		ld	bc, 0FE20h	; if an	SFX was	being managed, go back to corresponding	music channel
		add	ix, bc
		ld	a, 0B4h	; '�'   ; YM Register : Stereo / LFO Sensitivity
		add	a, (iy+0)
		ld	b, a
		ld	c, (ix+1Eh)	; load corresponding music channel stereo setting
		call	YM1_Input
		ld	a, (ix+3)
		or	a
		jr	nz, loc_nimp2
		ld	a, (ix+4)	; if corresponding music channel in use, load its instrument, and return
		jp	YM1_LoadInstrument	
		
		
			
loc_nimp2:		
		xor	a
		jp	YM1_LoadInstrument ; set channel level to minimum and leave subroutine
; ---------------------------------------------------------------------------

YM1_Parse_At_New_Offset:		; CODE XREF: YM1_ParseData+67j
		ex	de, hl		; THIS PART puts in de the new offset from which to parse data
		jr	Parsing_Start
; ---------------------------------------------------------------------------

Set_Instrument:				; CODE XREF: YM1_ParseData+5Dj
		cp	0FEh ; '�'      ; FE xx : set new instrument xx
		jr	nz, Load_Note	; FD xx	: play note at level xx. It's followed by other parameters handled at next parsing loop
		inc	de
		ld	a, (de)
		call	YM1_SetChannelInstrument
		inc	de
		jp	Parsing_Start
; ---------------------------------------------------------------------------

Load_Note:				; CODE XREF: YM1_ParseData+7Ej
		cp	0FDh ; '�'      ; FD xx : play note at level xx. It's followed by other parameters handled at next parsing loop
		jr	nz, Set_Slide_Or_Key_Release
		inc	de
		ld	a, (de)		; get note level
		and	0Fh		
		call	YM1_LoadInstrument
		inc	de
		jp	Parsing_Start
; ---------------------------------------------------------------------------

Set_Slide_Or_Key_Release:		; CODE XREF: YM1_ParseData+8Bj
		cp	0FCh ; '�'
		jr	nz, Load_Vibrato
		call	YM_SetSlideOrKeyRelease
		jp	Parsing_Start
; ---------------------------------------------------------------------------

Load_Vibrato:				; CODE XREF: YM1_ParseData+9Aj
		cp	0FBh ; '�'
		jr	nz, Set_Stereo
		call	LoadVibrato
		jp	Parsing_Start
; ---------------------------------------------------------------------------

Set_Stereo:				; CODE XREF: YM1_ParseData+A4j
		cp	0FAh ; '�'
		jr	nz, Load_Note_Shift
		call	YM1_SetStereo
		jp	Parsing_Start
; ---------------------------------------------------------------------------

Load_Note_Shift:			; CODE XREF: YM1_ParseData+AEj
		cp	0F9h ; '�'
		jr	nz, Loop_Command
		call	LoadNoteShift
		jp	Parsing_Start
; ---------------------------------------------------------------------------

Loop_Command:				; CODE XREF: YM1_ParseData+B8j
		cp	0F8h ; '�'
		jr	nz, Theoretically_Unreachable
		call	ParseLoopCommand
		jp	Parsing_Start
; ---------------------------------------------------------------------------

Theoretically_Unreachable:		; CODE XREF: YM1_ParseData+C2j
		inc	de		; if none of the commands from above are found,
		inc	de		; then ignore and start	process	again two bytes	forward. Theoretically,	it can't happen ...
		jp	Parsing_Start
; ---------------------------------------------------------------------------

loc_636:				; CODE XREF: YM1_ParseData+57j
		ld	a, (de)		; we are here because a	< F8, so a can still be	F0, 70,	or a new note frequency	to play
		and	7Fh ; ''
		cp	70h ; 'p'
		jp	z, loc_68E	; if a = F0 or 70. Else, a is a	note frequency byte
		add	a, (ix+1Ch)	; 1C affects note index	up or down. It's set by command F9
		ld	l, a
		ld	h, 0
		ld	bc, YM_FREQUENCIES+1 ; load table of YM	frequencies
		add	hl, hl
		add	hl, bc		; now hl points	to the YM frequency value corresponding	to the note's frequency
		ld	a, (hl)
		dec	hl
		ld	l, (hl)		; l = byte to put in YM	Register Frequency 2
		ld	h, a		; h = byte to put in YM	Register Frequency 1
		ld	b, 0
		ld	c, (ix+1Dh)	; byte 1D affects frequency up.	It's set by command F9. Is it used ? I'll look in SF2 musics
		add	hl, bc
		ld	a, (loc_774+1)
		ld	b, a		; YM Register :	Frequency 2
		ld	c, h		; input	value
		ld	(ix+12h), c
		ld	a, (ix+1Fh)	; if channel byte 1F !=	0, then	pitch slide is activated
		or	a		; so keep final	value to reach in channel byte 12
		jr	nz, loc_668	; then jump
		ld	(ix+0Fh), c	; else,	put it directly	in channel byte	0F
		xor	a
		ld	(ix+12h), a

loc_668:				; CODE XREF: YM1_ParseData+F8j
		call	YM1_ConditionnalInput
		ld	a, (loc_77D+1)	; dynamically changed :	1st frequency register to use corresponding to current channel
		ld	b, a		; YM register :	Frequency 1
		ld	c, l		; input	value
		ld	(ix+11h), c
		ld	a, (ix+1Fh)	; if channel byte 1F !=	0, pitch slide is activated
		or	a		; so keep value	in channel byte	11
		jr	nz, loc_680	; then jump
		ld	(ix+0Eh), c	; else,	put it directly	in channel byte	0E
		xor	a
		ld	(ix+11h), a

loc_680:				; CODE XREF: YM1_ParseData+110j
		call	YM1_ConditionnalInput
		ld	b, 28h ; '('    ; YM Register : Key on/off
		ld	a, (iy+0)
		or	0F0h ; '�'      ; set key ON
		ld	c, a
		call	YM1_ConditionnalInput

loc_68E:				; CODE XREF: YM1_ParseData+D4j
		ld	a, (de)		; get full byte	again
		bit	7, a
		jr	nz, Command_F0	; if bit 7 set,	then it's command F0 or it's new note to play needing new note length
		ld	a, (ix+7)	; else use existing time period
		jr	loc_69D
; ---------------------------------------------------------------------------

Command_F0:				; CODE XREF: YM1_ParseData+12Aj
		inc	de		; if a's bit 7 is set, then it's F0
		ld	a, (de)		; set a	new time period	with next byte
		ld	(ix+7),	a

loc_69D:				; CODE XREF: YM1_ParseData+12Fj
		ld	(ix+2),	a	; also put time	period in channel byte 2, which	is the time counter
		inc	de
		ld	(ix+1),	d	; point	to next	channel	rom byte
		ld	(ix+0),	e
		jp	loc_586
; ---------------------------------------------------------------------------

loc_6AA:				; CODE XREF: YM1_ParseData+3Fj
		dec	(ix+2)		; decrement channel time counter
		ld	b, (ix+12h)
		ld	c, (ix+11h)
		ld	a, b
		or	c
		jr	z, loc_72E	; if bc	= 0, then there	is no pitch slide
		ld	a, (ix+0Fh)	; else,	pitch slide !
		ld	h, a
		ld	a, (ix+0Eh)
		ld	l, a		; hl = current frequency ; bc =	frequency to reach
		push	bc
		push	hl
		or	a
		sbc	hl, bc		; get frequency	difference
		ld	a, h
		ld	(TEMP_FREQUENCY), a ; save first frequency byte	... why	?
		jr	nc, loc_6D2	; if bc	<= hl, so if frequency value to	reach is lower
		ld	b, 0
		ld	c, (ix+1Fh)	; frequency to reach is	higher,	so get slide up	value
		jp	loc_6DA
; ---------------------------------------------------------------------------

loc_6D2:				; CODE XREF: YM1_ParseData+161j
		ld	b, 0FFh		; frequency to reach is	lower, so get slide down value
		ld	a, (ix+1Fh)
		neg			; get negative value of	pitch slide speed in order to slide down
		ld	c, a

loc_6DA:				; CODE XREF: YM1_ParseData+168j
		pop	hl
		add	hl, bc		; apply	slide on frequency
		pop	bc
		push	hl
		or	a
		sbc	hl, bc		; get new frequency difference
		ld	a, (TEMP_FREQUENCY) ; xor old h	and new	h
		xor	h
		bit	7, a
		pop	hl
		jr	nz, loc_721	; jump if bit 7	of xor result =	1, go put final	pitch as current frequency, but	how can	it happen ?
		push	hl
		ld	a, h
		and	7		; leave	octave bits, just keep frequency bits
		ld	h, a
		ld	(TEMP_FREQUENCY), hl ; save new	frequency
		ld	bc, 4D4h
		or	a
		sbc	hl, bc
		jr	c, loc_700	; if hl	frequency (without octave) < $4D4
		ld	bc, 596h	; hl > $4D4, so	add $596
		jp	loc_714
; ---------------------------------------------------------------------------

loc_700:				; CODE XREF: YM1_ParseData+191j
		ld	hl, (TEMP_FREQUENCY) ; temp space to store frequency values when YM data is parsed
		ld	bc, 26Ah	; 2 * $26A = $4D4
		or	a
		sbc	hl, bc
		jr	nc, loc_711	; if hl	frequency (without octave) >= 26A
		ld	bc, 0FA6Ah	; hl < $26A, so	sub $596
		jp	loc_714
; ---------------------------------------------------------------------------

loc_711:				; CODE XREF: YM1_ParseData+1A2j
		ld	bc, 0		; hl between $26A and $4D4, so do nothing

loc_714:				; CODE XREF: YM1_ParseData+196j
					; YM1_ParseData+1A7j
		pop	hl
		add	hl, bc
		ld	a, h
		ld	(ix+0Fh), a	; set new frequency... but why do they have to add/sub $596 O___o ?!
		ld	a, l
		ld	(ix+0Eh), a
		jp	loc_72E
; ---------------------------------------------------------------------------

loc_721:				; CODE XREF: YM1_ParseData+181j
		ld	(ix+0Fh), b	; current frequency = final slide pitch
		ld	(ix+0Eh), c
		xor	a
		ld	(ix+11h), a	; end of slide
		ld	(ix+12h), a

loc_72E:				; CODE XREF: YM1_ParseData+14Ej
					; YM1_ParseData+1B7j
		ld	a, (ix+0Ah)
		or	a
		jr	z, loc_73A	; if channel byte 0A = 0 ... then start	vibrato	?
		dec	(ix+0Ah)	; decrement channel byte 0A : I	think this is a	time counter before note vibrato
		xor	a
		jr	EndPart
; ---------------------------------------------------------------------------

loc_73A:				; CODE XREF: YM1_ParseData+1CBj
					; YM1_ParseData+1F9j
		ld	a, (ix+0Ch)
		ld	h, a
		ld	a, (ix+0Bh)
		ld	l, a		; hl = vibrato pointer
		ld	a, (ix+0Dh)	; get vibrato relative pointer
		ld	b, 0
		ld	c, a
		inc	(ix+0Dh)
		add	hl, bc		; point	to next	vibrato	byte
		ld	a, (hl)
		cp	81h ; '�'
		jr	nz, loc_757
		dec	(ix+0Dh)	; if byte = 81,	point previous byte and	do nothing ? O_o
		xor	a		; anyway, there's no $81 in the data -_- ...
		jr	EndPart
; ---------------------------------------------------------------------------

loc_757:				; CODE XREF: YM1_ParseData+1E8j
		cp	80h ; '�'
		jp	nz, EndPart
		xor	a		; if byte = 80,	it's the end of vibrato data, so go back to the beginning
		ld	(ix+0Dh), a
		jp	loc_73A
; ---------------------------------------------------------------------------

EndPart:				; CODE XREF: YM1_ParseData+1D1j
					; YM1_ParseData+1EEj
					; YM1_ParseData+1F2j
		ld	c, a		; a = vibrato value to apply
		ld	a, (ix+0Eh)
		ld	l, a
		ld	a, (ix+0Fh)
		ld	h, a		; hl = current note's frequency value
		ld	b, 0
		bit	7, c
		jr	z, loc_773
		dec	b		; if c is a negative value, b =	FF

loc_773:				; CODE XREF: YM1_ParseData+209j
		add	hl, bc		; after	this, up to date frequency is sent to YM

loc_774:				; DATA XREF: YM1_ParseData+1Cw
					; YM1_ParseData+ECr YM2_ParseData+11Ar
		ld	b, 0		; dynamically changed :	2nd frequency register corresponding to	current	channel
		ld	c, h
		ld	(ix+0Fh), c
		call	YM1_ConditionnalInput

loc_77D:				; DATA XREF: YM1_ParseData+16w
					; YM1_ParseData+104r
					; YM2_ParseData+132r
		ld	b, 0		; dynamically changed :	1st frequency register to use corresponding to current channel
		ld	c, l
		ld	(ix+0Eh), c
		call	YM1_ConditionnalInput
		ld	a, (FADE_OUT_TIMER) ; Starts with fade out length value, decrements at each YM Timer overflow. set to $63 while	loading	music
		or	a
		ret	nz
		ld	a, (ix+4)	; if currently fading out, make	sure the instrument level is updated
		jp	YM1_LoadInstrument
; End of function YM1_ParseData