class_name Grid
extends Node2D

var width: int# = 64
var height: int# = 64

var size = 720.0#/height # Based on the height of the screen, 64 "pixels" along it (in the background shader)

var min_cluster_size: int

var grid = []
var sand_cells = []
var sand_map = {}

var radius = 0.9 # Same as the shaders, need to make it global or put both together or something like that

#@warning_ignore("integer_division")
var center: Vector2# = Vector2(width/2,height/2)

var time_passed: float = 0.0
var circle_check_timer: float = 0.0
var interval: float = 0.05
var circle_time: float = 0.25


var tetris_pieces: Array = []
var anchor: Vector2i
var piece_active: bool = false
var tetris_color: Color

#enum SHAPES {STRAIGHT, SQUARE, LSHAPE, TSHAPE, DIAGONAL}
var TETRIS_SHAPES = { # A lot of manual values, but works for now and need 0,0 as rotation and anchor point
	straight = [Vector2i(-2,0), Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(2, 0)],
	square = [
			Vector2i(-2,-2), Vector2i(-1,-2), Vector2i(0,-2), Vector2i(1,-2), Vector2i(2,-2), 
			Vector2i(-2,-1), Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1), Vector2i(2,-1), 
			Vector2i(-2,0), Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), 
			Vector2i(-2,1), Vector2i(-1,1), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), 
			Vector2i(-2,2), Vector2i(-1,2), Vector2i(0,2), Vector2i(1,2), Vector2i(2,2)],
	l_shape =  [Vector2i(0,-2), Vector2i(0,-1), Vector2i(0,0), Vector2i(1,0), Vector2i(2,0)],
	t_shape =  [Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(0,-1)],
	diagonal =  [Vector2i(-2,-2), Vector2i(-1,-1), Vector2i(0,0), Vector2i(1,1), Vector2i(2,2)]
}


enum ColorChoice {GREEN, BLUE, RED, BROWN, YELLOW} # Maybe for later, probably gonna remove it
var colors = [
	Color(0.753, 0.898, 0.227, 1.0),
	Color(0.366, 0.41, 0.863, 1.0),
	Color(0.678, 0.157, 0.149, 1.0),
	Color(0.249, 0.102, 0.062, 1.0),
	Color(0.839, 0.851, 0.145, 1.0)
]

enum CellType { EMPTY, SAND, TETRIS, WATER, WALL, BARRIER}

class Cell:
	var type: int = CellType.EMPTY
	var extra: int = 0 # Not needed except for water later (moving left or right)
	var vel: Vector2 = Vector2.ZERO
	var color: Color = Color(0.0, 0.0, 0.0)
	
	func _init(_type: int = 0, _extra: int = 0) -> void:
		type = _type
		extra = _extra


#func _ready() -> void:
	#print("Hello")
	#grid.resize(width*height)
	#circle()
	##grid[2080].type = CellType.SAND
	#queue_redraw()

func setup():
	size = size/height
	@warning_ignore("integer_division")
	center = Vector2(width/2,height/2)
	min_cluster_size = height*2
	grid.resize(width*height)
	circle()

func _physics_process(delta: float) -> void:
	time_passed += delta
	circle_check_timer += delta
	if time_passed >= interval:
		update_sand()
		if piece_active:
			move_down()
		time_passed = 0.0
	if circle_check_timer >= circle_time:
		check_full_circle()
		circle_check_timer = 0.0
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
				CellType.SAND, CellType.TETRIS: # Only Sand for now, but still match, so I just have to add water, etc later
					@warning_ignore("integer_division")
					var gap_x = (1280-width*size)/2
					@warning_ignore("integer_division")
					var gap_y = (720-height*size)/2
					var rect = Rect2(gap_x+x*size, gap_y+y*size, size, size)
					draw_rect(rect, box.color)#Color(0.753, 0.898, 0.227, 1.0))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		var pos = event.position
		#print(pos)
		var grid_pos = Vector2i((pos.x-(1280-width*size)/2)/size, pos.y/size)
		#print(grid_pos)
		
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				for y in [-1, 0, 1]:
					for x in [-1, 0, 1]:
						var idx = (grid_pos.y+y) * width + (grid_pos.x+x)
						if idx < width*height:
							#print(cell_angle(grid_pos))
							if grid[idx].type == CellType.EMPTY:
								grid[idx].type = CellType.SAND
								grid[idx].color = Color(0.753, 0.898, 0.227, 1.0)#Color(randf(), randf(), randf())
								sand_cells.append(idx)
								sand_map[idx] = sand_cells.size()-1
			MOUSE_BUTTON_RIGHT:
				for y in [-1, 0, 1]:
					for x in [-1, 0, 1]:
						var idx = (grid_pos.y+y) * width + (grid_pos.x+x)
						if idx < width*height:
							#print(cell_angle(grid_pos))
							if grid[idx].type == CellType.EMPTY:
								grid[idx].type = CellType.SAND
								grid[idx].color = Color(0.366, 0.41, 0.863, 1.0)
								sand_cells.append(idx)
								sand_map[idx] = sand_cells.size()-1
	if event.is_action_released("ui_accept"):
		#spawn_sand()
		spawn_tetris()
	
	if piece_active:
		if event.is_action_pressed("clockwise"):
			move_tetris(PI/height)
		elif event.is_action_pressed("counter_clockwise"):
			move_tetris(-PI/height)

