extends Node2D

func _ready():
	print("Starting Shop Integration Test")

	# Wait for things to settle
	await get_tree().process_frame
	await get_tree().process_frame

	var game_ui = get_node("/root/TestShopIntegration/GameUI")
	if not game_ui:
		print("FAIL: GameUI node not found")
		get_tree().quit(1)
		return

	var shop_manager = game_ui.shop_manager
	if not shop_manager:
		# Maybe it's not exposed as property or finding failed.
		# GameUI finds it in tree. In the test scene, we need to ensure ShopManager is there or created.
		print("Checking for ShopManager...")
		shop_manager = game_ui.find_child("ShopManager", true, false)
		if not shop_manager:
			print("FAIL: ShopManager not found in GameUI")
			get_tree().quit(1)
			return

	# In refactored ShopManager, we rely on GameData.UNIT_TYPES, not available_units array.
	# But check if refresh_shop worked.
	if shop_manager.shop_state.size() == 0:
		print("FAIL: ShopManager shop_state is empty")
		get_tree().quit(1)
		return

	print("PASS: ShopManager loaded state with ", shop_manager.shop_state.size(), " items.")

	var shop_container = game_ui.shop_container
	if shop_container.get_child_count() == 0:
		print("FAIL: Shop container is empty")
		get_tree().quit(1)
		return

	print("PASS: Shop container has ", shop_container.get_child_count(), " cards.")

	# Simulate Click
	var card = shop_container.get_child(0)
	# Check unit data is a Dictionary now
	var unit_data = card.unit_data
	var unit_name = unit_data.get("name", "Unknown")

	# Connect to signal to verify
	SignalBus.unit_purchased.connect(func(data):
		if data.get("name") == unit_name:
			print("PASS: SignalBus.unit_purchased received for ", unit_name)
			get_tree().quit(0)
		else:
			print("FAIL: SignalBus received wrong unit data: ", data)
			get_tree().quit(1)
	)

	# Trigger click manually via gui_input emulation or calling the handler
	print("Simulating purchase of ", unit_name)
	# GameUI connects gui_input to _on_shop_card_input(event, index)
	# We can call buy_item on manager directly to verify logic, or simulate input on GameUI.

	# Let's call the signal emission on GameUI that usually comes from internal logic?
	# Actually GameUI listens to shop_manager or handles input.
	# The refactored GameUI connects card.gui_input to _on_shop_card_input.
	# Let's just manually trigger what we expect the click to do: emit unit_purchased.
	# But that tests nothing.
	# Let's call GameUI._on_shop_card_input with a fake event.

	var ev = InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true

	game_ui._on_shop_card_input(ev, 0)

	# Timeout fallback
	await get_tree().create_timer(1.0).timeout
	print("FAIL: Timeout waiting for signal")
	get_tree().quit(1)
