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
var circle_check_timer: float = 0.0
var interval: float = 0.05
var circle_time: float = 1.0

enum CellType { EMPTY, SAND, WATER, WALL, BARRIER}

class Cell:
	var type: int = CellType.EMPTY
	var extra: int = 0 # Not needed except for water later (moving left or right)
	var vel: Vector2 = Vector2.ZERO
	var color: Color = Color(0.0, 0.0, 0.0)
	
	func _init(_type: int = 0, _extra: int = 0) -> void:
		type = _type
		extra = _extra


func _ready() -> void:
	grid.resize(width*height)
	circle()
	#grid[2080].type = CellType.SAND
	queue_redraw()

func _physics_process(delta: float) -> void:
	time_passed += delta
	circle_check_timer += delta
	if time_passed >= interval:
		update_sand()
		time_passed = 0.0
	if circle_check_timer >= circle_time:
		check_full_circle()
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
						if idx < 64*64:
							#print(cell_angle(grid_pos))
							if grid[idx].type == CellType.EMPTY:
								grid[idx].type = CellType.SAND
								grid[idx].color = Color(0.753, 0.898, 0.227, 1.0)#Color(randf(), randf(), randf())
			MOUSE_BUTTON_RIGHT:
				for y in [-1, 0, 1]:
					for x in [-1, 0, 1]:
						var idx = (grid_pos.y+y) * width + (grid_pos.x+x)
						if idx < 64*64:
							#print(cell_angle(grid_pos))
							if grid[idx].type == CellType.EMPTY:
								grid[idx].type = CellType.SAND
								grid[idx].color = Color(0.366, 0.41, 0.863, 1.0)
	if event.is_action_released("ui_accept"):
		spawn_sand()

func spawn_sand(): #Spawns a single sand-block in the center
	var idx = center.y * width + center.x
	
	#print(idx)
	if grid[idx].type == CellType.EMPTY:
		var angle = randf_range(0.0, TAU)
		var dir = Vector2(cos(angle), sin(angle))
		grid[idx].type = CellType.SAND
		grid[idx].vel = dir
		grid[idx].color = Color(randf(), randf(), randf())


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
			var cell = grid[idx]
			if cell.type != CellType.SAND:
				continue
		
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
					break

func angle_of(pos: Vector2) -> float:
	# pos are integer cell coordinates
	var a = atan2(pos.y - center.y, pos.x - center.x)
	return fmod(a + TAU, TAU)

func check_full_circle():
	var seen = {}

	for y in height:
		for x in width:
			var idx = y * width + x
			if seen.has(idx):
				continue
			var cell = grid[idx]
			if cell.type != CellType.SAND:
				continue
			
			var color = cell.color
			var queue = [Vector2i(x, y)]
			var cluster = []
			var angles = []
			var sum_radius = 0.0
			var count = 0
			
			while queue.size() > 0:
				var p = queue.pop_back()
				var pidx = p.y * width + p.x
				if seen.has(pidx):
					continue
				seen[pidx] = true

				var c = grid[pidx]
				if c.type != CellType.SAND or c.color != color:
					continue
				
				cluster.append(p)
				angles.append(angle_of(p))
				
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
			
			if count == 0:
				continue
			
			var avg_radius = sum_radius / max(1, count)
			
			if avg_radius < 2.5:
				continue
				
			angles.sort()
			
			var largest_gap = 0.0
			for i in angles.size()-1:
				var gap = angles[i+1] - angles[i]
				if gap > largest_gap:
					largest_gap = gap
			
			var wrap_gap = angles[0] + TAU - angles[angles.size() - 1]
			if wrap_gap > largest_gap:
				largest_gap = wrap_gap
			
			var circumference_cells = max(8, int(round(TAU * avg_radius)))
			var angle_per_cell = TAU / float(circumference_cells)
			
			var gap_factor = 1.5
			var allowed_gap = angle_per_cell * gap_factor
			
			if largest_gap <= allowed_gap:
				for pos in cluster:
					var clear_idx = pos.y * width + pos.x
					grid[clear_idx].type = CellType.EMPTY
