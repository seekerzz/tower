extends Node2D

const TILE_SIZE = 60
const GRID_RADIUS = 2 # 5x5 grid means radius 2 from center? No, 5x5 is -2 to 2.

var grid_data = {} # Key: Vector2i, Value: Unit Node or Data

func _ready():
	# Initialize grid tiles
	for x in range(-GRID_RADIUS, GRID_RADIUS + 1):
		for y in range(-GRID_RADIUS, GRID_RADIUS + 1):
			create_tile(Vector2i(x, y))

func create_tile(coord: Vector2i):
	var tile = ColorRect.new()
	tile.size = Vector2(TILE_SIZE, TILE_SIZE)
	tile.color = Color(0.2, 0.2, 0.3)
	tile.position = Vector2(coord * TILE_SIZE) - Vector2(TILE_SIZE/2.0, TILE_SIZE/2.0)

	# Add border (visual only)
	var border = Line2D.new()
	border.points = [Vector2(0,0), Vector2(TILE_SIZE, 0), Vector2(TILE_SIZE, TILE_SIZE), Vector2(0, TILE_SIZE), Vector2(0,0)]
	border.width = 2
	border.default_color = Color(0.3, 0.3, 0.4)
	tile.add_child(border)

	# Core tile visual
	if coord == Vector2i(0, 0):
		tile.color = Color(0.3, 0.2, 0.3)

	add_child(tile)
	grid_data[coord] = {
		"node": tile,
		"unit": null
	}

func world_to_grid(pos: Vector2) -> Vector2i:
	return Vector2i(round(pos.x / TILE_SIZE), round(pos.y / TILE_SIZE))

func try_place_unit(unit_scene: PackedScene, coord: Vector2i) -> bool:
	if not grid_data.has(coord):
		return false
	if grid_data[coord]["unit"] != null:
		return false # Occupied
	if coord == Vector2i(0,0):
		return false # Core pos

	var unit_instance = unit_scene.instantiate()
	grid_data[coord]["unit"] = unit_instance
	unit_instance.position = coord * TILE_SIZE
	add_child(unit_instance)
	return true
