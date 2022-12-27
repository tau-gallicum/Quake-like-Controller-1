extends Button

func _ready():
	self.connect("mouse_entered", self, "_on_Button_mouse_entered")

func _on_Button_mouse_entered():
	get_tree().current_scene.move_to(self.rect_global_position.y)
	self.grab_focus()