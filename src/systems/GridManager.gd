extends Node2D

const TILE_SIZE = 60

# Grid dict: "x,y" -> Unit Node
var grid: Dictionary = {}

func _ready():
	# Create Core
	var core_scene = load("res://src/scenes/Unit.tscn").instantiate()
	# Hack: Unit scene is generally for units, but Core is special.
	# We might want a dedicated Core scene, but for now reuse Unit visually?
	# Or just represent it as a tile.
	# Let's use a "Core" visual tile in the Main scene.
	pass

func get_tile_key(x, y):
	return "%d,%d" % [x, y]

func world_to_grid(pos: Vector2) -> Vector2i:
	return Vector2i(round(pos.x / TILE_SIZE), round(pos.y / TILE_SIZE))

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * TILE_SIZE, grid_pos.y * TILE_SIZE)

func try_place_unit(unit_key: String, grid_pos: Vector2i) -> bool:
	var unit_data = GameData.UNIT_TYPES[unit_key]

	# Check for merge first
	var tile_key = get_tile_key(grid_pos.x, grid_pos.y)
	if grid.has(tile_key):
		var existing_unit = grid[tile_key]
		# Ensure it's the main tile of the unit (simple check for 1x1 or correct origin)
		if existing_unit.type_key == unit_key and existing_unit.tile_pos == grid_pos:
			# Merge!
			upgrade_unit(existing_unit)
			return true

	if not can_place(grid_pos, unit_data.size):
		return false

	var unit_scene = load("res://src/scenes/Unit.tscn")
	var unit = unit_scene.instantiate()
	add_child(unit)
	unit.position = grid_to_world(grid_pos)
	unit.setup(unit_key, grid_pos)

	register_unit(unit, grid_pos, unit_data.size)
	SignalBus.unit_placed.emit(unit, grid_pos)
	return true

func upgrade_unit(unit):
	unit.level += 1
	unit.damage_mod += 0.5
	# Visual update could happen here
	print("Unit Upgraded to Level ", unit.level)

func can_place(start_pos: Vector2i, size: Vector2i) -> bool:
	for x in range(size.x):
		for y in range(size.y):
			var pos = start_pos + Vector2i(x, y)
			if pos == Vector2i(0, 0): # Core
				return false
			if grid.has(get_tile_key(pos.x, pos.y)):
				return false
	return true

func register_unit(unit, start_pos: Vector2i, size: Vector2i):
	for x in range(size.x):
		for y in range(size.y):
			var pos = start_pos + Vector2i(x, y)
			grid[get_tile_key(pos.x, pos.y)] = unit

func remove_unit(unit):
	# TODO: Implement removal (selling)
	pass
