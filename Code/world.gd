class_name World
extends Node2D

@export var pixels = 32
var pause: bool = false

@onready var grid = $Grid
@onready var blur = $Blur
@onready var score_label = $Score

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
		blur.show()
	else:
		blur.hide()

func _physics_process(delta: float) -> void:
	if !pause:
		grid.update(delta)
		score_label.text = str(grid.score/10) # Better with signal probably, but works for now
