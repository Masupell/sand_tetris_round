class_name World
extends ColorRect

func _ready() -> void:
	get_viewport().size_changed.connect(size_changed)

func size_changed():
	#var size = get_viewport().get_visible_rect().size
	print(material)
