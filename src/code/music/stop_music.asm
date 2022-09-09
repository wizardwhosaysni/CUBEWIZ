
    ; sets key off / mutes music channels

StopMusic:
    push  hl

    ld  iy, CURRENT_CHANNEL
    xor  a
    ld  (CALL_YM_PART2), a
    ld  (iy+0),  a
    ld  ix, MUSIC_CHANNEL_YM1
    call  YM1_LoadInstrument
    ld  bc, (YMREG_KEY_ON_OFF<<8)+00h
    call  YM1_ConditionnalInput
    inc  (iy+0)
    xor  a
    ld  ix, MUSIC_CHANNEL_YM2
    call  YM1_LoadInstrument
    ld  bc, (YMREG_KEY_ON_OFF<<8)+01h
    call  YM1_ConditionnalInput
    inc  (iy+0)
    xor  a
    ld  ix, MUSIC_CHANNEL_YM3
    call  YM1_LoadInstrument
    ld  bc, (YMREG_KEY_ON_OFF<<8)+02h
    call  YM1_ConditionnalInput
    ld  a, 1
    ld  (CALL_YM_PART2), a
    xor  a
    ld  (iy+0),  a
    ld  a, (SFX_CHANNEL_YM4+CHANNEL_FREE)
    or  a
    jr  z, $$skipYm4
    xor  a
    ld  ix, MUSIC_CHANNEL_YM4
    call  YM2_LoadInstrument
    ld  bc, (YMREG_KEY_ON_OFF<<8)+04h
    call  YM1_ConditionnalInput
$$skipYm4:
    inc  (iy+0)
    ld  a, (SFX_CHANNEL_YM5+CHANNEL_FREE)
    or  a
    jr  z, $$skipYm5
    xor  a
    ld  ix, MUSIC_CHANNEL_YM5
    call  YM2_LoadInstrument
    ld  bc, (YMREG_KEY_ON_OFF<<8)+05h
    call  YM1_ConditionnalInput
$$skipYm5:
    inc  (iy+0)
    ld  a, (SFX_CHANNEL_YM6+CHANNEL_FREE)
    or  a
    jr  z, $$skipYm6
    xor  a
    ld  ix, MUSIC_CHANNEL_YM6
    call  YM2_LoadInstrument
    ld  bc, (YMREG_KEY_ON_OFF<<8)+06h
    call  YM1_ConditionnalInput
    jr  $$skipYm6
$$skipYm6:
    ld  hl, PSG_PORT
    ld  a, 9Fh
    ld  (hl), a    ; set PSG channel 1 volume to 0
    ld  a, 0BFh
    ld  (hl), a    ; set PSG channel 2 volume to 0
    ld  a, 0DFh
    ld  (hl), a    ; set PSG channel 3 volume to 0
    ld  a, 0FFh
    ld  (hl), a    ; set PSG noise  channel  volume to 0

    ld  hl, MUSIC_CHANNEL_YM1+CHANNEL_FREE
    ld  de, 30h
    ld  b, 0Ah
    ld  a, 1
$$loop:
    ld  (hl), a    ; set "Channel free" byte
    add  hl, de
    djnz  $$loop

    pop  hl
    ld  de, 0
    xor  a
    ld  (CURRENTLY_FADING_OUT), a
    ld  (FADE_OUT_COUNTER), a
    ld  a, 63h
    ld  (FADE_OUT_TIMER), a
    ret
