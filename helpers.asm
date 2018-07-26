; Helper code

; update random num
prng:
  ldx #$08
  lda rand_seed+0
  prng_1:
    asl A
    rol rand_seed+1
    bcc prng_2
    eor #$2D
  prng_2:
	dex
	bne prng_1
	sta rand_seed+0
	cmp #$00 ; reload flags
	rts