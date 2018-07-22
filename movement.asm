InitShipPos:
  lda #$80
  sta ship_x
  sta ship_y
  rts

UpdateShipPos:
  ; check move up
  lda ctrl_1
  and #%00001000
  beq .skip_up
  ldx ship_y
  dex
  stx ship_y
.skip_up:
  ; check move down
  lda ctrl_1
  and #%00000100
  beq .skip_down
  ldx ship_y
  inx
  stx ship_y
.skip_down:
  ; check move left
  lda ctrl_1
  and #%00000010
  beq .skip_left
  ldx ship_x
  dex
  stx ship_x
.skip_left:
 ; check move right
  lda ctrl_1
  and #%00000001
  beq .skip_right
  ldx ship_x
  inx
  stx ship_x
.skip_right:
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
  
  rts