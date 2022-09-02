; =============== S U B	R O U T	I N E =======================================


LoadYmTimerB:				; CODE XREF: Main+F3p
					; UpdateSound:loc_475p
		ld	bc, 273Ah	; reset	timers A and B,	enable and load	B
		jr	ApplyYm1Input
; End of function YM_LoadTimerB