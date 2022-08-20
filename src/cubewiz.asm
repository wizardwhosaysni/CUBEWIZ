
	cpu z80
	listing off
	phase	0

    include "constants.asm"

    include "code\init.asm"
    include "code\main_loop.asm"
    include "code\command\main\pause_sound.asm"
    include "code\ym\update_level.asm"
    include "code\load_bank.asm"
    include "code\dac\load_dac_sample.asm"
    include "code\command\process_new_command.asm"
    include "code\sfx\init_channel.asm"
    include "code\music\stop_music.asm"
    include "code\update_sound.asm"
    include "code\ym\load_timer.asm"
    include "code\ym\ym_inputs.asm"
    include "code\psg\set_attenuation.asm"
    include "code\dac\set_sample.asm"
    include "code\ym\parse_data_ym1.asm"
    include "code\ym\parse_data_ym2.asm"
    include "code\ym\set_instrument_ym1.asm"
    include "code\ym\load_instrument_ym1.asm"
    include "code\ym\set_instrument_ym2.asm"
    include "code\ym\load_instrument_ym2.asm"
    include "code\dac\parse_dac_data.asm"
    include "code\psg\parse_tone_data.asm"
    include "code\psg\conditional_input.asm"
    include "code\psg\get_instrument_pointer.asm"
    include "code\psg\load_instrument.asm"
    include "code\psg\parse_noise_data.asm"
    include "code\ym\set_slide_or_release.asm"
    include "code\command\channel\set_release.asm"
    include "code\command\channel\load_vibrato.asm"
    include "code\ym\set_stereo.asm"
    include "code\command\channel\load_note_shift.asm"
    include "code\command\channel\process_loop_command.asm"
    include "code\command\main\fade_out.asm"
    include "code\ym\set_timer.asm"
    include "code\music_resuming.asm"
    include "code\dac\send_dac_byte.asm"
    
    include "data\ym_frequencies.asm"
    include "data\psg_freqencies.asm"
    include "data\ym_levels.asm"
    include "data\algo_slots.asm"
    include "data\pitch_effects.asm"
    include "data\psg_instruments.asm"
	align 010h, 0	
    include "data\pcm_samples.asm"
	align 1700h, 0
    include "data\channel_data.asm"

END_OF_DRIVER:
	if MOMPASS==2
		if $ > 1FC0h
			fatal "Driver too big to fit in Z80 Ram ; the last offset must be < 1FC0h. It is currently \{END_OF_DRIVER}h"
		else
			message "Last offset: \{END_OF_DRIVER}h"
		endif
	endif

		end