; Reads controllers

ReadCtrl1:
  lda #$01
  sta $4016
  lda #$00
  sta $4016
  ldx #$08
.loop:
  lda $4016
  lsr A
  rol ctrl_1
  dex
  bne .loop
  rts

ReadCtrl2:
  lda #$01
  sta $4016
  lda #$00
  sta $4016
  ldx #$08
.loop:
  lda $4017
  lsr A
  rol ctrl_2
  dex
  bne .loop
  rts