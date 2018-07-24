; Code for enemy aliens

InitAliens:
  lda #$80
  sta alien_1_x
  lda #$50
  sta alien_1_y
  rts

UpdateAliens:
  ; move
  ldx alien_1_x
  inx
  stx alien_1_x
  
  ; check take damage
  lda #$00000001
  sta curr_laser_mask
  ldx #$00
  
.loop:
  ; check curr laser
  lda laser_mask
  and curr_laser_mask
  beq .skip
  
  ; collision
  ; FIGURE OUT HOW TO DO MULTIPLE ALIENS
  lda laser_1_x, x 
  cmp alien_1_x
  bcc .skip
  lda laser_1_x, x
  sec
  sbc #$10
  cmp alien_1_x
  bcs .skip
  lda laser_1_y, x
  cmp alien_1_y
  bcs .skip
  
  ; test
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