extends Node

enum POWERUP {
	BASE,
	METAL,
}


var Game = {
	
	Player = {
		
		Attribute = {
			movement_speed = 1.0,
			jump_strength = 1.0,
			spin_air_strength = 1.0,
			gravity = 1.0,
		},
		
		Shader = {
			opacity = 1.0,
			saturation = 1.0,
			brightness = 1.0,
			contrast = 1.0,
		},
		
		State = {
			walking = false,
			in_air = false,
			in_water = false,
		},
		
		Modifier = {
			invulnerable = false,
			metal = false,
		}
		
	}
}

#######
## PLAYER HANDLING
#######

func grant_powerup(powerup: POWERUP):
	var powerup_music
	match powerup: 
		POWERUP.METAL: 
			if Game.Player.Modifier.metal:
				get_tree().root.get_node("MetalMarioTimer").start(30)
				apply_powerup_modifiers()
				return
			powerup_music = get_tree().root.get_node("/root/Main/Player/PowerupHandler/MetalMario/MetalMarioMusic") # This can probably be improved in some way
			Singleton.add_child(powerup_music.duplicate())
			Singleton.get_node("Music").volume_db = -INF 
			Singleton.get_node("MetalMarioMusic").play() 
			Game.Player.Modifier.metal = true


	apply_powerup_modifiers()

func revoke_powerup(powerup: POWERUP):
	match powerup:
		POWERUP.METAL: 
			Game.Player.Modifier.metal = false
			Singleton.get_node("Music").volume_db = -8.0
			Singleton.get_node("MetalMarioMusic").free()
			get_tree().root.get_node("MetalMarioTimer").free()

	apply_powerup_modifiers()

func apply_powerup_modifiers():
	var player_attributes = Game.Player.Attribute
	var player_state = Game.Player.State
	var player_shader = Game.Player.Shader
	var modifiers = Game.Player.Modifier
	
	## DEFAULT VALUES
	player_attributes.movement_speed = 1.0
	player_attributes.jump_strength = 1.0
	player_attributes.spin_air_strength = 1.0
	player_attributes.gravity = 1.0
	player_shader.opacity = 1.0
	player_shader.brightness = 1.0
	player_shader.saturation = 1.0
	modifiers.invulnerable = false
	
	## THESE ARE WHAT WILL *NOT* CHANGE, IF SOMETHING CHANGES DEPENDING ON CIRCUMSTANCES
	## IT WOULD BE BEST TO SEPERATE THAT CODE THAN RUN ALL OF THIS AT ONCE
	if modifiers.metal:               	# METAL MARIO: Constant Attributes
		player_attributes.movement_speed = 0.75
		player_shader.saturation = 0.0
		player_shader.contrast = 0.8
		player_shader.brightness = 1.0
		modifiers.invulnerable = true

func metal_mario_handler():
	if !Global.Game.Player.Modifier.metal: return
	var player_attributes = Game.Player.Attribute
	var player_state = Game.Player.State
	
	if not player_state.in_water: 	# METAL MARIO: Not in water
		player_attributes.jump_strength = 0.9
		player_attributes.spin_air_strength = 0.45
		player_attributes.gravity = 1.1

	else:                         	# METAL MARIO: In water
		player_attributes.jump_strength = 0.575
		player_attributes.spin_air_strength = 0.2
		player_attributes.gravity = 0.45


#######
## GLOBAL NODE CONTROL
#######

func play_sound(sound: AudioStreamPlayer):
	if Singleton.get_node("" + sound.name): return
	else:
		Singleton.add_child(sound.duplicate())
		Singleton.get_node("" + sound.name).play()

func stop_sound(sound: String):
	Singleton.get_node("" + sound).free()

func start_timer(node: Timer, secs: float = node.time_left):
	if get_tree().root.get_node("/root/" + node.name): return
	else:
		get_tree().root.add_child(node.duplicate())
		get_tree().root.get_node("/root/" + node.name).start(secs)

