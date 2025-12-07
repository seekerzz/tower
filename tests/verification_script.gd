extends SceneTree

func _init():
	print("Starting verification...")

	# Load the Enemy scene
	var enemy_scene = load("res://src/entities/Enemy.tscn")
	if enemy_scene == null:
		print("Error: Could not load Enemy.tscn")
		quit(1)
		return

	# Instantiate the enemy
	var enemy = enemy_scene.instantiate()
	# We manually call _ready to ensure initialization for this unit test
	# because add_child behavior in _init script might be deferred.
	enemy._ready()

	# Check basic properties
	if enemy.max_hp != 100.0:
		print("Error: max_hp is not 100.0")
		quit(1)
		return
	if enemy.speed != 100.0:
		print("Error: speed is not 100.0")
		quit(1)
		return

	# Check if ready was called and hp initialized
	if enemy.current_hp != 100.0:
		print("Error: current_hp is not 100.0 after _ready. It is: ", enemy.current_hp)
		quit(1)
		return

	print("Properties verification passed.")

	# Test take_damage
	enemy.take_damage(50)
	if enemy.current_hp != 50.0:
		print("Error: current_hp is not 50.0 after taking 50 damage. It is: ", enemy.current_hp)
		quit(1)
		return

	enemy.take_damage(50)
	if enemy.current_hp != 0.0:
		print("Error: current_hp is not 0.0 after taking another 50 damage. It is: ", enemy.current_hp)
		quit(1)
		return

	if not enemy.is_queued_for_deletion():
		print("Error: Enemy should be queued for deletion after death")
		quit(1)
		return

	print("Damage verification passed.")

	enemy.free() # Clean up manually since queue_free is deferred and we are not running a loop

	# Test movement logic roughly
	var enemy_move = enemy_scene.instantiate()
	# No need to add to tree for this physics calculation check
	enemy_move._ready()
	enemy_move.global_position = Vector2(100, 0)

	# Manually call _physics_process
	enemy_move._physics_process(0.16)

	# Target is (0,0), so velocity should be pointing left (-1, 0) * speed
	var expected_velocity = Vector2(-1, 0) * enemy_move.speed
	if not enemy_move.velocity.is_equal_approx(expected_velocity):
		print("Error: Velocity is incorrect. Expected: ", expected_velocity, " Got: ", enemy_move.velocity)
		quit(1)
		return

	print("Movement logic verification passed.")

	print("All verifications passed!")
	quit(0)
