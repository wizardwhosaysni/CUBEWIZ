; =============== S U B	R O U T	I N E =======================================


InitChannelDataForSFX:			; CODE XREF: Main+120p	Main+14Cp
		ld	(ix+0),	e
		ld	(ix+1),	d	; bytes	0-1 = ed = offset of channel data source
		ld	a, 0C0h	; '�'
		ld	(ix+1Eh), a	; byte 1E = C0
		xor	a		; clear	a
		ld	(ix+2),	a	; clear	all those bytes
		ld	(ix+3),	a
		ld	(ix+6),	a
		ld	(ix+8),	a
		ld	(ix+13h), a
		ld	(ix+14h), a
		ld	(ix+1Ch), a
		ld	(ix+1Dh), a
		ld	(ix+1Fh), a
		ld	a, 1
		ld	(ix+1Eh), a	; byte 1E = 1 ... er ... why is	it set to $CO first and	then to	1 at the end ?
		ret			; Definitely need to watch stereo stuff !
; End of function InitChannelDataForSFX