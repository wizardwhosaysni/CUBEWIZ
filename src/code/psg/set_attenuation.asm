PSG_SetChannelAttenuation:		; CODE XREF: PSG_ParseToneData+4Fj
					; PSG_ParseNoiseData+41j
		and	0Fh		; just keep attenuation	parameter
		ld	h, a		; save it
		ld	a, (CURRENT_PSG_CHANNEL) ; get concerned channel
		or	h		; load attenuation value
		or	90h ; '�'       ; load attenuation command bits
		ld	(PSG_PORT), a	; send message
		ret