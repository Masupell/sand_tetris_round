class_name World
extends Node2D

const SAVE_PATH := "user://save.tres"

@export var pixels = 32
var pause: bool = false

@onready var grid = $Grid
@onready var blur = $Blur
@onready var score_label_one = $Score

@onready var ui = $CanvasLayer/UI
@onready var score_label_two = $CanvasLayer/UI/MarginContainer/VBoxContainer/Score
@onready var high_score_label = $CanvasLayer/UI/MarginContainer/VBoxContainer/Highscore

var high: HighScore = null

func _ready() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		var res = ResourceLoader.load(SAVE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
		if res is HighScore:
			high = res
		else:
			HighScore.new()
	else:
		high = HighScore.new()
	@warning_ignore("integer_division")
	high_score_label.text = "  HighScore: %d" % (high.high_score/10)
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
		if grid.score > high.high_score:
			high.high_score = grid.score
			@warning_ignore("integer_division")
			high_score_label.text = "  HighScore: %d" % (high.high_score/10)
			save()
		score_label_one.text = str(grid.score/10) # Better with signal probably, but works for now
		score_label_two.text = "  Score: %d" % (grid.score / 10)


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()

func save() -> void:
	var error_code := ResourceSaver.save(high, SAVE_PATH)
	if error_code != OK:
		push_error("Failed to save game: " + error_string(error_code))
