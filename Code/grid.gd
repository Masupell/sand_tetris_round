class_name Grid
extends Node2D

var width = 64
var height = 64

var size = 720.0/64.0 # Based on the height of the screen, 64 "pixels" along it (in the background shader)

var grid = [64*64, 1]

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	for y in height:
		for x in width:
			#var idx = y * width + x
			#var box = grid[idx]
			@warning_ignore("integer_division")
			var gap_x = (1280-width*size)/2
			@warning_ignore("integer_division")
			var gap_y = (720-height*size)/2
			var outer_rect = Rect2(gap_x+x*size, gap_y+y*size, size, size)
			var inner_rect = Rect2(gap_x+x*size+1, gap_y+y*size+1, size-2, size-2)
			draw_rect(outer_rect, Color(1.0, 1.0, 1.0, 0.5))
			draw_rect(inner_rect, Color(1.0, 0.0, 0.0, 0.5))
