extends CanvasLayer

func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_cancel") and !get_tree().paused:
		_pause_game()

func _ready():
	_resume_game()

func _pause_game() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	visible = true
	$PauseTransitionPlayer.play("Appear")

	get_tree().paused = true
		
func _resume_game() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	visible = false
	$PauseTransitionPlayer.play("RESET")
	get_tree().paused = false

func _quit_game() -> void:
	get_tree().quit()

func _on_ContinueButton_pressed():
	_resume_game()

func _on_QuitButton_pressed():
	_quit_game()