func spawn_sand(): #Spawns a single sand-block in the center
	var color = colors.pick_random()
	for y in [-1, 0, 1]:
		for x in [-1, 0, 1]:
			var idx = (center.y+y) as int * width + (center.x+x) as int
			if grid[idx].type == CellType.EMPTY:
				var angle = randf_range(0.0, TAU)
				var dir = Vector2(cos(angle), sin(angle))
				grid[idx].type = CellType.SAND
				grid[idx].vel = dir
				grid[idx].color = color#Color(randf(), randf(), randf())
				sand_cells.append(idx)
				sand_map[idx] = sand_cells.size()-1


func update_sand():
	@warning_ignore("integer_division")
	var max_radius = width/2
	var buckets = []
	for i in max_radius+1:
		buckets.append([])
	
	for y in height:
		for x in width:
			var idx = y * width + x
			var cell = grid[idx]
			if cell.type != CellType.SAND:
				continue
			var pos = Vector2(x, y)
			var d = int((pos - center).length())
			buckets[d].append(pos)
	for d in range(max_radius, -1, -1):
		for pos in buckets[d]:
			var x = int(pos.x)
			var y = int(pos.y)
			var idx = y*width+x
		
			var dir = (pos - center).normalized()
			if pos == center:
				var angle = randf_range(0, TAU)
				dir = Vector2(cos(angle), sin(angle))
		
			var primary = dir.round()
			var perpendicular = Vector2(-dir.y, dir.x)
			var side1 = (dir + perpendicular).round()
			var side2 = (dir - perpendicular).round()
		
			var positions = []
			for offset in [primary, side1, side2]:
				if offset == Vector2.ZERO || offset.dot(dir) <= 0:
					continue
				if not (offset in positions):
					positions.append(offset)
		
			for offset in positions:
				var tx = x + int(offset.x)
				var ty = y + int(offset.y)
				var tidx = ty * width + tx
				if grid[tidx].type == CellType.EMPTY:
					grid[tidx].type = CellType.SAND
					grid[tidx].color = grid[idx].color
					grid[idx].type = CellType.EMPTY
					
					var arr_pos = sand_map[idx]
					sand_cells[arr_pos] = tidx
					sand_map.erase(idx)
					sand_map[tidx] = arr_pos
					break

func angle_of(pos: Vector2) -> float:
	var a = atan2(pos.y - center.y, pos.x - center.x)
	return fmod(a + TAU, TAU)

