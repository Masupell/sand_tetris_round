class_name Main
extends CanvasLayer

var world = preload("res://scenes/World.tscn")

@onready var menu = $UI/Menu
@onready var level = $UI/LevelSelect

@onready var left = $UI/LevelSelect/Left
@onready var middle = $UI/LevelSelect/Middle
@onready var right = $UI/LevelSelect/Right

func _on_button_pressed() -> void:
	menu.hide()
	level.show()


func _on_button_2_pressed() -> void:
	get_tree().quit()


func _on_left_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		switch_scene(32)

func _on_left_mouse_entered() -> void:
	var t = get_tree().create_tween().set_parallel()
	t.tween_property(left, "size", Vector2(382, 214), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(left, "position", Vector2(150 - 44.5, 278 - 25.0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_left_mouse_exited() -> void:
	var t = get_tree().create_tween().set_parallel()
	t.tween_property(left, "size", Vector2(293, 164), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(left, "position", Vector2(150, 278), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)



func _on_middle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		switch_scene(64)

func _on_middle_mouse_entered() -> void:
	var t = get_tree().create_tween().set_parallel()
	t.tween_property(middle, "size", Vector2(382, 214), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(middle, "position", Vector2(493 - 44.5, 278 - 25.0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_middle_mouse_exited() -> void:
	var t = get_tree().create_tween().set_parallel()
	t.tween_property(middle, "size", Vector2(293, 164), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(middle, "position", Vector2(493, 278), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)



func _on_right_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		switch_scene(128)

func _on_right_mouse_entered() -> void:
	var t = get_tree().create_tween().set_parallel()
	t.tween_property(right, "size", Vector2(382, 214), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(right, "position", Vector2(836 - 44.5, 278 - 25.0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_right_mouse_exited() -> void:
	var t = get_tree().create_tween().set_parallel()
	t.tween_property(right, "size", Vector2(293, 164), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(right, "position", Vector2(836, 278), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_back_pressed() -> void:
	menu.show()
	level.hide()


func switch_scene(pixels: int):
	var new_scene = world.instantiate()
	new_scene.set("pixels", pixels)
	get_tree().root.add_child(new_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = new_scene
