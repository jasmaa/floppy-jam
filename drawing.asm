; Draws sprites

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
  
  lda laser_2_y
  sta $0214
  lda laser_2_x
  sta $0217
  
  lda laser_3_y
  sta $0218
  lda laser_3_x
  sta $021B
  
  ; draw aliens
  lda alien_1_y
  sta $021C
  sta $0220
  clc
  adc #$08
  sta $0224
  sta $0228
  
  lda alien_1_x
  sta $021F
  sta $0227
  clc
  adc #$08
  sta $0223
  sta $022B
  
  rts