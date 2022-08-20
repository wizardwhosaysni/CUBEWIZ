
; 68K ROM offsets
SFX_ROM_OFFSET                 equ  043000h
DAC_BANK_1_ROM_OFFSET          equ 01E0000h
DAC_BANK_2_ROM_OFFSET          equ 01E8000h
YM_INSTRUMENTS_BANK_ROM_OFFSET equ 01EB000h
MUSIC_BANK_2_ROM_OFFSET        equ 01F0000h
MUSIC_BANK_1_ROM_OFFSET        equ 01F8000h

; Banks defined by 32kB slot position in ROM, 
; and then pointers to mapped range 0x8000..0xFFFF when needed	
SFX_BANK                       equ SFX_ROM_OFFSET/08000h
SFX_BANK_OFFSET                equ SFX_ROM_OFFSET#08000h+08000h			
DAC_BANK_1                     equ DAC_BANK_1_ROM_OFFSET/08000h
DAC_BANK_2                     equ DAC_BANK_2_ROM_OFFSET/08000h
MUSIC_BANK_1                   equ MUSIC_BANK_1_ROM_OFFSET/08000h				
MUSIC_BANK_2                   equ MUSIC_BANK_2_ROM_OFFSET/08000h
YM_INSTRUMENTS_BANK            equ YM_INSTRUMENTS_BANK_ROM_OFFSET/08000h
YM_INSTRUMENTS_BANK_OFFSET     equ YM_INSTRUMENTS_BANK_ROM_OFFSET#08000h+08000h		

; Z80 RAM offsets
STACK_START                    equ 1FE0h
SAVED_MUSIC_BANK 	           equ 1FE0h
PREVIOUS_MUSIC 		           equ 1FE1h
SAVED_YM_TIMER_VALUE 	       equ 1FE2h
SAVED_MUSIC_DOESNT_USE_SAMPLES equ 1FE3h
NEW_SAMPLE_TO_LOAD 	           equ 1FE4h
DAC_LAST_OFFSET 	           equ 1FE5h
TEMP_FREQUENCY                 equ 1FE6h ; 2 bytes
RESUMING_DEACTIVATED	       equ 1FE8h
CURRENT_PSG_CHANNEL            equ 1FE9h
CURRENT_CHANNEL                equ 1FEAh
FADE_OUT_LENGTH		           equ 1FEBh
FADE_OUT_TIMER		           equ 1FECh
FADE_OUT_COUNTER	           equ 1FEDh
CURRENTLY_FADING_OUT	       equ 1FEEh
COMMANDS_COUNTER 	           equ 1FEFh
MUSIC_BANK 		               equ 1FF0h	
CURRENT_MUSIC 		           equ 1FF1h
YM_TIMER_VALUE 		           equ 1FF2h
MUSIC_DOESNT_USE_SAMPLES       equ 1FF3h
DAC_BANK		               equ 1FF4h
DAC_REMAINING_LENGTH 	       equ 1FF5h ; 2 bytes
CURRENTLY_MANAGING_SFX         equ 1FF7h
CALL_YM2_INSTEAD_OF_YM1        equ 1FF8h
CURRENTLY_MANAGING_SFX_TYPE_2  equ 1FF9h
TEMP_REGISTER		           equ 1FFAh
FADE_IN_TIMER		           equ 1FFBh
FADE_IN_PARAMETERS 	           equ 1FFCh	
MUSIC_LEVEL 		           equ 1FFDh
LAST_COMMAND 		           equ 1FFEh	
NEW_OPERATION 		           equ 1FFFh
					
; Registers
YM1_REGISTER                   equ 4000h
YM1_DATA                       equ 4001h
YM2_REGISTER                   equ 4002h
YM2_DATA                       equ 4003h
BANK_REGISTER                  equ 6000h
PSG_PORT                       equ 7F11h