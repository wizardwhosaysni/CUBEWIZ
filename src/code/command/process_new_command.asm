; =============== S U B	R O U T	I N E =======================================


Main:					
		push	af		; main handles any new operation sent by 68K (or Z80 itself)
		xor	a
		ld	(NEW_OPERATION), a ; clear 0x1FFF (its value is	already	in pushed a)
		ld	a, (COMMANDS_COUNTER)
		add	a, 1
		ld	(COMMANDS_COUNTER), a		
		pop	af
		ld	(LAST_COMMAND), a 
		cp	0FFh
		jp	z, Pause_Sound	; if a = FFh : mute sound
		cp	0FEh ; '�'
		jp	z, StopMusic	; if a = FEh : stop music by muting PSG	and releasing YM keys
		cp	0FDh ; '�'
		jp	z, Fade_Out	; if a = FDh : fade out
		cp	0FCh 
		jp	z, Save_Music	; if a = FCh : save current music
		cp	0FBh 
		jp	z, Resume_Music	; if a = FBh : resume saved music	
		cp	0FAh 
		jp	z, ActivateResuming	; if a = FAh : activate resuming		
		cp	0F9h 
		jp	z, DeactivateResuming	; if a = F9h : deactivate resuming				
		cp	0F0h ; '�'
		jp	z, Update_YM_Level ; if	a = F0h
		cp	0F1h ; '�'
		jp	z, YM_SetTimer	; if a = F1h
		cp	41h ; 'A'
		jp	nc, Load_SFX	; if a > 41h, then play	an SFX (already	stored in ram along with the code)
		
		ld	ix, PREVIOUS_MUSIC
		cp	(ix)
		jp	z, Resume_Previous_Music
		jp	Not_Previous_Music
		
Resume_Previous_Music:
		; if saved music was finished, just load it again
		push	af
		ld	a, (SAVED_MUSIC_CHANNEL_YM1+CHANNEL_FREE)		
		cp	01h
		jp	nz, Test_Resuming
		pop	af
		jp	Not_Previous_Music
Test_Resuming:
		ld	a, (RESUMING_DEACTIVATED)		
		cp	0FFh
		jp	nz, Resume_Indeed
		pop	af
		jp	Not_Previous_Music
Resume_Indeed:		
		ld	a, (CURRENT_MUSIC)
		ld	(PREVIOUS_MUSIC), a	
		pop	af
		ld	(CURRENT_MUSIC), a
		jp	Resume_Music		

Not_Previous_Music:		
		push	hl		; else,	play a music !
		push	de
		push	af
		ld	a, (MUSIC_BANK)
		ld	(SAVED_MUSIC_BANK), a	
		pop	af
		push	af
		cp	21h ; '!'
		jr	nc, loc_201	; if a > 21h, then play	music from chunk 0x1F0000
		ld	a, MUSIC_BANK_1		; otherwise play music from 0x1F8000
		ld	(MUSIC_BANK), a	; load 01h to 0x152D
		call	LoadBank	; load rom chunk 0x1F8000 to bank
		ld	a, (CURRENT_MUSIC)	
		ld	(PREVIOUS_MUSIC), a
		pop	af
		ld	(CURRENT_MUSIC), a
		ld	de, 8000h
		jp	Load_Music	; decrement music/sound	index (no $00 entry)
; ---------------------------------------------------------------------------

loc_201:				; CODE XREF: Main+29j
		ld	a, MUSIC_BANK_2	
		ld	(MUSIC_BANK), a
		call	LoadBank	; load rom chunk 0x1F0000 to bank
		ld	a, (CURRENT_MUSIC)	
		ld	(PREVIOUS_MUSIC), a
		pop	af
		ld	(CURRENT_MUSIC), a
		ld	de, 8000h
		sub	20h ; ' '

