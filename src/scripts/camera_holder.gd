extends Spatial

onready var player : Player = get_parent()

onready var footstep = $Camera/FootstepPlayer
onready var jump = $Camera/JumpPlayer
onready var land = $Camera/LandPlayer

onready var chromatic_overlay : ColorRect = player.get_node("HUD/ChromaticOverlay")
var cam_trans : float 

var footstep_sounds = [
	preload("res://Assets/Sounds/footstep_01.wav"),
	preload("res://Assets/Sounds/footstep_02.wav"),
	preload("res://Assets/Sounds/footstep_03.wav"),
	preload("res://Assets/Sounds/footstep_04.wav"),
	preload("res://Assets/Sounds/footstep_05.wav"),

]

var impact_sounds = [
	preload("res://Assets/Sounds/impact_01.wav"),
	preload("res://Assets/Sounds/impact_02.wav"),
	preload("res://Assets/Sounds/impact_03.wav"),
	preload("res://Assets/Sounds/impact_04.wav"),
	preload("res://Assets/Sounds/impact_05.wav"),
	preload("res://Assets/Sounds/impact_06.wav"),
	preload("res://Assets/Sounds/impact_07.wav"),
	preload("res://Assets/Sounds/impact_08.wav"),
	preload("res://Assets/Sounds/impact_09.wav"),
	preload("res://Assets/Sounds/impact_10.wav"),

]

func _physics_process(delta):
	if player.h_velocity.length() >= player.MAX_CROUCHED_ACCEL - 1.0 && player.is_on_floor()	:
		if $Timer.time_left <= 0:
			play_random_sound(0.05 if !player.is_crouching else 0.01, footstep, footstep_sounds)
			$Timer.start(0.4 * player.MAX_ACCEL / (player.h_velocity.length()))
	

	if player.just_jumped:
		play_random_sound(db2linear(jump.volume_db), jump, impact_sounds)

	elif player.just_landed:
		if player.high_land:
			play_random_sound(1, land, impact_sounds)
		else:
			play_random_sound(0.2, land, impact_sounds)
		
		player.high_land = false if player.high_land else false

	cam_trans = cos(player.bobbing_value) * 0.1

	player.camera.transform.origin.y = cam_trans if player.is_on_floor() and player.velocity.length() > player.MAX_ACCEL - 5 and !player.is_crouching else lerp(player.camera.transform.origin.y, 0.0, delta)
	
	chromatic_overlay.material.set_shader_param("spread", 0.005 + (player.velocity.length() / player.MAX_ACCEL) * 0.002)

func play_random_sound(volume = 1.0, sound_player : AudioStreamPlayer = null, sounds : Array = []):
	var current = sounds[0]
	sound_player.stream = current
	sound_player.volume_db = linear2db(volume)
	sound_player.play()
	sounds.shuffle()
	sounds.erase(current)
	sounds.push_back(current)

func remap_range(value, InputA, InputB, OutputA, OutputB):
	return(value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA