; =============== S U B	R O U T	I N E =======================================


FadeOut:				; CODE XREF: Main+12j
		ld	a, 12h		; set a	fade out period	length of $12 YM timer overflows
		ld	(FADE_OUT_LENGTH), a ; number of YM Timer overflows to handle before incrementing the fade out counter
		ld	a, 1
		ld	(CURRENTLY_FADING_OUT),	a ; set	to 01 when a fade out operation	is being executed
		ld	a, (FADE_OUT_LENGTH) ; number of YM Timer overflows to handle before incrementing the fade out counter
		ld	(FADE_OUT_TIMER), a ; Starts with fade out length value, decrements at each YM Timer overflow. set to $63 while	loading	music
		ret
; End of function Fade_Out