class_name Grid
extends Node2D

var width = 64
var height = 64

var size = 720.0/64.0 # Based on the height of the screen, 64 "pixels" along it (in the background shader)

var grid = []

var radius = 0.9 # Same as the shaders, need to make it global or put both together or something like that

@warning_ignore("integer_division")
var center = Vector2(width/2,height/2)

var time_passed: float = 0.0
var interval: float = 1.0

enum CellType { EMPTY, SAND, WATER, WALL, BARRIER}

class Cell:
	var type: int = CellType.EMPTY
	var extra: int = 0 # Not needed except for water later (moving left or right)
	var vel: Vector2 = Vector2.ZERO
	
	func _init(_type: int = 0, _extra: int = 0) -> void:
		type = _type
		extra = _extra


func _ready() -> void:
	grid.resize(64*64)
	circle()
	#grid[2080].type = CellType.SAND
	queue_redraw()

func _physics_process(delta: float) -> void:
	time_passed += delta
	if time_passed >= interval:
		update_sand()
		time_passed = 0.0
	queue_redraw()

func circle():
	for y in height:
		for x in width:
			var uv_x = (x + 0.5) / width
			var uv_y = (y + 0.5) / height
			var dx = uv_x - 0.5
			var dy = uv_y - 0.5
			
			var dist = dx*dx + dy*dy
			dist *= 4.0

			var type = CellType.EMPTY if dist < radius else CellType.BARRIER
			var cell = Cell.new(type)
			var idx = y * width + x
			grid[idx] = cell

func _draw() -> void:
	for y in height:
		for x in width:
			var idx = y * width + x
			var box = grid[idx]
			#if box == 0:
				#continue
			#@warning_ignore("integer_division")
			#var gap_x = (1280-width*size)/2
			#@warning_ignore("integer_division")
			#var gap_y = (720-height*size)/2
			#var outer_rect = Rect2(gap_x+x*size, gap_y+y*size, size, size)
			#var inner_rect = Rect2(gap_x+x*size+1, gap_y+y*size+1, size-2, size-2)
			#draw_rect(outer_rect, Color(1.0, 1.0, 1.0, 0.5))
			#draw_rect(inner_rect, Color(1.0, 0.0, 0.0, 0.5))
			match box.type:
				CellType.SAND: # Only Sand for now, but still match, so I just have to add water, etc later
					@warning_ignore("integer_division")
					var gap_x = (1280-width*size)/2
					@warning_ignore("integer_division")
					var gap_y = (720-height*size)/2
					var rect = Rect2(gap_x+x*size, gap_y+y*size, size, size)
					draw_rect(rect, Color(0.753, 0.898, 0.227, 1.0))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		var pos = event.position
		print(pos)
		var grid_pos = Vector2i((pos.x-(1280-width*size)/2)/size, pos.y/size)
		print(grid_pos)
		#var idx = grid_pos.y * width + grid_pos.x
		#grid[idx] = 0 if grid[idx] == 1 else 1
	if event.is_action_released("ui_accept"):
		spawn_sand()

func spawn_sand(): #Spawns a single sand-block in the center
	var idx = center.y * width + center.x + 1
	print(idx)
	if grid[idx].type == CellType.EMPTY:
		var angle = randf_range(0.0, TAU)
		var dir = Vector2(cos(angle), sin(angle))
		grid[idx].type = CellType.SAND
		grid[idx].vel = dir

func update_sand():
	for y in height:
		for x in width:
			var idx = y * width + x
			var cell = grid[idx]
			if cell.type != CellType.SAND:
				continue
			
			var pos = Vector2(x, y)
			var dir = (pos-center).normalized()
			var target = pos + dir.round()
			
			var target_idx = target.y as int * width + target.x as int
			if grid[target_idx].type == CellType.EMPTY:
				grid[target_idx].type = CellType.SAND
				cell.type = CellType.EMPTY
