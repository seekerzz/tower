extends Node

func _ready():
	print("Starting UI Test...")
	var game_ui = load("res://src/ui/GameUI.tscn").instantiate()
	add_child(game_ui)

	print("GameUI instantiated.")

	# Simulate adding a card
	var shop_card_scene = load("res://src/ui/components/ShopCard.tscn")
	game_ui.add_shop_card(shop_card_scene)

	print("ShopCard added.")

	# Verify structure
	var shop_container = game_ui.get_node("BottomPanel/HBoxContainer/ShopContainer")
	if shop_container.get_child_count() == 5: # 4 placeholders + 1 added card
		print("Test Passed: ShopCard added correctly.")
	else:
		print("Test Failed: ShopCard count mismatch. Expected 5, got ", shop_container.get_child_count())
		get_tree().quit(1)

	print("All checks passed.")
	get_tree().quit()
