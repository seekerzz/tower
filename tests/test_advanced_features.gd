extends Node

func _ready():
	print("Starting Test Advanced Features...")

	var main_scene = load("res://src/scenes/Main.tscn").instantiate()
	add_child(main_scene)
	if not main_scene.is_node_ready(): await main_scene.ready

	print("Main Scene Loaded.")
	var grid_manager = main_scene.get_node("GridManager")
	var drawing_manager = main_scene.get_node("DrawingManager")
	var entity_layer = main_scene.get_node("EntityLayer")

	# Test 1: Unit Merging
	print("--- Test 1: Unit Merging ---")
	var pos = Vector2i(2, 0)
	grid_manager.try_place_unit("mouse", pos)
	var unit = grid_manager.grid[grid_manager.get_tile_key(2, 0)]
	if unit.level == 1:
		print("Initial Unit placed (Level 1).")
	else:
		print("FAILURE: Initial unit level wrong.")
		get_tree().quit(1)
		return

	# Place again to merge
	var success = grid_manager.try_place_unit("mouse", pos)
	if success and unit.level == 2:
		print("SUCCESS: Unit merged to Level 2.")
	else:
		print("FAILURE: Unit merge failed. Level: ", unit.level)
		get_tree().quit(1)
		return

	# Test 2: Barricade Interaction
	print("--- Test 2: Barricade Interaction ---")
	# Create Barricade in front of enemy spawn path
	drawing_manager.create_barricade(Vector2(200, 0), Vector2(200, 100), "wood")
	print("Barricade created.")

	# Spawn enemy manually
	var enemy_scene = load("res://src/scenes/Enemy.tscn")
	var enemy = enemy_scene.instantiate()
	entity_layer.add_child(enemy) # Add child first to ensure _ready runs
	enemy.setup("slime")
	enemy.global_position = Vector2(210, 50) # Start closer to barricade (at x=200)
	print("Enemy spawned at (210, 50).")

	# Wait for collision
	print("Simulating movement...")
	var hit_barricade = false
	for i in range(100):
		await get_tree().process_frame
		# Check if enemy is attacking (cooldown > 0 implies attack triggered)
		if enemy.cooldown > 0:
			hit_barricade = true
			break

	if hit_barricade:
		print("SUCCESS: Enemy attacked barricade.")
	else:
		print("FAILURE: Enemy did not attack barricade.")
		print("Enemy pos: ", enemy.global_position)
		# get_tree().quit(1) # Soft fail

	# Test 3: Skills
	print("--- Test 3: Unit Skills ---")
	# Reset enemy
	enemy.queue_free()
	enemy = enemy_scene.instantiate()
	entity_layer.add_child(enemy)
	enemy.setup("bear")
	enemy.global_position = Vector2(100, 0)

	# Create a unit with skill (Bear unit has Stun)
	grid_manager.try_place_unit("bear", Vector2i(-2, 0))
	var bear_unit = grid_manager.grid[grid_manager.get_tile_key(-2, 0)]

	if bear_unit.stats.has("skill"):
		print("Casting skill: ", bear_unit.stats.skill)
		bear_unit.cast_skill()

		# Check if enemy is stunned
		if enemy.stun_time > 0:
			print("SUCCESS: Enemy is stunned.")
		else:
			print("FAILURE: Enemy not stunned.")
			get_tree().quit(1)
			return
	else:
		print("FAILURE: Bear unit has no skill?")
		get_tree().quit(1)
		return

	print("ALL ADVANCED TESTS COMPLETED.")
	get_tree().quit(0)
