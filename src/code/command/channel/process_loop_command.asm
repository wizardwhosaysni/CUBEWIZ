; =============== S U B	R O U T	I N E =======================================


ParseLoopCommand:			; CODE XREF: YM1_ParseData+C4p
					; YM2_ParseData+F2p
					; YM2_ParseChannel6Data+A3p
					; PSG_ParseToneData+91p
					; PSG_ParseNoiseData+60p
		inc	de
		ld	a, (de)		; get first byte parameter
		ld	b, a
		inc	de		; point	to next	data byte
		rlca
		rlca
		rlca
		and	7		; keep bits 7-6-5. It must be a	subcommand
		jr	nz, loc_1049
		ld	(ix+13h), e	; if bits 7-6-5	= 0, put next data byte	offset into channel bytes 13-14
		ld	(ix+14h), d	; this must be a loop start !
		ret
; ---------------------------------------------------------------------------

loc_1049:				; CODE XREF: ParseLoopCommand+9j
		cp	1		; if bits 7-6-5	= 1 ...	beginning of a loop ?
		jr	nz, loc_105B
		ld	(ix+15h), e	; put next data	byte offset in 15-16
		ld	(ix+16h), d	; is it	also a loop start ? like there could be	a loop in another loop ? Two loops managed independently ?
		xor	a
		ld	(ix+1Ah), a	; clear	1A-1B
		ld	(ix+1Bh), a
		ret
; ---------------------------------------------------------------------------

loc_105B:				; CODE XREF: ParseLoopCommand+14j
		cp	2		; if bits 7-6-5	= 2
		jr	nz, loc_1089
		ld	a, (ix+1Ah)
		or	a
		jr	nz, loc_106B	; if (1A) != 0,	then it's not the first loop
		ld	a, 1		; if (1A) = 0, then put	1 instead. It means it's the first loop.
		ld	(ix+1Ah), a
		ret
; ---------------------------------------------------------------------------

loc_106B:				; CODE XREF: ParseLoopCommand+2Cj
					; ParseLoopCommand+45j
					; ParseLoopCommand+48j
					; ParseLoopCommand+4Dj
		ld	a, (de)		; a = $F0
		ld	b, a		; b = $F0
		inc	de
		ld	a, (de)		; a = $D8
		ld	c, a		; c = $D8
		inc	de		; de points to a next F8 command
		ld	a, b		; a = $F0
		cp	0FFh
		jr	z, loc_1086	; if first data	byte = FF, finish
		cp	0F8h ; '�'
		jr	z, loc_1081	; if first data	byte = F8 (then	you have something like	F8, byte with bits 7-6-5 = 2, and F8 again ?)
		and	80h ; '�'
		jr	nz, loc_106B	; if bit 7 of first data byte =	1, start process again
		dec	de		; else,	start process again but	point one byte backward	first ... wow ... o_O
		jr	loc_106B	; a = $F0
; ---------------------------------------------------------------------------

loc_1081:				; CODE XREF: ParseLoopCommand+41j
		ld	a, c
		cp	60h ; '`'
		jr	nz, loc_106B	; if a = 60, finish, else start	process	again ... so it	expects	loop command 3 to get out of here !

loc_1086:				; CODE XREF: ParseLoopCommand+3Dj
					; ParseLoopCommand+6Bj
					; ParseLoopCommand+7Dj
		dec	de
		dec	de
		ret
; ---------------------------------------------------------------------------

loc_1089:				; CODE XREF: ParseLoopCommand+26j
		cp	3		; if bits 7-6-5	= 3
		jr	nz, loc_10B6
		ld	a, (ix+1Bh)
		or	a
		jr	nz, loc_1099	; same idea as command 2
		ld	a, 1		; if (1B) = 0, then put	1 instead
		ld	(ix+1Bh), a
		ret
; ---------------------------------------------------------------------------

loc_1099:				; CODE XREF: ParseLoopCommand+5Aj
					; ParseLoopCommand+73j
					; ParseLoopCommand+76j
					; ParseLoopCommand+7Bj
		ld	a, (de)		; same idea as command 2
		ld	b, a
		inc	de
		ld	a, (de)
		ld	c, a
		inc	de
		ld	a, b
		cp	0FFh
		jr	z, loc_1086
		cp	0F8h ; '�'
		jr	z, loc_10AF
		and	80h ; '�'
		jr	nz, loc_1099	; same idea as command 2
		dec	de
		jr	loc_1099	; same idea as command 2
; ---------------------------------------------------------------------------

loc_10AF:				; CODE XREF: ParseLoopCommand+6Fj
		ld	a, c
		cp	80h ; '�'
		jr	nz, loc_1099	; expects command 4 to get out of here
		jr	loc_1086
; ---------------------------------------------------------------------------

loc_10B6:				; CODE XREF: ParseLoopCommand+54j
		cp	4		; if bits 7-6-5	= 4 end	of command 3
		jr	nz, loc_10BB
		ret			; if command 4,	just return ! it's just here to stop command 3
; ---------------------------------------------------------------------------

loc_10BB:				; CODE XREF: ParseLoopCommand+81j
		cp	5		; if bits 7-6-5	= 5 ...	go back	to the beginning of a loop ?
		jr	nz, loc_10D1
		bit	0, b
		jr	nz, loc_10CA	; if bit 0 = 1 (value A1)
		ld	e, (ix+15h)	; else (value A0), point back to offset	saved in 15-16
		ld	d, (ix+16h)
		ret
; ---------------------------------------------------------------------------

loc_10CA:				; CODE XREF: ParseLoopCommand+8Aj
		ld	e, (ix+13h)	; point	back to	offset saved in	13-14
		ld	d, (ix+14h)
		ret
; ---------------------------------------------------------------------------

loc_10D1:				; CODE XREF: ParseLoopCommand+86j
		cp	6		; if bits 7-6-5	= 6 : initiate a loop repeated x times,	x being	bits 4-0
		jr	nz, loc_10E3	; else,	bits 7-6-5 = 7
		ld	(ix+17h), e	; put next data	byte offset in 17-18
		ld	(ix+18h), d
		ld	a, b
		and	1Fh		; just keep parameter
		inc	a		; increment it
		ld	(ix+19h), a	; and store it in 19
		ret
; ---------------------------------------------------------------------------

loc_10E3:				; CODE XREF: ParseLoopCommand+9Cj
		dec	(ix+19h)	; decrement loop counter
		ret	z		; return if counter reached 0
		ld	e, (ix+17h)	; go back to the beginning of the loop
		ld	d, (ix+18h)
		ret
; End of function ParseLoopCommand