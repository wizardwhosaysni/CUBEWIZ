; =============== S U B	R O U T	I N E =======================================


YM1_SetChannelInstrument:		; CODE XREF: YM1_ParseData+82p
		ld	(ix+10h), a	; just set instrument value in channel byte 10 without loading it into YM
		ret
; End of function YM1_SetChannelInstrument