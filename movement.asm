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
  beq .skip_fire
  lda #$01
  sta is_laser
  ; messing with ship_x for some reason...
  lda ship_x
  clc
  adc #$04
  sta laser_x
  lda ship_y
  sta laser_y
.skip_fire:
  rts

UpdateLaser:
  lda is_laser
  beq .kill_laser
  
  ; fire laser code here
  lda #%00000001
  sta $0212
  lda laser_y
  sec
  sbc #$05
  sta laser_y
  
  jmp .skip
.kill_laser:
  lda #%00100001
  sta $0212
.skip:
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
  lda laser_y
  sta $0210
  lda laser_x
  sta $0213
  
  rts