extends ColorRect

var time:float = 0.0

func _process( delta:float ):
	time += delta
	material.set_shader_param( "fade", clamp( time, 0.0, 1.0 ) )