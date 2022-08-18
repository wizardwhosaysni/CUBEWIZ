; =============== S U B	R O U T	I N E =======================================


YM_SetTimer:				; CODE XREF: Main+1Cj
		push	bc
		ld	b, 26h ; '&'    ; YM Register : Timer B
		ld	a, (YM_TIMER_VALUE) ; stores the timer value to	send to	YM
		ld	c, a
		
					; Conditional input to implement here (maybe!) !
		
		call	YM1_Input
		pop	bc
		ret
; End of function YM_SetTimer