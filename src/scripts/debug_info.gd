extends Control

var properties : Array = []

func add_property(object, property):
	var label : Label = Label.new()
	label.set("custom_colors/font_color", Color(0.85,0.85,0.85,1))
	label.set("custom_colors/font_color_shadow", Color(0,0,0,1))
	label.set("custom_constants/shadow_offset_x", 2.5)
	label.set("custom_constants/shadow_offset_y", 2.5)
	label.set("custom_fonts/font", load("res://Assets/debug_info_font.tres"))
	$InfoList.add_child(label)
	properties.append(Property.new(object, property, label))
	return self

func remove_property(object, property):
	for prop in properties:
		if prop.object == object and prop.property == property:
			properties.erase(prop)

class Property:
	var object
	var property
	var label

	func _init(_object : Node, _property, _label : Label):
		object = _object
		property = _property
		label = _label

	func set_label():
		label.text = object.name + ":"
		var s : String

		match typeof(object.get_indexed(property)):
			TYPE_VECTOR3:
				s = str(stepify(object.get_indexed(property).x, 0.001)) + " " + str(stepify(object.get_indexed(property).y, 0.001)) + " " + str(stepify(object.get_indexed(property).z, 0.001))
			_:
				s = str(object.get_indexed(property))
		
		label.text += property + ": " + s

func _process(_delta):
	if not visible:
		return
	
	for prop in properties:
		prop.set_label()
