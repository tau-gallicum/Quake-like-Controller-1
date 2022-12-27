extends CanvasLayer

onready var player : Player = get_parent()
onready var start_player : AnimationPlayer = $StartAnimationPlayer

var relative_mouse : Vector2

var offset_y : float

var hud_trans : float

func _unhandled_input(event : InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			relative_mouse = event.relative

func _ready():
	start_player.play("Start")

func _process(delta):
	print($VelocityLabel.rect_position)
	offset = offset.linear_interpolate(Vector2(clamp(relative_mouse.x, -50, 50), clamp(relative_mouse.y, -20, 20)), 10 * delta) if relative_mouse.length() > 1\
	else offset.linear_interpolate(Vector2.ZERO, 10 * delta)

	offset += Vector2(0, offset_y)
	
	hud_trans = cos(player.bobbing_value) * 1

	if player.is_on_floor() and player.input_vector.length() > 0 and !player.is_crouching:
		offset_y = hud_trans
	else:
		offset_y = lerp(offset_y, 0, 10 * delta)

	$VelocityLabel.text = str(round(player.h_velocity.length()))
