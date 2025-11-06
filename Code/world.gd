class_name World
extends Node2D

@export var pixels = 64

func _ready() -> void:
	randomize()
	$Grid.height = pixels
	$Grid.width = pixels
	$Grid.setup()
	$Background.material.set_shader_parameter("pixels", pixels)
