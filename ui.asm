; Control UI elements

UpdateLabels:

  ; update score
  jmp CalcScore
  CalcScoreDone:
  
  rts

; converts score to digits
CalcScore:
  lda #$00
  sta digit_1
  sta digit_2
  sta digit_3
  sta digit_4
  
  ldx score
  beq CalcScoreDone
.loop:
  lda digit_1
  clc
  adc #$01
  sta digit_1
  cmp #$0A
  bne .skip
; add 10s
  lda #$00
  sta digit_1
  lda digit_2
  clc
  adc #$01
  sta digit_2
  cmp #$0A
  bne .skip
; add 100s
  lda #$00
  sta digit_2
  lda digit_3
  clc
  adc #$01
  sta digit_3
  cmp #$0A
  bne .skip
; add 1000s
  lda #$00
  sta digit_3
  lda digit_4
  clc
  adc #$01
  sta digit_4
  cmp #$0A
  bne .skip
; wraparound (it already does at 255 but bleh)
  lda #$00
  sta digit_4
  
.skip:
  dex
  bne .loop
  
  jmp CalcScoreDone