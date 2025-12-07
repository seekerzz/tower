extends Node2D

class_name GridManager

signal unit_placed(unit, grid_pos)

@export var tile_size: int = 60
@export var grid_radius: int = 2 # 5x5 grid means radius 2 (-2 to +2)

var grid_units: Dictionary = {} # Vector2i -> Node2D

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var color = Color(1, 1, 1, 0.2)
	var top_left_x = (-grid_radius * tile_size) - (tile_size / 2.0)
	var top_left_y = (-grid_radius * tile_size) - (tile_size / 2.0)
	var top_left = Vector2(top_left_x, top_left_y)

	var total_tiles = grid_radius * 2 + 1
	var total_size = total_tiles * tile_size

	for i in range(total_tiles + 1):
		var x = top_left.x + i * tile_size
		draw_line(Vector2(x, top_left.y), Vector2(x, top_left.y + total_size), color)

	for i in range(total_tiles + 1):
		var y = top_left.y + i * tile_size
		draw_line(Vector2(top_left.x, y), Vector2(top_left.x + total_size, y), color)

func world_to_grid(pos: Vector2) -> Vector2i:
	var local_pos = to_local(pos)
	var x = floor((local_pos.x + tile_size / 2.0) / tile_size)
	var y = floor((local_pos.y + tile_size / 2.0) / tile_size)
	return Vector2i(int(x), int(y))

func grid_to_world(coord: Vector2i) -> Vector2:
	return to_global(Vector2(coord.x * tile_size, coord.y * tile_size))

func is_valid_grid_pos(coord: Vector2i) -> bool:
	return abs(coord.x) <= grid_radius and abs(coord.y) <= grid_radius

func get_unit_at(coord: Vector2i) -> Node2D:
	return grid_units.get(coord, null)

func remove_unit_at(coord: Vector2i) -> void:
	if grid_units.has(coord):
		grid_units.erase(coord)

func move_unit(from_coord: Vector2i, to_coord: Vector2i) -> bool:
	if not grid_units.has(from_coord):
		return false
	if not is_valid_grid_pos(to_coord):
		return false
	if grid_units.has(to_coord):
		return false # Target occupied

	var unit = grid_units[from_coord]
	grid_units.erase(from_coord)
	grid_units[to_coord] = unit
	unit.global_position = grid_to_world(to_coord)
	return true

func try_place_unit(grid_coord: Vector2i, unit_stats: UnitStats) -> bool:
	if not is_valid_grid_pos(grid_coord):
		print("Invalid grid position: ", grid_coord)
		return false

	if grid_units.has(grid_coord):
		print("Grid position occupied: ", grid_coord)
		return false

	var unit_scene = load("res://src/entities/Unit.tscn")
	var unit_instance = unit_scene.instantiate()

	unit_instance.stats = unit_stats

	add_child(unit_instance)
	unit_instance.global_position = grid_to_world(grid_coord)
	grid_units[grid_coord] = unit_instance

	print("Unit placed at ", grid_coord)
	unit_placed.emit(unit_instance, grid_coord)
	return true
