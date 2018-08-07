; Variables

	.rsset $0000
	
; controllers
ctrl_1		.rs 1
ctrl_2		.rs 1

score		.rs 1
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
curr_laser_mask	.rs 1
laser_cooldown	.rs 1
; keep this ordering!
laser_1_x		.rs 1
laser_2_x		.rs 1
laser_3_x		.rs 1
laser_1_y		.rs 1
laser_2_y		.rs 1
laser_3_y		.rs 1
; keep this ordering!

; alien vars
alien_mask		.rs 1
curr_alien_mask	.rs 1
alien_1_x		.rs 1
alien_2_x		.rs 1
alien_3_x		.rs 1
alien_4_x		.rs 1
alien_1_y		.rs 1
alien_2_y		.rs 1
alien_3_y		.rs 1
alien_4_y		.rs 1

alien_1_dir		.rs 1
alien_2_dir		.rs 1
alien_3_dir		.rs 1
alien_4_dir		.rs 1

; explosions for each alien
exp_mask		.rs 1
curr_exp_mask	.rs 1
exp_cooldown_1	.rs 1
exp_cooldown_2	.rs 1
exp_cooldown_3	.rs 1
exp_cooldown_4	.rs 1

; score
digit_1			.rs 1
digit_2			.rs 1
digit_3			.rs 1
digit_4			.rs 1

; temp vars
temp			.rs 1
temp2			.rs 1