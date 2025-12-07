extends Node

func _ready():
	_test_data_binding()
	_test_shop_logic()
	_test_drawing_cost()
	get_tree().quit()

func _test_data_binding():
	print("--- Testing Data Binding ---")

	# Load GameUI
	var game_ui = load("res://src/ui/GameUI.tscn").instantiate()
	add_child(game_ui)

	# Wait a frame for _ready
	await get_tree().process_frame

	# Simulate Resource Change
	print("Adding 100 Gold...")
	GameManager.add_gold(100)

	var expected_gold_text = "💰 250" # 150 start + 100
	if expected_gold_text in game_ui.resource_label.text:
		print("SUCCESS: Gold updated in UI.")
	else:
		print("FAILURE: Gold text is '%s', expected to contain '%s'" % [game_ui.resource_label.text, expected_gold_text])

	game_ui.queue_free()

func _test_shop_logic():
	print("\n--- Testing Shop Logic ---")
	var game_ui = load("res://src/ui/GameUI.tscn").instantiate()
	add_child(game_ui)

	await get_tree().process_frame

	# Check if shop is populated
	var shop_cards = game_ui.shop_container.get_children()
	print("Shop cards count: ", shop_cards.size())
	if shop_cards.size() >= 4:
		print("SUCCESS: Shop populated.")
		# Simulate Click
		var card = shop_cards[0]
		print("Simulating click on card: ", card.name_label.text)

		# Listen for signal
		var watcher = SignalWatcher.new()
		SignalBus.unit_purchased.connect(watcher._on_signal)

		card.card_clicked.emit(card.unit_data)

		if watcher.received:
			print("SUCCESS: Unit purchased signal received for ", watcher.data.unit_name)
		else:
			print("FAILURE: Unit purchased signal not received.")
	else:
		print("FAILURE: Shop not populated correctly.")

	game_ui.queue_free()

func _test_drawing_cost():
	print("\n--- Testing Drawing Cost ---")
	# Need DrawingManager and a mock parent for it to add children to
	var parent_node = Node2D.new()
	add_child(parent_node)

	var drawing_manager = load("res://src/systems/DrawingManager.tscn").instantiate()
	parent_node.add_child(drawing_manager)

	await get_tree().process_frame

	# Initial wood is 0
	print("Initial Wood: ", GameManager.materials["wood"])

	# Try to draw
	drawing_manager.start_point = Vector2(0, 0)
	drawing_manager.is_drawing = true
	drawing_manager._finish_drawing(Vector2(100, 0)) # Length 100, Cost 100

	# Should fail
	if parent_node.get_child_count() == 1: # Only drawing_manager
		print("SUCCESS: Barricade not created (insufficient materials).")
	else:
		print("FAILURE: Barricade created despite insufficient materials.")

	# Add materials
	GameManager.add_material("wood", 200)
	print("Added 200 wood. Current: ", GameManager.materials["wood"])

	# Try to draw again
	drawing_manager.start_point = Vector2(0, 0)
	drawing_manager.is_drawing = true
	drawing_manager._finish_drawing(Vector2(100, 0))

	if parent_node.get_child_count() > 1:
		print("SUCCESS: Barricade created.")
		print("Final Wood: ", GameManager.materials["wood"])
		if GameManager.materials["wood"] == 100:
			print("SUCCESS: Wood deducted correctly.")
		else:
			print("FAILURE: Wood not deducted correctly.")
	else:
		print("FAILURE: Barricade not created.")

	parent_node.queue_free()

class SignalWatcher:
	var received = false
	var data
	func _on_signal(arg):
		received = true
		data = arg
