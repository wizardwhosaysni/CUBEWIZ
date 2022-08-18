; =============== S U B	R O U T	I N E =======================================


YM_LoadTimerB:				; CODE XREF: Main+F3p
					; UpdateSound:loc_475p
		ld	bc, 273Ah	; reset	timers A and B,	enable and load	B
		jr	YM1_Input
; End of function YM_LoadTimerB