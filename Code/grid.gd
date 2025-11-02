@tool
class_name Grid
extends Node2D

var width = 127
var height = 64

var size = 15#Global.size
var pixels_x: float = 1280.0 / Global.size
var pixels_y: float = 720.0 / Global.size

var grid = [127*64, 1]

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	for y in height:
		for x in width:
			var idx = y * width + x
			if idx % 2 == 0:
				continue
			#var box = grid[idx]
			@warning_ignore("integer_division")
			var gap_x = 0#(1280-width*size)/2
			@warning_ignore("integer_division")
			var gap_y = 0#(720-height*size)/2
			var outer_rect = Rect2(gap_x+x*size, gap_y+y*size, size, size)
			#print("pos:", outer_rect.position, "floor:", outer_rect.position.floor())
			#print("size:", outer_rect.size)
			var inner_rect = Rect2(gap_x+x*size+1, gap_y+y*size+1, size-2, size-2)
			draw_rect(outer_rect, Color(1.0, 1.0, 1.0, 0.5))
			draw_rect(inner_rect, Color(1.0, 0.0, 0.0, 0.5))
