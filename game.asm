
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .inesprg 1
  .ineschr 1
  .inesmap 0
  .inesmir 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PROGRAM - MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .bank 0
  .org $C000

  ; includes
  INCLUDE "aliens.asm"
  INCLUDE "controller.asm"
  INCLUDE "spaceship.asm"
  INCLUDE "drawing.asm"
  INCLUDE "constants.asm"
  INCLUDE "variables.asm"
  
vblankwait:
  bit $2002
  bpl vblankwait
  rts

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

LoadBG:
  lda $2002
  lda #$20	; remember top row doesn't get rendered
  sta $2006
  lda #$00
  sta $2006
  ldx #$00
  ldy #$00
  
; Load entire BG
.loop:
  lda [pointerLo], y	; can only be used with y
  sta $2007
  iny
  bne .loop
  inc pointerHi
  inx
  cpx #$04
  bne .loop
  rts
	
; ===================  
; === START RESET ===

RESET:
  ; disable irq
  sei
  cld
  ldx #%01000000
  stx $4017
  
  ; set up stack
  ldx #$FF
  txs
  
  ldx #$00
  stx $2000 ; disable NMI
  stx $2001 ; disable rendering
  stx $4010 ; disable dmc

  ; 1st vblank
  jsr vblankwait
  
  ldx #$00
clrmem:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  lda #$FE
  sta $0300, x
  inx
  bne clrmem ; loop until x overflows

  ; 2nd vblank
  jsr vblankwait
  
LoadSprites:
  ldx #$00
.loop:
  lda sprites, x
  sta $0200, x
  inx
  cpx #$2C
  bne .loop

LoadPalette:
  lda $2002
  lda #$3F
  sta $2006
  lda #$00
  sta $2006
  ldx #$00
.loop:
  lda palette, x
  sta $2007
  inx
  cpx #$20
  bne .loop

; bg to title
  ;lda #LOW(title_bg)
  ;sta pointerLo
  ;lda #HIGH(title_bg)
  ;sta pointerHi
  ;jsr LoadBG
  
  ; set seed
  lda #$66
  sta rand_seed
  
  ; inits
  jsr InitShip
  jsr InitAliens
  
  ; set ppu
  lda #%10001000
  sta $2000
  lda #%10011110
  sta $2001
  
Forever:
  jmp Forever
  
; === END RESET ===
; ================= 

; ===========================
; === START NMI INTERRUPT ===
NMI:
  ; set RAM address to 0200
  lda #$00
  sta $2003
  lda #$02
  sta $4014
  
  ; ppu clean up
  lda #%10001000
  sta $2000 ; set PPUCTRL
  lda #%10011110
  sta $2001 ; set PPUMASK
  lda #%00000000
  sta $2005 ; disable PPU scrolling
  sta $2005
  
  ; read controllers
  jsr ReadCtrl1
  jsr ReadCtrl2
  
; GAME ENGINE

  jsr UpdateShip
  jsr UpdateLaser
  jsr UpdateAliens
  
  jsr UpdateSprites

; END GAME ENGINE
  rti
	
; === END NMI INTERRUPT ===
; =========================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PROGRAM - INTERRUPTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .bank 1
  
  .org $E000
	sprites:
	; spaceship
	.db $10, $00, %00000000, $80   ;00
	.db $10, $00, %01000000, $88   ;04
	.db $18, $10, %00000000, $80   ;08
	.db $18, $10, %01000000, $88   ;0C
	
	; lasers
	.db $18, $01, %00000001, $18   ;10
	.db $18, $01, %00000001, $28   ;14
	.db $18, $01, %00000001, $38   ;18
    
	; aliens
	.db $10, $02, %00000010, $80   ;1C
	.db $10, $03, %00000010, $88   ;20
	.db $18, $12, %00000010, $80   ;24
	.db $18, $13, %00000010, $88   ;28
	
	palette:
	; bg pal
	.db $0F,$1F,$1F,$1F, $0F,$00,$0C,$05, $0F,$00,$0C,$05, $0F,$00,$0C,$05
	; sprite pal
	.db $0F,$00,$0C,$05, $0F,$25,$00,$00, $0F,$30,$24,$21, $0F,$00,$00,$00
  
  ; vectors
  .org $FFFA
  .dw NMI
  .dw RESET
  .dw 0 ; no irq interrupt

  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CHARACTER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .bank 2
  .org $0000
  .incbin "graphics.chr"