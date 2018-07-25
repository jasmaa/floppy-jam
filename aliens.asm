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

  lda #%00000001
  sta curr_alien_mask
  ldy #$00
  
; collision
; for each alien, y
.outer_loop:
  lda alien_mask
  and curr_alien_mask
  beq .outer_skip
  
  lda #%00000001
  sta curr_laser_mask
  ldx #$00
  
  ; update active aliens
  ; move
  lda alien_1_x, y
  clc
  adc #$01
  sta alien_1_x, y
  
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
  lda laser_1_y, x
  clc
  adc #$10
  cmp alien_1_y, y
  bcc .inner_skip
  
  ; kill alien
  jsr kill_alien
  
.inner_skip:
  inx
  clc
  rol curr_laser_mask
  cpx #$03
  bne .inner_loop
; end inner, x
.outer_skip:
  iny
  clc
  rol curr_alien_mask
  cpy #$04
  bne .outer_loop
; end outer, y
  rts

  
; kill alien spaceship
kill_alien:
  sty temp
  ; set mask and destroy Y
  lda #%11111110
  sta curr_alien_mask
  cpy #$00
  beq .skip
.mask_loop:
  rol curr_alien_mask
  dey
  bne .mask_loop
.skip:
  lda alien_mask
  and curr_alien_mask
  sta alien_mask
  
  ; multiply y by 16
  clc
  rol temp
  rol temp
  rol temp
  rol temp
  ldy temp
  
  ;lda #%00100010
  ; change color for now
  lda #%00000001
  sta $021E, y
  sta $0222, y
  sta $0226, y
  sta $022A, y
  
  ; revert y here???? nah
  rts