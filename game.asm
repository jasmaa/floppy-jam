
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .inesprg 1
  .ineschr 1
  .inesmap 0
  .inesmir 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; VARIABLES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  .rsset $0000

gamestate	.rs 1
ctrl_1		.rs 1
ctrl_2		.rs 1
rand_seed	.rs 1
pointerLo	.rs 1
pointerHi	.rs 1

STATE_TITLE		= $00
STATE_PLAYING	= $01
STATE_GAMEOVER	= $02
  
RWALL		= $F4
UWALL		= $20
DWALL		= $E0
LWALL		= $04

PADDLE_1_X	= $20
PADDLE_2_X	= $E0
PADDLE_1_H	= $18
PADDLE_2_H	= $18
PADDLE_SPEED= $02

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PROGRAM - MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .bank 0
  .org $C000

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
LoadBGLoop:
  lda [pointerLo], y	; can only be used with y
  sta $2007
  iny
  bne LoadBGLoop
  inc pointerHi
  inx
  cpx #$04
  bne LoadBGLoop
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
LoadSpritesLoop:
  lda sprites, x
  sta $0200, x
  inx
  cpx #$24
  bne LoadSpritesLoop

;LoadPalette:
;  lda $2002
;  lda #$3F
;  sta $2006
;  lda #$00
;  sta $2006
;  ldx #$00
;LoadPaletteLoop:
;  lda palette, x
;  sta $2007
;  inx
;  cpx #$20
;  bne LoadPaletteLoop

; bg to title
  ;lda #LOW(title_bg)
  ;sta pointerLo
  ;lda #HIGH(title_bg)
  ;sta pointerHi
  ;jsr LoadBG
  
  ; set init state
  lda #STATE_TITLE
  sta gamestate
  
  ; set seed
  lda #$66
  sta rand_seed
  
  ; set ppu
  lda #%10010000
  sta $2000
  lda #%10011110	; make blue for now
  sta $2001
  
Forever:
  jmp Forever
  
; === END RESET ===
; ================= 

; ===========================
; === START NMI INTERRUPT ===
NMI:
  rti ; short circuit for now

  ; set RAM address to 0200
  lda #$00
  sta $2003
  lda #$02
  sta $4014
  
  ; ppu clean up
  lda #%10010000
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
; put game engine here
; END GAME ENGINE

; read controllers
ReadCtrl1:
  lda #$01
  sta $4016
  lda #$00
  sta $4016
  ldx #$08
ReadCtrl1Loop:
  lda $4016
  lsr A
  rol ctrl_1
  dex
  bne ReadCtrl1Loop
  rts

ReadCtrl2:
  lda #$01
  sta $4016
  lda #$00
  sta $4016
  ldx #$08
ReadCtrl2Loop:
  lda $4017
  lsr A
  rol ctrl_2
  dex
  bne ReadCtrl2Loop
  rts
	
; === END NMI INTERRUPT ===
; =========================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PROGRAM - INTERRUPTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .bank 1
  
  .org $E000
  sprites:
    .db $0F,$17,$28,$39, $0F,$17,$28,$39, $0F,$17,$28,$39, $0F,$17,$28,$39 
	.db $0F,$17,$28,$39, $0F,$17,$28,$39, $0F,$17,$28,$39, $0F,$17,$28,$39
	
  palette:
    .db $0F,$17,$28,$39, $0F,$17,$28,$39, $0F,$17,$28,$39, $0F,$17,$28,$39 
	.db $0F,$17,$28,$39, $0F,$17,$28,$39, $0F,$17,$28,$39, $0F,$17,$28,$39
  
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