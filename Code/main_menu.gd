class_name Main
extends CanvasLayer

var world = preload("res://scenes/World.tscn")

@onready var menu = $UI/Menu
@onready var level = $UI/LevelSelect

func _on_button_pressed() -> void:
	menu.hide()
	level.show()


func _on_button_2_pressed() -> void:
	get_tree().quit()


func _on_left_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		switch_scene(32)


func _on_middle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		switch_scene(64)


func _on_right_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		switch_scene(128)

func switch_scene(pixels: int):
	var new_scene = world.instantiate()
	new_scene.set("pixels", pixels)
	get_tree().root.add_child(new_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = new_scene
