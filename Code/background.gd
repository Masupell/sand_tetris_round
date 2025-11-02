class_name Background
extends ColorRect

var pixels_x: float = 1280.0 / Global.size
var pixels_y: float = 720.0 / Global.size


func _ready() -> void:
	print(pixels_y)
	print(pixels_x)
	#material.set_shader_parameter("pixels", Vector2(pixels_x, pixels_y))
