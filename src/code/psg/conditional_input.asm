; =============== S U B	R O U T	I N E =======================================


PSG_ConditionnalInput:	
		push	af		
		ld	a, (CURRENTLY_MANAGING_SFX) 
		or	a
		jr	nz, send_psg_data	
		exx
		push	ix		
		pop	hl
		ld	bc, 01E3h ; '�'
		add	hl, bc
		ld	a, (hl)		
		exx
		or	a
		jr	nz, send_psg_data
		pop	af
		ret	
send_psg_data:
		pop	af
		ld	(PSG_PORT), a
		ret

; End of function YM1_ConditionnalInput