Load_Music:				; CODE XREF: Main+37j
		dec	a		; decrement music/sound	index (no $00 entry)
		add	a, a		; double index because the pointer table to reach has 2	bytes per entry
		ld	h, 0
		ld	l, a
		add	hl, de
		ld	a, (hl)
		inc	hl
		ld	h, (hl)
		ld	l, a		; now hl contains pointer to music/sound data
		ld	a, (hl)		; get byte 0
		or	a		; check	if a = 0 with z	flag
		jp	nz, Load_SFX	; if byte 0 of music data != 0,	actually load it as an SFX instead
		ld	a, (FADE_IN_PARAMETERS)	; fade in parameter applied from 68k when a music is loaded. nibble 1 :	fade in	speed. nibble 2	: fade in start	level.
		and	0Fh
		ld	(MUSIC_LEVEL), a ; general output level	for music and SFX type 1, sent from 68k
		xor	a
		ld	(FADE_IN_TIMER), a ; reset fade	in timer
		
		call	Save_Music
		
		call	StopMusic	; stop currently playing music if there	was one
		inc	hl
		ld	a, (hl)		; get music data byte 1	: indicates if music uses DAC Samples
		inc	hl		; so music byte	2 is useless ? I guess it was intended to use YM Timer A first,	which needs two	data bytes
		inc	hl		; point	to byte	3 : YM Timer B value
		ld	(MUSIC_YM6_FM_MODE), a ;	indicates if music uses	DAC Samples
		ld	a, (hl)
		ld	(YM_TIMER_VALUE), a
		call	YM_SetTimer
		xor	a
		ld	(CURRENTLY_FADING_OUT),	a ; clear fade out bytes
		ld	(FADE_OUT_COUNTER), a ;	Counts how many	times the fade out timer reached 0. Fade out stops at value $0C.
		ld	a, 63h ; 'c'
		ld	(FADE_OUT_TIMER), a ; Starts with fade out length value, decrements at each YM Timer overflow. set to $63 while	loading	music
		inc	hl		; hl now points	to the first of	the ten	pointers
		ld	b, 0Ah		; number of loops
		ld	ix, MUSIC_CHANNEL_YM1 ;	start of the data to store

Load_Music_Channels:			; CODE XREF: Main+C8j
		ld	e, (hl)		; this part initializes	each channel ram data
		inc	hl
		ld	d, (hl)		; de = channel data pointer
		inc	hl		; point	to first byte of next pointer
		ld	(ix+0),	e
		ld	(ix+1),	d	; init data pointer
		xor	a		; and let me present to	you ...
		ld	(ix+2),	a	; time counter for note/sample length
		ld	(ix+3),	a	; "channel not in use" indicator
		ld	(ix+6),	a	; key release time (release key	when time counter 02 reaches this value)
		ld	(ix+8),	a	; set to $80 when there	is no key release
		ld	(ix+13h), a
		ld	(ix+14h), a	; loop A start pointer
		ld	(ix+1Ch), a	; note shift value
		ld	(ix+1Dh), a	; frequency shift value
		ld	(ix+1Fh), a	; slide	speed
		ld	a, 1
		ld	(ix+1Eh), a	; stereo setting
		ld	d, (ix+1)
		ld	e, (ix+0)
		ld	a, (de)		; get first pointed data byte
		cp	0FFh
		jr	nz, loc_28A
		ld	a, 1		; if first byte	of channel data	= FF, then there is no data for	this channel
		ld	(ix+3),	a	; "channel not in use"

loc_28A:				; CODE XREF: Main+BCj
		ld	de, 30h	; ' '
		add	ix, de
		djnz	Load_Music_Channels ; actual loop instruction based on register	b
		ld	b, 2		; loop two times

Activate_Stereo_Outputs:		; CODE XREF: Main+E1j
		push	bc
		ld	a, b
		dec	a
		ld	(CALL_YM2_INSTEAD_OF_YM1), a ; set to $01 when managing	YM4,5,6	channels, to call part 2 of YM
		ld	bc, 0B4C0h	; activate left	and right sound	outputs	for each channel
		call	YM_Input	; first	channel	of called YM part
		inc	b
		call	YM_Input	; second channel
		inc	b
		call	YM_Input	; third	channel
		pop	bc
		djnz	Activate_Stereo_Outputs
		
		ld	a, 0C0h	; '�'   ; set C0h for byte 1E of YM channels
		ld	(MUSIC_CHANNEL_YM1+STEREO_PANNING), a
		ld	(MUSIC_CHANNEL_YM2+STEREO_PANNING), a
		ld	(MUSIC_CHANNEL_YM3+STEREO_PANNING), a		
		ld	(MUSIC_CHANNEL_YM4+STEREO_PANNING), a
		ld	(MUSIC_CHANNEL_YM5+STEREO_PANNING), a
		ld	(MUSIC_CHANNEL_YM6+STEREO_PANNING), a
		ld	a, 0FEh	; '�'   ; put value FE as DAC Sound sample to load ... which loads nothing. Why such a thing then ?
		ld	(NEW_SAMPLE_TO_LOAD), a	; stores the index of a	new DAC	sample to play
		call	YM_LoadTimerB

