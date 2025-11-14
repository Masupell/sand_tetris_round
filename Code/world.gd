class_name World
extends Node2D

@export var pixels = 32
var pause: bool = false

@onready var grid = $Grid
@onready var blur = $Blur
@onready var score_label_one = $Score

@onready var ui = $CanvasLayer/UI
@onready var score_label_two = $CanvasLayer/UI/MarginContainer/VBoxContainer/Score
@onready var high_score_label = $CanvasLayer/UI/MarginContainer/VBoxContainer/Highscore

var high_score := 0

func _ready() -> void:
	randomize()
	grid.height = pixels
	grid.width = pixels
	grid.setup()
	$Background.material.set_shader_parameter("pixels", pixels)

func _input(event: InputEvent) -> void:
	if event.is_action_released("pause"):
		pause = !pause
		toggle_pause(pause)
	if event.is_action_released("space") && !pause:
		grid.spawn_tetris()

func toggle_pause(paused: bool):
	if paused:
		score_label_one.hide()
		blur.show()
		ui.show()
	else:
		score_label_one.show()
		blur.hide()
		ui.hide()

func _physics_process(delta: float) -> void:
	if !pause:
		grid.update(delta)
		if grid.score > high_score:
			high_score = grid.score
		score_label_one.text = str(grid.score/10) # Better with signal probably, but works for now
		score_label_two.text = "  Score: %d" % (grid.score / 10)
		@warning_ignore("integer_division")
		high_score_label.text = " HighScore: %d" % (high_score/10)


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
