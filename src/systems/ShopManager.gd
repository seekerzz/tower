extends Node

signal shop_updated(cards_data)

var shop_size: int = 4
var shop_state: Array = [] # Array of dictionaries { "key": String, "locked": bool }

func _ready():
	# Wait for GameData to be ready if it's an Autoload, which it is.
	# But in -s mode, we need to be careful.
	refresh_shop()

func refresh_shop(force_all: bool = false):
	var new_shop_state = []
	# Check if GameData is valid
	if not GameData or not GameData.UNIT_TYPES:
		print("Error: GameData.UNIT_TYPES not available")
		return

	var keys = GameData.UNIT_TYPES.keys()
	if keys.size() == 0:
		return

	for i in range(shop_size):
		if not force_all and i < shop_state.size() and shop_state[i].get("locked", false):
			new_shop_state.append(shop_state[i])
		else:
			var random_key = keys.pick_random()
			new_shop_state.append({ "key": random_key, "locked": false })

	shop_state = new_shop_state
	shop_updated.emit(shop_state)

func toggle_lock(index: int):
	if index >= 0 and index < shop_state.size():
		shop_state[index]["locked"] = not shop_state[index]["locked"]
		shop_updated.emit(shop_state)

func get_item_at(index: int):
	if index >= 0 and index < shop_state.size():
		# GameData is autoload
		var key = shop_state[index]["key"]
		if GameData.UNIT_TYPES.has(key):
			return GameData.UNIT_TYPES[key]
	return null

func get_item_key_at(index: int):
	if index >= 0 and index < shop_state.size():
		return shop_state[index]["key"]
	return null

func buy_item(index: int) -> Dictionary:
	var item_data = get_item_at(index)
	if item_data:
		var cost = item_data.get("cost", 0)
		if GameManager.spend_gold(cost):
			return item_data
	return {}
