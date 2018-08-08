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
  lda #EXP_COOLDOWN_TIME
  sta exp_cooldown_1
  sta exp_cooldown_2
  sta exp_cooldown_3
  sta exp_cooldown_4
  
  rts

UpdateAliens:

  ; randomly respawn aliens excluding explosion
  jsr prng
  cmp #$10
  bcs .skip_respawn
  lda #%11111111
  eor exp_mask
  sta temp
  jsr prng
  and temp
  ora alien_mask
  sta alien_mask
.skip_respawn:

; collision
  lda #%00000001
  sta curr_alien_mask
  ldy #$00
  
; for each alien, y
.outer_loop:
  lda alien_mask
  and curr_alien_mask
  beq .outer_skip
  
  lda #%00000001
  sta curr_laser_mask
  ldx #$00
  
  ; update active aliens
  jsr ShowAlien
  jsr MoveAlien
  
  ; check ship collision
  jsr CheckShipCollide
  
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
  jmp SkipUpdateAliens
  
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
SkipUpdateAliens:
  rts

; show active aliens
ShowAlien:
  sty temp
  clc
  rol temp
  rol temp
  rol temp
  rol temp
  ldy temp
  lda #%00000010
  sta $021E, y
  sta $0222, y
  sta $0226, y
  sta $022A, y
  clc
  ror temp
  ror temp
  ror temp
  ror temp
  ldy temp
.done:
  rts

; Move aliens
MoveAlien:
  jsr prng
  sta temp2
  
  ; choose direction flip
  lda temp2
  cmp #$05
  bcs .skip
  lda alien_1_dir, y
  eor #%11111111
  sta alien_1_dir, y
  .skip:
  
  lda alien_1_dir, y
  beq .move_right
.move_left:
  lda alien_1_x, y
  sec
  sbc #$01
  jmp .move_x_done
.move_right:
  lda alien_1_x, y
  clc
  adc #$01
.move_x_done:
  sta alien_1_x, y

  lda alien_1_y, y
  clc
  adc #$01

  sta alien_1_y, y
  rts
  
; kill alien spaceship
KillAlien:

  ; quick screen flash
  lda #%00000001
  sta $2001

  ; add to score
  lda score
  clc
  adc #$01
  sta score

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
  asl temp
  asl temp
  asl temp
  asl temp
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

CheckShipCollide:
  lda ship_y
  sec
  sbc #$08
  cmp alien_1_y, y
  bcs .skip_ship_collide
  lda ship_y
  clc
  adc #$08
  cmp alien_1_y, y
  bcc .skip_ship_collide
  
  lda ship_x
  sec
  sbc #$08
  cmp alien_1_x, y
  bcs .skip_ship_collide
  lda ship_x
  clc
  adc #$08
  cmp alien_1_x, y
  bcc .skip_ship_collide
  
  lda ship_damage_cooldown
  bne .skip_ship_collide
  
  ; damage
  lda lives
  sec
  sbc #$01
  sta lives
  
  lda #SHIP_DAMAGE_COOLDOWN_TIME
  sta ship_damage_cooldown
  
.skip_ship_collide:
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
  
  ; reset vars
  lda #EXP_COOLDOWN_TIME
  sta exp_cooldown_1, x
  lda #$00
  sta alien_1_y, x
  
  ; deactivate
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
  and exp_mask
  sta exp_mask
  
  ; kill explosion
  ; multiply by 16
  lda temp
  clc
  rol a
  rol a
  rol a
  rol a
  tax
  ; revert to alien, pal, and hide
  lda #%00100010
  sta $021E, x
  sta $0222, x
  sta $0226, x
  sta $022A, x
  lda #$02
  sta $021D, x
  lda #$03
  sta $0221, x
  lda #$12
  sta $0225, x
  lda #$13
  sta $0229, x
  
.skip:
  clc
  rol curr_exp_mask
  inx
  cpx #$05
  bne .loop
  rts