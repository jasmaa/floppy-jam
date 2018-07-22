InitShip:
  lda #$80
  sta ship_x
  sta ship_y
  lda #$01
  sta ship_speed
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
  
  ; shitty lazzer firing code
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
  .skip_1:
  
.skip_fire_all:
  rts

UpdateLaser:
  lda laser_mask
  and #%00000001
  beq .kill_laser_1
  
  ; fire laser code here
  lda #%00000001
  sta $0212
  lda laser_1_y
  sec
  sbc #$05
  sta laser_1_y
  
  jmp .end_1
.kill_laser_1:
  lda #%00100001
  sta $0212
.end_1:
  rts
  
UpdateSprites:
  ; draw ship
  lda ship_y
  sta $0200
  sta $0204
  clc
  adc #$08
  sta $0208
  sta $020C
  
  lda ship_x
  sta $0203
  sta $020B
  clc
  adc #$08
  sta $0207
  sta $020F
  
  ; draw laser
  lda laser_1_y
  sta $0210
  lda laser_1_x
  sta $0213
  
  rts