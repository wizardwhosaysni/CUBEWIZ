t_SAMPLE_LOAD_DATA:
		db	 1,   0,   DAC_BANK_1,	0,0EFh,	11h,   0, 80h ;	DATA XREF: LoadDacSound+12o
		db    1,   0,	DAC_BANK_1,   0,0EFh, 11h,0EFh, 91h ; Data layout of the	8-byte entries :
		db    1,   0,	DAC_BANK_1,   0,0E3h,   8, 31h,0F4h ; byte 0 : PCM frame	period parameter
		db    1,   0,	DAC_BANK_2,   0,0E3h,   8,   0, 80h ; byte 1 : always 0 (ignored	when data is parsed)
		db    1,   0,	DAC_BANK_2,   0,0E3h,   8,0E3h, 88h ; byte 2 : bank to load
		db    1,   0,	DAC_BANK_1,   0,0EFh, 11h,0DEh,0A3h ; byte 3 : always 0 (ignored	when data is parsed)
		db    1,   0,	DAC_BANK_1,   0,0C1h, 11h,0CDh,0B5h ; bytes 5-4 : sample	length
		db    5,   0,	DAC_BANK_1,   0,0C1h, 11h,0CDh,0B5h ; bytes 7-6 : pointer to sound PCM Data once	bank is	loaded
		db    3,   0,	DAC_BANK_1,   0,	  0, 0Fh, 8Eh,0C7h ;
		db    9,   0,	DAC_BANK_1,   0,	  0, 0Fh, 8Eh,0C7h ; With this table, the same sound sample can	be played at different rates,
		db    1,   0,	DAC_BANK_2,   0,	29h, 1Dh,0C6h, 91h ; resulting with quick high-pitched,	or slow	low-pitched sounds,
		db  0Fh,   0,	DAC_BANK_2,   0,	29h, 1Dh,0C6h, 91h ; which is quite appropriate	for drums or attack hits or explosions !
		db    1,   0,	DAC_BANK_1,   0,0A3h, 1Dh, 8Eh,0D6h
		db    5,   0,	DAC_BANK_1,   0,0A3h, 1Dh, 8Eh,0D6h
		db    9,   0,	DAC_BANK_1,   0,0A3h, 1Dh, 8Eh,0D6h
		db  0Fh,   0,	DAC_BANK_1,   0,0A3h, 1Dh, 8Eh,0D6h
		db  14h,   0,	DAC_BANK_1,   0,0A3h, 1Dh, 8Eh,0D6h