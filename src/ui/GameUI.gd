extends CanvasLayer

@onready var shop_container = $BottomPanel/HBoxContainer/ShopContainer
@onready var bench_container = $BottomPanel/HBoxContainer/BenchContainer
@onready var health_label = $TopHUD/HBoxContainer/HealthLabel
@onready var wave_label = $TopHUD/HBoxContainer/WaveLabel
@onready var resource_label = $TopHUD/HBoxContainer/ResourceLabel
@onready var refresh_button = $BottomPanel/HBoxContainer/Buttons/RefreshButton

# We should probably get ShopManager from the scene tree if it's there, or instantiate it if not.
# Assuming ShopManager is added in Main.gd or we find it.
var shop_manager: Node
const ShopCardScene = preload("res://src/ui/components/ShopCard.tscn")

func _ready():
	# Find ShopManager in parent (Main) or create it if standalone test
	shop_manager = get_tree().root.find_child("ShopManager", true, false)
	if not shop_manager:
		# Fallback for UI testing
		shop_manager = preload("res://src/systems/ShopManager.gd").new()
		add_child(shop_manager)

	if shop_manager.has_signal("shop_updated"):
		shop_manager.shop_updated.connect(_on_shop_updated)

	# Connect Signals
	SignalBus.resource_changed.connect(_on_resource_changed)
	SignalBus.wave_started.connect(_on_wave_started)
	refresh_button.pressed.connect(_on_refresh_button_pressed)

	# Initial UI update
	_update_resources()
	_update_health()
	_update_wave(GameManager.wave)

	# Initial Shop Refresh
	if shop_manager.has_method("refresh_shop"):
		shop_manager.refresh_shop()

func _process(_delta):
	pass

func _on_resource_changed(resource_name: String, _value):
	if resource_name in ["gold", "food", "mana", "materials"]:
		_update_resources()
	elif resource_name == "core_health":
		_update_health()

func _update_resources():
	var gold = GameManager.gold
	var food = floor(GameManager.food)
	var mana = floor(GameManager.mana)
	resource_label.text = "💰 %d  🌽 %d  💧 %d" % [gold, food, mana]

func _update_health():
	var current = ceil(GameManager.core_health)
	var max_h = ceil(GameManager.max_core_health)
	health_label.text = "❤️ %d/%d" % [current, max_h]

func _on_wave_started(wave_number):
	_update_wave(wave_number)

func _update_wave(wave_number):
	wave_label.text = "Wave %d" % wave_number

func _on_refresh_button_pressed():
	if GameManager.spend_gold(10):
		shop_manager.refresh_shop()

func _on_shop_updated(shop_state):
	_render_shop(shop_state)

func _render_shop(shop_state):
	# Clear existing cards
	for child in shop_container.get_children():
		child.queue_free()

	for i in range(shop_state.size()):
		var item = shop_state[i]
		var key = item["key"]
		var locked = item["locked"]

		if GameData.UNIT_TYPES.has(key):
			var data = GameData.UNIT_TYPES[key]
			var card = ShopCardScene.instantiate()
			shop_container.add_child(card)

			# We need to adapt ShopCard to handle dictionary data instead of UnitStats resource
			# Or we modify ShopCard.gd
			if card.has_method("setup_from_data"):
				card.setup_from_data(data, locked)
			else:
				# Temporarily Mock or fix ShopCard.gd
				# I'll update ShopCard.gd next.
				pass

			card.gui_input.connect(func(ev): _on_shop_card_input(ev, i))

func _on_shop_card_input(event, index):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var item_data = shop_manager.buy_item(index)
		if not item_data.is_empty():
			# Add to bench logic needs to happen here or via signal
			# ref.html says: if (addToBench(newUnit))
			# We need a BenchManager or similar.
			# For now, let's just emit a signal that Main or GridManager picks up
			SignalBus.unit_purchased.emit(item_data)
