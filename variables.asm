; Variables

	.rsset $0000
	
; controllers
ctrl_1		.rs 1
ctrl_2		.rs 1

gamestate	.rs 1
rand_seed	.rs 1
pointerLo	.rs 1
pointerHi	.rs 1

; ship control vars
ship_x		.rs 1
ship_y		.rs 1
ship_speed	.rs 1

; laser var
laser_mask		.rs 1	; bit mask to control laser on/off
laser_cooldown	.rs 1
; keep this ordering!
laser_1_x		.rs 1
laser_2_x		.rs 1
laser_3_x		.rs 1
laser_1_y		.rs 1
laser_2_y		.rs 1
laser_3_y		.rs 1
; keep this ordering!

curr_laser_mask	.rs 1

; alien vars
alien_1_x		.rs 1
alien_1_y		.rs 1