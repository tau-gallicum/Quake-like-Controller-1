extends Label

onready var player : Player = get_parent().get_parent()

func _physics_process(_delta):
	text = str(round(player.h_velocity.length()))