extends Node2D

class_name GridManager

signal unit_placed(unit, grid_pos)

@export var tile_size: int = 60
@export var grid_radius: int = 2 # 5x5 grid means radius 2 (-2 to +2)

var grid_units: Dictionary = {} # Vector2i -> Node2D

func _ready() -> void:
	queue_redraw()

func recalculate_synergies() -> void:
	# 1. Reset all buffs
	for unit in grid_units.values():
		if unit.get("applied_buffs") != null:
			unit.applied_buffs.clear()

	# 2. Apply buffs from providers
	var neighbors_offsets = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

	for pos in grid_units.keys():
		var unit = grid_units[pos]
		if not unit.get("stats") or unit.stats.get("buff_provider_type") == null or unit.stats.buff_provider_type == "none":
			continue

		var buff_type = unit.stats.buff_provider_type

		for offset in neighbors_offsets:
			var neighbor_pos = pos + offset
			if grid_units.has(neighbor_pos):
				var neighbor = grid_units[neighbor_pos]
				if neighbor.get("applied_buffs") != null:
					neighbor.applied_buffs.append(buff_type)

	# 3. Update stats for all units
	for unit in grid_units.values():
		if unit.has_method("update_stats"):
			unit.update_stats()

func _draw() -> void:
	var color = Color(1, 1, 1, 0.2)

	# Calculate top-left corner in local coordinates
	# Center of tile (0,0) is at local (0,0)
	# Center of tile (-grid_radius, -grid_radius) is at (-grid_radius * tile_size, -grid_radius * tile_size)
	# Top-left of the entire grid area is offset by half tile size from the center of the top-left tile

	var top_left_x = (-grid_radius * tile_size) - (tile_size / 2.0)
	var top_left_y = (-grid_radius * tile_size) - (tile_size / 2.0)
	var top_left = Vector2(top_left_x, top_left_y)

	var total_tiles = grid_radius * 2 + 1
	var total_size = total_tiles * tile_size

	# Vertical lines
	for i in range(total_tiles + 1):
		var x = top_left.x + i * tile_size
		draw_line(Vector2(x, top_left.y), Vector2(x, top_left.y + total_size), color)

	# Horizontal lines
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

func try_place_unit(unit_scene: PackedScene, grid_coord: Vector2i) -> bool:
	if not is_valid_grid_pos(grid_coord):
		print("Invalid grid position: ", grid_coord)
		return false

	if grid_units.has(grid_coord):
		print("Grid position occupied: ", grid_coord)
		return false

	var unit_instance = unit_scene.instantiate()

	# Determine cost
	var cost = 0
	if "stats" in unit_instance and unit_instance.stats:
		cost = unit_instance.stats.cost
	else:
		# Fallback or check if we should look elsewhere
		cost = 10 # Default for testing if no stats

	if GameManager.gold < cost:
		print("Not enough gold. Cost: ", cost, ", Current: ", GameManager.gold)
		unit_instance.queue_free()
		return false

	# Deduct gold
	GameManager.spend_gold(cost)

	# Place unit
	add_child(unit_instance)
	unit_instance.global_position = grid_to_world(grid_coord)
	grid_units[grid_coord] = unit_instance

	print("Unit placed at ", grid_coord, ", Gold remaining: ", GameManager.gold)
	unit_placed.emit(unit_instance, grid_coord)

	recalculate_synergies()

	return true
