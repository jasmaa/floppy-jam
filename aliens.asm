; Code for enemy aliens

InitAliens:
  lda #$80
  sta alien_1_x
  lda #$50
  sta alien_1_y
  rts

UpdateAliens:
  ; check take damage
  lda #$00000001
  sta curr_laser_mask
  ldx #$00
  
.loop:
  ; check curr laser
  lda laser_mask
  and curr_laser_mask
  beq .skip
  lda laser_1_x, x  
  cmp alien_1_x
  
  ; check if less for now
  bcs .skip
  lda #$00
  sta $021E
  sta $0222
  sta $0226
  sta $022A
  
.skip:
  inx
  clc
  rol curr_laser_mask
  cpx #$03
  bne .loop
  rts