pt_PSG_INSTRUMENTS:dw byte_12D2		; DATA XREF: PSG_LoadInstrument+22o
					; The PSG instruments only affect the channel level
		dw byte_12D4		; more details about the data layout in	psg-intruments.txt
		dw byte_12E6		; instrument 2
		dw byte_12F4		; instrument 3
		dw byte_130B		; instrument 4
		dw byte_1312		; instrument 5
		dw byte_131D		; instrument 6
		dw byte_1325		; instrument 7
		dw byte_132A		; instrument 8
		dw byte_1338		; instrument 9
		dw byte_133E		; instrument A
		dw byte_1349		; instrument B
		dw byte_134B		; instrument C
		dw byte_134F		; instrument D
		dw byte_1355		; instrument E
		dw byte_135D		; instrument F
byte_12D2:	db 8Fh			; DATA XREF: RAM:pt_PSG_INSTRUMENTSo
					; start	of data	: instrument 0
		db 8Bh
byte_12D4:	db 0Fh			; DATA XREF: RAM:12B4o
					; instrument 1
		db 0Fh
		db 0Eh
		db 0Dh
		db 0Ch
		db 0Bh
		db 0Ah
		db  9
		db  8
		db  7
		db  6
		db  5
		db  4
		db  3
		db  2
		db  1
		db 80h
		db 80h
byte_12E6:	db 0Fh			; DATA XREF: RAM:12B6o
					; instrument 2
		db 0Eh
		db 0Eh
		db 0Dh
		db 0Dh
		db 0Dh
		db 0Ch
		db 0Ch
		db 0Ch
		db 0Ch
		db 8Bh
		db 0Ah
		db 0Ah
		db 89h
byte_12F4:	db 0Fh			; DATA XREF: RAM:12B8o
					; instrument 3
		db 0Fh
		db 0Fh
		db 0Fh
		db 0Fh
		db 0Fh
		db 0Eh
		db 0Eh
		db 0Eh
		db 0Eh
		db 0Eh
		db 0Eh
		db 0Eh
		db 0Eh
		db 0Eh
		db 0Eh
		db 0Eh
		db 0Eh
		db 8Dh
		db 0Bh
		db 0Bh
		db 0Bh
		db 8Ah
byte_130B:	db 0Fh			; DATA XREF: RAM:12BAo
					; instrument 4
		db 0Fh
		db 8Eh
		db 0Bh
		db 0Bh
		db 0Bh
		db 8Ah
byte_1312:	db 0Fh			; DATA XREF: RAM:12BCo
					; instrument 5
		db 0Eh
		db 8Dh
		db 0Bh
		db  9
		db  7
		db  5
		db  3
		db  2
		db  1
		db 80h
byte_131D:	db 0Dh			; DATA XREF: RAM:12BEo
					; instrument 6
		db 0Eh
		db 0Fh
		db 8Eh
		db  4
		db  2
		db  1
		db 80h
byte_1325:	db 0Dh			; DATA XREF: RAM:12C0o
					; instrument 7
		db 0Eh
		db 0Fh
		db 8Eh
		db 8Bh
byte_132A:	db 0Fh			; DATA XREF: RAM:12C2o
					; instrument 8
		db 0Fh
		db 0Eh
		db 0Eh
		db 0Dh
		db 0Ch
		db 0Fh
		db 0Fh
		db 0Eh
		db 0Eh
		db 0Dh
		db 0Dh
		db 8Ch
		db 8Ah
byte_1338:	db 0Bh			; DATA XREF: RAM:12C4o
					; instrument 9
		db 0Ch
		db 0Dh
		db 0Eh
		db 8Fh
		db 88h
byte_133E:	db 0Bh			; DATA XREF: RAM:12C6o
					; instrument A
		db 0Dh
		db 0Fh
		db 0Eh
		db 0Dh
		db 8Ch
		db 0Ah
		db 0Ah
		db  9
		db  9
		db 88h
byte_1349:	db 8Fh			; DATA XREF: RAM:12C8o
					; instrument B
		db 8Fh
byte_134B:	db 0Fh			; DATA XREF: RAM:12CAo
					; instrument C
		db 0Ah
		db 86h
		db 83h
byte_134F:	db 0Fh			; DATA XREF: RAM:12CCo
					; instrument D
		db 0Ch
		db 0Ah
		db  8
		db 86h
		db 83h
byte_1355:	db 0Fh			; DATA XREF: RAM:12CEo
					; instrument E
		db 0Dh
		db 0Bh
		db  9
		db  8
		db  7
		db 86h
		db 83h
byte_135D:	db 8Fh			; DATA XREF: RAM:12D0o
					; instrument F
		db 80h			; end of data