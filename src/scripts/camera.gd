extends Camera

onready var plr := get_tree().current_scene.get_node("Actors/Player")
onready var head : Node = get_parent()

var x_axis : float
var y_axis : float

var bobbing_enabled : bool = false
var roll_enabled : bool = true

# The higher the more it tilts
var roll_value : float = 2

func _physics_process(delta) -> void:
	if plr.is_on_floor() && roll_enabled:
		head.rotation_degrees.z = lerp(head.rotation_degrees.z, -roll_value * x_axis, 5 * delta)
	elif not plr.is_on_floor():
		head.rotation_degrees.z = lerp(head.rotation_degrees.z, 0, 5 * delta)

	x_axis = Input.get_action_raw_strength("right") - Input.get_action_raw_strength("left")
	y_axis = Input.get_action_raw_strength("forward") - Input.get_action_raw_strength("backward")
