t_SLOTS_PER_ALGO:db 8			; DATA XREF: YM1_LoadInstrument+61o
					; YM2_LoadInstrument+6Co
		db  8
		db  8			; table	used to	know which operators have to be	affected by the	channel's level
		db  8			; bit 0	related	to operator 1, bit 1 to	operator 2 etc ...
		db 0Ch			; if 0,	then operator is not a slot, so	use the	instrument's original level value
		db 0Eh			; if 1,	then operator is a slot, so use	channel	level value
		db 0Eh
		db 0Fh