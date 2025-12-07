extends Node2D

func _ready():
	print("Starting Shop Integration Test")

	# Instantiate GameUI
	# Note: GameUI relies on SignalBus and GameManager which are Autoloads.
	# In this test environment (running this script with -s), we might need to be careful if Autoloads are not automatically loaded.
	# But if we use TestRunner.tscn or similar approach it might be better.
	# For now, let's assume this script is attached to a scene run with `godot --headless tests/TestShopIntegration.tscn` or similar.

	# However, since I am creating a standalone script to be run with `godot --headless -s`, I need to simulate Autoloads if they are missing
	# Or I can manually load them if they are not present.
	# But 'SignalBus' and 'GameManager' are needed.

	# Let's check if SignalBus exists in the tree (it won't if run as -s script)
	# The memory says "Tests requiring Autoloads must be executed via a scene... rather than running the script directly."
	# So I should create a scene for this test.

	var game_ui = load("res://src/ui/GameUI.tscn").instantiate()
	add_child(game_ui)

	# Wait for ready
	await get_tree().process_frame

	# Verify ShopManager loaded units
	var shop_manager = game_ui.shop_manager
	if not shop_manager:
		print("FAIL: ShopManager not initialized")
		get_tree().quit(1)
		return

	if shop_manager.available_units.size() == 0:
		print("FAIL: No units loaded in ShopManager")
		get_tree().quit(1)
		return

	print("PASS: ShopManager loaded ", shop_manager.available_units.size(), " units.")

	# Verify Shop Cards generated
	var shop_container = game_ui.shop_container
	if shop_container.get_child_count() == 0:
		print("FAIL: Shop container is empty")
		get_tree().quit(1)
		return

	print("PASS: Shop container has ", shop_container.get_child_count(), " cards.")

	# Simulate Click
	var card = shop_container.get_child(0)
	var unit_name = card.unit_data.unit_name

	# Connect to signal to verify
	SignalBus.unit_purchased.connect(func(unit_data):
		if unit_data.unit_name == unit_name:
			print("PASS: SignalBus.unit_purchased received for ", unit_name)
			get_tree().quit(0)
		else:
			print("FAIL: SignalBus received wrong unit data")
			get_tree().quit(1)
	)

	# Trigger click
	print("Simulating click on ", unit_name)
	card.card_clicked.emit(card.unit_data)

	# Timeout fallback
	await get_tree().create_timer(1.0).timeout
	print("FAIL: Timeout waiting for signal")
	get_tree().quit(1)