func check_full_circle():
	var seen = {}
	const NUM_BINS = 512

	for idx in sand_cells:
		if seen.has(idx):
			continue
		var x = idx % width
		var y = int(idx / width)
		var cell = grid[idx]
		
		var color = cell.color
		var queue = [Vector2i(x, y)]
		var cluster = []
		var sum_radius = 0.0
		var count = 0
		
		while queue.size() > 0:
			var p = queue.pop_back()
			var pidx = p.y * width + p.x
			if seen.has(pidx):
				continue
			seen[pidx] = true

			var c = grid[pidx]
			if c.color != color:
				continue
			
			cluster.append(p)
			var r = (Vector2(p.x, p.y) - center).length()
			sum_radius += r
			count += 1
			
			for oy in [-1, 0, 1]:
				for ox in [-1, 0, 1]:
					if ox == 0 and oy == 0:
						continue
					var nx = p.x + ox
					var ny = p.y + oy
					var nidx = ny * width + nx
					if seen.has(nidx):
						continue
					var nc = grid[nidx]
					if nc.type == CellType.SAND and nc.color == color:
						queue.append(Vector2i(nx, ny))
		
		if count < min_cluster_size:#== 0:
			continue
		
		var avg_radius = sum_radius / max(1, count)
		
		if avg_radius < 2.5:
			continue
		
		var bins = PackedInt32Array()
		bins.resize(NUM_BINS)
		for pos in cluster:
			var dx = pos.x - center.x
			var dy = pos.y - center.y
			var angle = atan2(dy, dx)
			var bin_idx = int((angle + TAU) / TAU * NUM_BINS) % NUM_BINS
			bins[bin_idx] = 1
		
		var largest_gap = 0.0
		var current_gap = 0
		for i in NUM_BINS*2:
			if bins[i % NUM_BINS] == 0:
				current_gap += 1
				if current_gap > largest_gap:
					largest_gap = current_gap
			else:
				current_gap = 0

		var allowed_gap = int(NUM_BINS / (TAU * avg_radius) * 1.5)
		
		if largest_gap <= allowed_gap:
			if is_ring_connected(color):
				for pos in cluster:
					var clear_idx = pos.y * width + pos.x
					grid[clear_idx].type = CellType.EMPTY
					#sand_cells.erase(clear_idx) # Deleting while iterating over it, but works for now
					#sand_map.erase(clear_idx)
					remove_sand(clear_idx)

func is_ring_connected(color: Color) -> bool:
	var seen = {}
	var queue = [Vector2i(center.x, center.y)]
	
	while queue.size() > 0:
		var pos = queue.pop_back()
		for oy in [-1, 0, 1]:
			for ox in [-1, 0, 1]:
				if ox and oy == 0:
					continue
				var nx = pos.x + ox
				var ny = pos.y + oy
				var nidx = ny * width + nx
				if seen.has(nidx):
					continue
				var nc = grid[nidx]
				if nc.type == CellType.BARRIER:
					return false
				if nc.color != color:#nc.type == CellType.EMPTY:
					seen[nidx] = true
					queue.append(Vector2i(nx, ny))
	return true

func remove_sand(idx: int):
	var arr_pos = sand_map[idx]
	var last_idx = sand_cells[sand_cells.size() - 1]

	sand_cells[arr_pos] = last_idx
	sand_map[last_idx] = arr_pos

	sand_cells.pop_back()
	sand_map.erase(idx)



func spawn_tetris():
	if piece_active:
		return
	tetris_pieces.clear()
	
	var shapes = TETRIS_SHAPES.values()
	var random_shape = shapes[randi()%shapes.size()]
	tetris_pieces = random_shape.duplicate()
	
	anchor = center
	tetris_color = colors.pick_random()
	
	for i in range(tetris_pieces.size()):
		tetris_pieces[i] += anchor
		var idx = tetris_pieces[i].y * width + tetris_pieces[i].x
		grid[idx].type = CellType.TETRIS
		grid[idx].color = tetris_color
	piece_active = true


func move_tetris(angle: float):
	pass

func move_down():
	var dir = (Vector2(anchor) - center).normalized()
	if anchor == Vector2i(center):
		var angle = randf_range(0, TAU)
		dir = Vector2(cos(angle), sin(angle))
	var offset = Vector2i(dir.round())
	var new_positions = []
	for pos in tetris_pieces:
		var new_pos = pos+offset
		var idx = new_pos.y * width + new_pos.x
		if grid[idx].type != CellType.EMPTY and grid[idx].type != CellType.TETRIS:
			to_sand()
			return
		new_positions.append(new_pos)
		grid[pos.y * width + pos.x].type = CellType.EMPTY
	tetris_pieces = new_positions
	for pos in tetris_pieces:
		var idx = pos.y * width + pos.x
		grid[idx].type = CellType.TETRIS
		grid[idx].color = tetris_color
	anchor += offset


func to_sand():
	for pos in tetris_pieces:
		var idx = pos.y * width + pos.x
		grid[idx].type = CellType.SAND
		sand_cells.append(idx)
		sand_map[idx] = sand_cells.size()-1
	tetris_pieces.clear()
	piece_active = false

var test = {one = 0, hello = 23}
