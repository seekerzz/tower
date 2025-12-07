extends Node

func _ready():
	print("Starting test...")

	# Create a temporary unit stats resource for Archer to ensure it's ranged
	var archer_stats = load("res://src/resources/units/Archer.tres")
	print("Archer type: ", archer_stats.attack_type)
	print("Archer proj: ", archer_stats.proj_type)

	# Create a GridManager scene manually or instantiate
	var grid_manager = load("res://src/systems/GridManager.tscn").instantiate()
	add_child(grid_manager)

	# Create a mock enemy
	var enemy = load("res://src/entities/Enemy.tscn").instantiate()
	enemy.position = Vector2(200, 0) # Within range (250)
	# We need to add enemy to the scene so it can be found by find_target
	# And add to group "enemy"
	enemy.add_to_group("enemy")
	add_child(enemy)

	# Create an Archer Unit
	var unit_scene = load("res://src/entities/Unit.tscn")
	var archer = unit_scene.instantiate()
	archer.stats = archer_stats

	# Place archer on grid via GridManager to ensure parentage is correct for ProjectileFactory
	# But ProjectileFactory uses get_parent(), so if we add archer to grid_manager, get_parent is grid_manager.
	grid_manager.add_child(archer)
	archer.global_position = Vector2(0, 0)

	# Wait for a frame to let things initialize
	await get_tree().process_frame

	# Force find_target and attack
	archer.find_target()
	print("Target found: ", archer.target)

	if archer.target == enemy:
		print("Target is correct.")
	else:
		print("Target is incorrect. Expected enemy.")

	# Force attack
	archer.attack()

	# Check if projectile spawned
	# Projectiles are added to archer's parent (grid_manager)
	await get_tree().create_timer(0.2).timeout

	var projectiles = []
	for child in grid_manager.get_children():
		# Check if it's a projectile (by script path or name)
		if child.get_script() and "Projectile" in child.get_script().resource_path:
			projectiles.append(child)

	print("Projectiles found: ", projectiles.size())
	if projectiles.size() > 0:
		print("Archer fired projectile successfully.")
	else:
		print("Archer failed to fire projectile.")

	# --- Test Buff System ---
	print("\nTesting Buff System...")

	# Create a Buff Provider (Wall with speed buff)
	# We need to modify Wall.tres or create a new one dynamically
	var wall_stats = load("res://src/resources/units/Wall.tres")
	wall_stats.buff_provider_type = "speed" # Temporarily modify for test

	# Place Wall at (0,1) - Neighbor to Archer at (0,0) (in grid coords)
	# Archer is at (0,0) world -> (0,0) grid
	# Wall at (0, 60) world -> (0,1) grid

	var wall = unit_scene.instantiate()
	wall.stats = wall_stats

	# We need to use GridManager's grid dictionary for recalculate_synergies to work
	# Reset grid
	grid_manager.grid_units.clear()

	# Add Archer to grid
	grid_manager.grid_units[Vector2i(0,0)] = archer
	archer.applied_buffs.clear()
	archer.update_stats()
	print("Archer base atk_speed: ", archer.base_stats.atk_speed)
	print("Archer current atk_speed (no buff): ", archer._current_atk_speed)

	# Add Wall to grid
	grid_manager.grid_units[Vector2i(0,1)] = wall
	grid_manager.add_child(wall)
	wall.global_position = grid_manager.grid_to_world(Vector2i(0,1))

	# Run recalculate_synergies
	grid_manager.recalculate_synergies()

	print("Archer applied buffs: ", archer.applied_buffs)
	print("Archer current atk_speed (with speed buff): ", archer._current_atk_speed)

	if "speed" in archer.applied_buffs:
		print("Buff applied to Archer.")
		if archer._current_atk_speed < archer.base_stats.atk_speed:
			print("Buff system working: Archer speed increased (cooldown decreased).")
		else:
			print("Buff system failed: Speed did not change.")
	else:
		print("Buff system failed: Buff not applied.")

	get_tree().quit()
