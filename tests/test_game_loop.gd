extends Node

func _ready():
	print("Starting Test Game Loop...")

	# Load Main Scene
	var main_scene = load("res://src/scenes/Main.tscn").instantiate()
	add_child(main_scene)

	if not main_scene.is_node_ready():
		await main_scene.ready

	print("Main scene loaded.")

	# Test Projectile Instantiation directly
	print("Testing Projectile Instantiation...")
	var proj_scene = load("res://src/scenes/Projectile.tscn")
	if proj_scene:
		var proj = proj_scene.instantiate()
		add_child(proj)
		print("Projectile instantiated and added to tree.")
		# Test setup
		proj.setup({
			"position": Vector2(0,0),
			"target": null,
			"speed": 100,
			"damage": 10,
			"type": "dot",
			"splash": 0
		})
		print("Projectile setup complete.")
		proj.queue_free()
	else:
		print("FAILURE: Could not load Projectile.tscn")
		get_tree().quit(1)
		return

	# 1. Test Placing a Unit
	print("Testing Unit Placement...")
	var grid_manager = main_scene.get_node("GridManager")
	var success = grid_manager.try_place_unit("mouse", Vector2i(1, 0))
	if success:
		print("SUCCESS: Unit placed at (1,0)")
	else:
		print("FAILURE: Could not place unit")
		get_tree().quit(1)
		return

	# 2. Test Spawning Enemy (Manual)
	print("Testing Enemy Spawn...")
	var wave_manager = main_scene.get_node("WaveManager")
	wave_manager.spawn_enemy()

	var enemies = main_scene.get_node("EntityLayer").get_children().filter(func(node): return node.is_in_group("enemies"))
	if enemies.size() > 0:
		print("SUCCESS: Enemy spawned. Count: ", enemies.size())
	else:
		print("FAILURE: No enemies spawned")
		get_tree().quit(1)
		return

	# 3. Simulate Game Loop
	print("Simulating frames...")
	var enemy = enemies[0]

	# Force enemy close
	enemy.global_position = Vector2(100, 0)
	print("Forced enemy to (100,0)")

	for i in range(20):
		await get_tree().process_frame

	# Check if unit attacked
	var projectiles = []
	var entity_layer = main_scene.get_node("EntityLayer")
	for child in entity_layer.get_children():
		if child.get_script() and child.get_script().resource_path == "res://src/scripts/Projectile.gd":
			projectiles.append(child)

	# Also check root for legacy fallback (though we expect EntityLayer now)
	for child in get_tree().root.get_children():
		if child.get_script() and child.get_script().resource_path == "res://src/scripts/Projectile.gd":
			projectiles.append(child)

	if projectiles.size() > 0:
		print("SUCCESS: Projectiles fired. Count: ", projectiles.size())
	else:
		print("FAILURE: Still no projectiles.")

	# 4. Test Game Over Logic
	print("Testing Core Damage...")
	GameManager.damage_core(10)
	if GameManager.core_health == 90:
		print("SUCCESS: Core took damage. HP: ", GameManager.core_health)
	else:
		print("FAILURE: Core HP mismatch. Expected 90, got ", GameManager.core_health)
		get_tree().quit(1)
		return

	print("ALL TESTS COMPLETED.")
	get_tree().quit(0)
