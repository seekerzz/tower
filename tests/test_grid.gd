extends Node

func _ready():
	print("Starting Test...")

	# Create GridManager
	var grid_scene = load("res://src/systems/GridManager.tscn")
	var grid = grid_scene.instantiate()
	add_child(grid)

	# Test Tile Creation
	print("Grid Data size: ", grid.grid_data.size())
	if grid.grid_data.size() > 0:
		print("Grid initialized correctly.")
	else:
		print("Grid init failed.")
		get_tree().quit(1)

	# Test Unit Placement
	var unit_scene = load("res://src/entities/Unit.tscn")
	var success = grid.try_place_unit(unit_scene, Vector2i(1, 0))
	if success:
		print("Unit placed successfully at (1,0).")
	else:
		print("Unit placement failed.")
		get_tree().quit(1)

	var fail_success = grid.try_place_unit(unit_scene, Vector2i(0, 0)) # Center (Core) should fail
	if not fail_success:
		print("Unit placement correctly blocked at (0,0).")
	else:
		print("Unit placement incorrectly allowed at (0,0).")
		get_tree().quit(1)

	print("Grid tests passed.")
	get_tree().quit()
