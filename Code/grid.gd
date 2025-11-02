class_name Grid
extends Node2D

var width = 64
var height = 64

var size = 720.0/64.0 # Based on the height of the screen, 64 "pixels" along it (in the background shader)

var grid = []

var radius = 0.9 # Same as the shaders, need to make it global or put both together or something like that

func _ready() -> void:
	circle()
	queue_redraw()

func _draw() -> void:
	for y in height:
		for x in width:
			var idx = y * width + x
			var box = grid[idx]
			if box == 0:
				continue
			@warning_ignore("integer_division")
			var gap_x = (1280-width*size)/2
			@warning_ignore("integer_division")
			var gap_y = (720-height*size)/2
			var outer_rect = Rect2(gap_x+x*size, gap_y+y*size, size, size)
			var inner_rect = Rect2(gap_x+x*size+1, gap_y+y*size+1, size-2, size-2)
			draw_rect(outer_rect, Color(1.0, 1.0, 1.0, 0.5))
			draw_rect(inner_rect, Color(1.0, 0.0, 0.0, 0.5))


func circle():
	grid.resize(64*64)
	for y in height:
		for x in width:
			var uv_x = (x + 0.5) / width
			var uv_y = (y + 0.5) / height
			var dx = uv_x - 0.5
			var dy = uv_y - 0.5
			
			var dist = dx*dx + dy*dy
			dist *= 4.0

			var value = 1 if dist < radius else 0
			var idx = y * width + x
			grid[idx] = value


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var pos = event.position
		print(pos)
		var grid_pos = Vector2i(pos.x/size, pos.y/size)
		print(grid_pos)
		
