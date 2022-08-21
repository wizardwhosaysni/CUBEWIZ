; =============== S U B	R O U T	I N E =======================================


LoadBank:			
		push	hl
		ld	hl, BANK_REGISTER 
		ld	(hl), a
		rra
		ld	(hl), a
		rra
		ld	(hl), a
		rra
		ld	(hl), a
		rra
		ld	(hl), a
		rra
		ld	(hl), a
		rra
		ld	(hl), a
		ld	(hl), l
		ld	(hl), l
		pop	hl
		ret
; End of function LoadAnyBank