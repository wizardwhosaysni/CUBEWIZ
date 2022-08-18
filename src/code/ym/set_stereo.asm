; =============== S U B	R O U T	I N E =======================================


YM1_SetStereo:				; CODE XREF: YM1_ParseData+B0p

; FUNCTION CHUNK AT 1016 SIZE 00000009 BYTES

		inc	de
		ld	a, (de)
		bit	0, a
		ret	nz	; if bit 0 of pointed value is set to 1	: if FMS value = 1 or 3	?
		and	0C0h ; '�'      ; else
		ld	(ix+1Eh), a
		ld	c, a
		ld	b, 0B4h	; '�'
		ld	a, (iy+0)
		add	a, b
		ld	b, a		; set proper register according	to currently processed channel
		inc	de		; point	to next	pointed	rom byte
		
					; conditionnal input to implement here !
		
		jp	YM1_ConditionnalInput
; End of function YM1_SetStereo


; =============== S U B	R O U T	I N E =======================================


YM2_SetStereo:				; CODE XREF: YM2_ParseData+DEp
					; YM2_ParseChannel6Data+99p
		inc	de
		ld	a, (de)
		and	0C0h ; '�'
		ld	(ix+1Eh), a
		ld	c, a
		ld	b, 0B4h	; '�'
		ld	a, (iy+0)
		add	a, b
		ld	b, a
		inc	de
		jp	YM2_ConditionalInput
; End of function YM2_SetStereo