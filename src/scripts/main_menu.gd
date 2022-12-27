extends Control

onready var focus = $Focus
onready var play_button = $VBoxContainer/PlayButton

var pos = [
	Vector2(0.09, -0.069),
	Vector2(0.143, 0.1),
	Vector2(-0.037, -0.145),
	Vector2(-0.026, 0.233),
]

func _ready():
	move_to(play_button.rect_global_position.y)

func move_to(new : float):
	$Tween.interpolate_property(focus, "rect_position:y", focus.rect_position.y, new, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()