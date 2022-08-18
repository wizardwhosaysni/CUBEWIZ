pt_PITCH_EFFECTS:dw byte_126B		; DATA XREF: LoadVibrato+8o
					; The pitch effects mostly are vibratos, but also effects that make pitch go up	or down	indefinitely
		dw byte_126D		; vibrato 1
		dw byte_1272
		dw byte_127D
		dw byte_1288
		dw byte_1293
		dw byte_129E		; from here, the pitch effects are not vibratos, they just make	the pitch constantly go	up or down
		dw byte_12A0
		dw byte_12A2
		dw byte_12A4
		dw byte_12A6
		dw byte_12A8
		dw byte_12AA
		dw byte_12AC
		dw byte_12AE
		dw byte_12B0
byte_126B:	db  0			; DATA XREF: RAM:pt_PITCH_EFFECTSo
					; vibrato 0 : nothing !	used to	cancel a previous vibrato ?
		db 80h
byte_126D:	db 0F0h			; DATA XREF: RAM:124Do
					; vibrato 1
		db 10h			; at each sound	frame, the next	data byte is added to the current frequency to slightly	affect it
		db 10h
		db 0F0h
		db 80h			; value	$80 means that it's end of data, so go back to the first byte of the pitch effect
byte_1272:	db 0FDh			; DATA XREF: RAM:124Fo
		db 0FDh
		db 0FFh
		db  1
		db  3
		db  3
		db  3
		db  1
		db 0FFh
		db 0FDh
		db 80h
byte_127D:	db 0FEh			; DATA XREF: RAM:1251o
		db 0FEh
		db 0FFh
		db  1
		db  2
		db  2
		db  2
		db  1
		db 0FFh
		db 0FEh
		db 80h
byte_1288:	db 0FFh			; DATA XREF: RAM:1253o
		db 0FFh
		db  0
		db  1
		db  1
		db  1
		db  1
		db  0
		db 0FFh
		db 0FFh
		db 80h
byte_1293:	db 0FFh			; DATA XREF: RAM:1255o
		db  0
		db  0
		db  1
		db  0
		db  1
		db  0
		db  0
		db 0FFh
		db  0
		db 80h
byte_129E:	db  2			; DATA XREF: RAM:1257o
					; from here, the pitch effects are not vibratos, they just make	the pitch constantly go	up or down
		db 80h
byte_12A0:	db 0FEh			; DATA XREF: RAM:1259o
		db 80h
byte_12A2:	db  4			; DATA XREF: RAM:125Bo
		db 80h
byte_12A4:	db 0FCh			; DATA XREF: RAM:125Do
		db 80h
byte_12A6:	db  8			; DATA XREF: RAM:125Fo
		db 80h
byte_12A8:	db 0F8h			; DATA XREF: RAM:1261o
		db 80h
byte_12AA:	db 10h			; DATA XREF: RAM:1263o
		db 80h
byte_12AC:	db 0F0h			; DATA XREF: RAM:1265o
		db 80h
byte_12AE:	db 20h			; DATA XREF: RAM:1267o
		db 80h
byte_12B0:	db 0E0h			; DATA XREF: RAM:1269o
		db 80h