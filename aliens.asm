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
  
  ; init exp cooldown
  lda #$20
  sta exp_cooldown_1
  sta exp_cooldown_2
  sta exp_cooldown_3
  sta exp_cooldown_4
  
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
  ; kill alien and laser
  jsr KillAlien
  jsr KillLaser
  
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
KillAlien:
  sty temp
  ; set alien and exp mask and destroy Y
  lda #%11111110
  sta curr_alien_mask
  lda #%00000001
  sta curr_exp_mask
  cpy #$00
  beq .skip
.mask_loop:
  sec
  rol curr_alien_mask
  clc
  rol curr_exp_mask
  dey
  bne .mask_loop
.skip:
  lda alien_mask
  and curr_alien_mask
  sta alien_mask
  lda exp_mask
  ora curr_exp_mask
  sta exp_mask
  
  ; multiply y by 16
  clc
  rol temp
  rol temp
  rol temp
  rol temp
  ldy temp
  
  ;lda #%00100010
  ; change pal and sprite
  lda #%00000001
  sta $021E, y
  sta $0222, y
  sta $0226, y
  sta $022A, y
  lda #$21
  sta $021D, y
  lda #$22
  sta $0221, y
  lda #$31
  sta $0225, y
  lda #$32
  sta $0229, y
  
  rts

; shut off laser
; MAKE BETTER WITH GENERAL SHUTOFF FUNC???
KillLaser:
  stx temp
  lda #%11111110 
  sta curr_laser_mask
  cpx #$00
  beq .skip
.mask_loop:
  rol curr_laser_mask
  dex
  bne .mask_loop
.skip:
  lda laser_mask
  and curr_laser_mask
  sta laser_mask
  
  ; multiply by 4
  clc
  rol temp
  rol temp
  ldx temp
  
  ; hide laser
  lda #%00100001
  sta $0212, x
  
  rts

; updates exploded aliens
UpdateExplosions:
  ldx #$00
  lda #%00000001
  sta curr_exp_mask
.loop:
  lda curr_exp_mask
  and exp_mask
  beq .skip				; short circuit if not active
  
  ; update explosion
  lda exp_cooldown_1, x
  sec
  sbc #$01
  sta exp_cooldown_1, x
  cmp #$00
  bne .skip
  
  ; deactivate - check me!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  stx temp
  lda #%11111110
  sec
.loop2:
  cpx #$00
  beq .skip2
  rol a
  dex
  jmp .loop2
.skip2:
  and curr_exp_mask
  sta curr_exp_mask
  
  ; do a color change or smth
  ; derp test DELETE ME!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  lda #%00000001
  sta $0202
  ; derp test end
  
.skip:
  clc
  rol curr_exp_mask
  inx
  cpx #$05
  bne .loop
  rts