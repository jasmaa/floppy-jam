; Code for enemy aliens

InitAliens:
  lda #$80
  sta alien_1_x
  lda #$50
  sta alien_1_y
  
  lda #%00001111
  sta alien_mask
  
  rts

UpdateAliens:
  ; move
  ;ldx alien_1_x
  ;inx
  ;stx alien_1_x
  
  ; check take damage
  lda #%00000001
  sta curr_laser_mask
  ldx #$00
  
.outer_loop:
  ; check each laser
  lda laser_mask
  and curr_laser_mask
  beq .outer_skip
  lda #%00000001
  sta curr_alien_mask
  ldy #$00
  
  ; collision
.inner_loop:
  lda alien_mask
  and curr_alien_mask
  beq .inner_skip
  
  lda laser_1_x, x 
  cmp alien_1_x, y
  bcc .inner_skip
  lda laser_1_x, x
  sec
  sbc #$10
  cmp alien_1_x, y
  bcs .inner_skip
  lda laser_1_y, x
  cmp alien_1_y, y
  bcs .inner_skip
  
  ; test
  lda #$00
  sta $021E
  sta $0222
  sta $0226
  sta $022A

.inner_skip:
  iny
  clc
  rol curr_alien_mask
  cpy #$04
  bne .inner_loop

.outer_skip:
  inx
  clc
  rol curr_laser_mask
  cpx #$03
  bne .outer_loop
  rts