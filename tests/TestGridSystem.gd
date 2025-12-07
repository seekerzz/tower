extends Node2D

@onready var grid_manager: GridManager = $GridManager
@onready var interaction_controller: InteractionController = $InteractionController
@onready var unit_scene = load("res://src/entities/Unit.tscn")

func _ready() -> void:
	# Initial gold setup for testing
	GameManager.gold = 100
	print("Initial Gold: ", GameManager.gold)

	# Setup interaction controller for manual verification if needed
	interaction_controller.test_unit_scene = unit_scene

	# Simulate pressing 'B' to enter placement mode
	interaction_controller.placement_mode = true
	print("Placement mode enabled via script")

	# Test 1: Place a unit at (0,0)
	print("--- Test 1: Place unit at (0,0) ---")
	var success = grid_manager.try_place_unit(unit_scene, Vector2i(0,0))
	if success:
		print("SUCCESS: Unit placed at (0,0)")
	else:
		print("FAILURE: Could not place unit at (0,0)")

	# Test 2: Try to place again at (0,0) (Should fail)
	print("--- Test 2: Place duplicate at (0,0) ---")
	success = grid_manager.try_place_unit(unit_scene, Vector2i(0,0))
	if not success:
		print("SUCCESS: Prevented duplicate placement")
	else:
		print("FAILURE: Allowed duplicate placement")

	# Test 3: Place at (1,1)
	print("--- Test 3: Place unit at (1,1) ---")
	success = grid_manager.try_place_unit(unit_scene, Vector2i(1,1))
	if success:
		print("SUCCESS: Unit placed at (1,1)")
	else:
		print("FAILURE: Could not place unit at (1,1)")

	# Test 4: Check gold deduction (Assuming cost is 10 or similar)
	print("--- Test 4: Check Gold ---")
	# Initial 100. Two successful placements.
	print("Final Gold: ", GameManager.gold)
	if GameManager.gold < 100:
		print("SUCCESS: Gold deducted")
	else:
		print("FAILURE: Gold not deducted")

	# Test 5: Out of bounds
	print("--- Test 5: Out of bounds (3,3) ---")
	success = grid_manager.try_place_unit(unit_scene, Vector2i(3,3))
	if not success:
		print("SUCCESS: Prevented out of bounds placement")
	else:
		print("FAILURE: Allowed out of bounds placement")

	# Check if running in headless mode for CI/Verification
	if DisplayServer.get_name() == "headless":
		print("Running in headless mode, quitting...")
		get_tree().quit()
	else:
		print("Interactive mode: Press 'B' to toggle placement mode and click to place units.")
