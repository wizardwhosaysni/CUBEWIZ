t_YM_LEVELS:	db 70h			; DATA XREF: YM1_LoadInstrument+58o
					; YM2_LoadInstrument+63o
		db 60h			; this table contains the actual YM level values corresponding
		db 50h			; to the 16 possible values of the sound engine
		db 40h			; First	value being almost YM's min level,
		db 38h			; and last value being almost YM's max level
		db 30h
		db 2Ah
		db 26h
		db 20h
		db 1Ch
		db 18h
		db 14h
		db 10h
		db 0Bh
		db  8
		db  4