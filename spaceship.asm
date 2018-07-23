; Controls player spaceship

InitShip:
  lda #$80
  sta ship_x
  sta ship_y
  lda #$01
  sta ship_speed
  lda #LASER_COOLDOWN_TIME
  sta laser_cooldown
  rts

UpdateShip:
  ; check move up
  lda ctrl_1
  and #%00001000
  beq .skip_up
  lda ship_y
  sec
  sbc ship_speed
  sta ship_y
.skip_up:
  ; check move down
  lda ctrl_1
  and #%00000100
  beq .skip_down
  lda ship_y
  clc
  adc ship_speed
  sta ship_y
.skip_down:
  ; check move left
  lda ctrl_1
  and #%00000010
  beq .skip_left
  lda ship_x
  sec
  sbc ship_speed
  sta ship_x
.skip_left:
 ; check move right
  lda ctrl_1
  and #%00000001
  beq .skip_right
  lda ship_x
  clc
  adc ship_speed
  sta ship_x
.skip_right:
  ; fire lazer
  lda ctrl_1
  and #%10000000
  beq .skip_fire_all
  lda laser_cooldown
  bne .skip_fire_all
  
  ; shitty lazzer firing code
  lda #LASER_COOLDOWN_TIME
  sta laser_cooldown
  
  lda laser_mask
  and #%00000001
  bne .skip_1
  lda #%00000001
  ora laser_mask
  sta laser_mask
  lda ship_x
  clc
  adc #$04
  sta laser_1_x
  lda ship_y
  sta laser_1_y
  jmp .skip_fire_all
.skip_1:
  
  lda laser_mask
  and #%00000010
  bne .skip_2
  lda #%00000010
  ora laser_mask
  sta laser_mask
  lda ship_x
  clc
  adc #$04
  sta laser_2_x
  lda ship_y
  sta laser_2_y
  jmp .skip_fire_all
.skip_2:
  
  lda laser_mask
  and #%00000100
  bne .skip_3
  lda #%00000100
  ora laser_mask
  sta laser_mask
  lda ship_x
  clc
  adc #$04
  sta laser_3_x
  lda ship_y
  sta laser_3_y
  jmp .skip_fire_all
.skip_3:
  
.skip_fire_all:
  rts

UpdateLaser:

  ; check cooldown
  lda laser_cooldown
  beq .skip
  ldx laser_cooldown
  dex
  stx laser_cooldown
.skip:

  ; move lasers
  lda laser_mask
  and #%00000001
  beq .end_1
  lda #%00000001
  sta $0212
  lda laser_1_y
  sec
  sbc #$05
  sta laser_1_y
  
  ; decide if laser is at ceiling and kill
  cmp #UWALL
  bcs .end_1
  lda #%11111110
  and laser_mask
  sta laser_mask
  lda #%00100001
  sta $0212
.end_1:

  lda laser_mask
  and #%00000010
  beq .end_2
  lda #%00000001
  sta $0216
  lda laser_2_y
  sec
  sbc #$05
  sta laser_2_y
  
  cmp #UWALL
  bcs .end_2
  lda #%11111101
  and laser_mask
  sta laser_mask
  lda #%00100001
  sta $0216
.end_2:

  lda laser_mask
  and #%00000100
  beq .end_3
  lda #%00000001
  sta $021A
  lda laser_3_y
  sec
  sbc #$05
  sta laser_3_y
  
  cmp #UWALL
  bcs .end_3
  lda #%11111011
  and laser_mask
  sta laser_mask
  lda #%00100001
  sta $021A
.end_3:

  rts