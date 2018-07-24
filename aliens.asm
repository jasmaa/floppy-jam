; Code for enemy aliens

InitAliens:
  lda #$80
  ldx #$00
.loop:
  sta alien_1_x, x
  clc
  adc #$10
  inx
  cpx #$04
  bne .loop
  
  lda #$50
  ldx #$00
.loop2:
  sta alien_1_y, x
  clc
  adc #$10
  inx
  cpx #$04
  bne .loop2
  
  lda #%00001111
  sta alien_mask
  
  rts

UpdateAliens:
  ; move
  ldx alien_1_x
  inx
  stx alien_1_x
  
  ; check take damage
  lda #%00000001
  sta curr_alien_mask
  ldy #$00
  
; collision
; for each alien, y
.outer_loop:
  lda alien_mask
  and curr_alien_mask
  beq .kill_alien
  
  lda #%00000001
  sta curr_laser_mask
  ldx #$00
  
; for each laser, x
.inner_loop:
  lda laser_mask
  and curr_laser_mask
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
  inx
  clc
  rol curr_laser_mask
  cpx #$03
  bne .inner_loop
; end inner, x
.kill_alien:
 ; write kill code here
.outer_skip:
  iny
  clc
  rol curr_alien_mask
  cpy #$04
  bne .outer_loop
; end outer, y
  rts