Load_End:				; CODE XREF: Main+12Aj	Main+134j
					; Main+166j
		pop	de		; end of the loadSFX and loadMusic chunks
		pop	hl
		ld	a, (DAC_BANK)
		jp	LoadBank
; ---------------------------------------------------------------------------

Load_SFX:				; CODE XREF: Main+21j Main+53j
		push	hl		; looks	like the part to play SFX
		push	de
		sub	41h ; 'A'
		ld	h, 0
		ld	l, a
		ld	a, SFX_BANK
		call	LoadBank		
		add	hl, hl		; a is an index, and you double	it to access to	a pointer table
		ld	de, SFX_BANK_OFFSET	; SFX in ROM Bank		
		add	hl, de	
		ld	a, (hl)
		inc	hl
		ld	h, (hl)		; get the proper pointer
		ld	l, a
		
		; hl now points to original sfx offset, with sfx data starting at 0x162D
		; now sfx data starts at 0xB070 so 0xB070 - 0x162D = 9A43h to add
		push	bc
		ld	b, 9Ah
		ld	c, 43h
		add	hl, bc
		pop	bc
		
		ld	a, h
		ld	(DAC_LAST_OFFSET), a
		ld	a, l	
		ld	(DAC_LAST_OFFSET+1), a						
		ld	a, (hl)		
		inc	hl		; hl points to byte 1 of sfx data
		cp	1
		jr	nz, Load_SFX_Type_2 ; if a != 1	(then a	= 2, which means the sound just	concerns 3 channels)
		ld	b, 0Ah		; loop 10 times
		ld	ix, SFX_CHANNEL_YM1

Load_SFX_Channels:			; CODE XREF: Main+128j
		ld	e, (hl)		; part to get next channel data
		inc	hl
		ld	d, (hl)		; de = bytes 2-3 of sound data = pointer
		inc	hl
		
		; add 9A43h to sfx data offset since it's been moved from driver to bank
		push	hl		
		ld	hl, 09A43h
		adc	hl, de
		ex	hl, de
		pop	hl
		
		ld	a, (de)		; a = first byte of current channel
		cp	0FFh		; if first byte	= FF, there is no data to setup, so skip subroutine call
		jr	z, loc_2EA
		call	InitChannelDataForSFX

loc_2EA:				; CODE XREF: Main+11Ej
		ld	de, 30h	; ' '
		add	ix, de		; go to	next channel data
		djnz	Load_SFX_Channels ; loop
		jr	Load_End	
; ---------------------------------------------------------------------------

Load_SFX_Type_2:			; CODE XREF: Main+10Fj
		ld	bc, 304h	; loop 3 times13/12/2008 17:14:41
		ld	ix, SFX_CHANNEL_YM4 ;	the 3 channel SFX are stored in	dedicated temp channel data, in	order not to overwrite current music data

loc_309:				; CODE XREF: Main+164j
		push	bc
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		inc	hl		; hl points to next pointer
		
		; add 9A43h to sfx data offset since it's been moved from driver to bank
		push	hl		
		ld	hl, 09A43h
		adc	hl, de
		ex	hl, de
		pop	hl
		
		ld	a, (de)		; a = first byte of current channel
		cp	0FFh
		jr	z, loc_324	; if a = FF, ignore this channel
		call	InitChannelDataForSFX ;	otherwise, init	channel	data
		ld	b, 28h ; '('    ; YM register : Key on/off
		call	YM1_Input	; input	"key off" for YM channel 4, 5, 6 respectively for channel 1,2,3 of the sound
		ld	c, a		; a = c	= current YM channel to	use
		add	a, 0B0h	; '�'   ; a = YM register to activate left and right stereo outputs
		ld	b, a
		ld	c, 0C0h	; '�'   ; sets stereo left and right on
		call	YM2_Input

loc_324:				; CODE XREF: Main+14Aj
		ld	de, 30h	; ' '
		add	ix, de		; point	next channel destination slot
		pop	bc
		inc	c		; next channel number
		djnz	loc_309		; loop
		jp	Load_End	; end of the loadSFX and loadMusic chunks
; End of function Main