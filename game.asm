
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
  INCLUDE "ui.asm"
  INCLUDE "drawing.asm"
  INCLUDE "constants.asm"
  INCLUDE "variables.asm"
  INCLUDE "helpers.asm"
  
vblankwait:
  bit $2002
  bpl vblankwait
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
  cpx #$9C
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
  lda #LOW(bg1)
  sta pointerLo
  lda #HIGH(bg1)
  sta pointerHi
  jsr LoadBG
  
  ; set seed
  lda #$66
  sta rand_seed
  
  ; Init game
  jsr InitShip
  jsr InitAliens
  
  lda #STATE_PLAYING
  sta gamestate
  
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

  lda gamestate
  cmp #STATE_PLAYING
  bne .game_over
  ; playing
  jsr UpdateShip
  jsr UpdateLaser
  jsr UpdateAliens
  jsr UpdateExplosions
  jsr UpdateLabels
  jsr UpdateSprites
  
  ; check state
  lda lives
  bne .done
  lda #STATE_GAMEOVER
  sta gamestate
  
  lda #%00001000 ; disable NMI
  sta $2000
  lda #%00000000 ; disable rendering
  sta $2001
  
  ; bg to game over
  lda #LOW(gameover_bg)
  sta pointerLo
  lda #HIGH(gameover_bg)
  sta pointerHi
  jsr LoadBG
  
  lda #%10001000
  sta $2000 ; set PPUCTRL
  lda #%10011110
  sta $2001 ; set PPUMASK
  lda #%00000000
  
.game_over:
  lda #%00001000
  sta $2001 ; clear sprites on screen
  
  lda ctrl_1
  and #%00010000
  beq .done
  
  ; Init game
  jsr InitShip
  jsr InitAliens
  lda #STATE_PLAYING
  sta gamestate
  lda #$00
  sta score
  sta ship_damage_cooldown
  
  ; bg to sky
  lda #%00001000 ; disable NMI
  sta $2000
  lda #%00000000 ; disable rendering
  sta $2001
  lda #LOW(bg1)
  sta pointerLo
  lda #HIGH(bg1)
  sta pointerHi
  jsr LoadBG
  lda #%10001000
  sta $2000 ; set PPUCTRL
  lda #%10011110
  sta $2001 ; set PPUMASK
  lda #%00000000
  
.done:

; END GAME ENGINE
  rti
	
; === END NMI INTERRUPT ===
; =========================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PROGRAM - DATA & INTERRUPTS
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
	.db $30, $02, %00000010, $80   ;1C
	.db $30, $03, %00000010, $88   ;20
	.db $38, $12, %00000010, $80   ;24
	.db $38, $13, %00000010, $88   ;28
	
	.db $30, $02, %00000010, $A0   ;2C
	.db $30, $03, %00000010, $A8   ;30
	.db $38, $12, %00000010, $A0   ;34
	.db $38, $13, %00000010, $A8   ;38
	
	.db $30, $02, %00000010, $C0   ;3C
	.db $30, $03, %00000010, $C8   ;40
	.db $38, $12, %00000010, $C0   ;44
	.db $38, $13, %00000010, $C8   ;48
	
	.db $30, $02, %00000010, $50   ;4C
	.db $30, $03, %00000010, $58   ;50
	.db $38, $12, %00000010, $50   ;54
	.db $38, $13, %00000010, $58   ;58
	
	; score label
	.db $10, $04, %00000010, $58   ;5C
	.db $10, $04, %00000010, $50   ;60
	.db $10, $04, %00000010, $48   ;64
	.db $10, $04, %00000010, $40   ;68
	
	; score text label
	.db $10, $14, %00000010, $10   ;6C
	.db $10, $15, %00000010, $18   ;70
	.db $10, $16, %00000010, $20   ;74
	.db $10, $17, %00000010, $28   ;78
	.db $10, $18, %00000010, $30   ;7C
	.db $10, $19, %00000010, $38   ;80
	
	; life label
	.db $18, $04, %00000010, $40   ;84
	
	; life text label
	.db $18, $24, %00000010, $10   ;88
	.db $18, $25, %00000010, $18   ;8C
	.db $18, $26, %00000010, $20   ;90
	.db $18, $18, %00000010, $28   ;94
	.db $18, $19, %00000010, $38   ;98
	
	
	palette:
	; bg pal
	.db $0F,$1F,$30,$1F, $0F,$1F,$30,$1F, $0F,$1F,$30,$1F, $0F,$1F,$30,$1F
	; sprite pal
	.db $0F,$00,$0C,$05, $0F,$25,$30,$15, $0F,$30,$24,$21, $0F,$00,$00,$00
	
	bg1:
	.incbin "bg1.nam"
	gameover_bg:
	.incbin "gameover.nam"
  
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