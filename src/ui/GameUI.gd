extends CanvasLayer

@onready var shop_container = $BottomPanel/HBoxContainer/ShopContainer
@onready var bench_container = $BottomPanel/HBoxContainer/BenchContainer
@onready var health_label = $TopHUD/HBoxContainer/HealthLabel
@onready var wave_label = $TopHUD/HBoxContainer/WaveLabel
@onready var resource_label = $TopHUD/HBoxContainer/ResourceLabel
@onready var refresh_button = $BottomPanel/HBoxContainer/Buttons/RefreshButton

var shop_manager: Node
const ShopCardScene = preload("res://src/ui/components/ShopCard.tscn")

func _ready():
	# Initialize ShopManager
	shop_manager = preload("res://src/systems/ShopManager.gd").new()
	add_child(shop_manager)

	# Connect Signals
	SignalBus.resource_changed.connect(_on_resource_changed)
	SignalBus.wave_started.connect(_on_wave_started)
	refresh_button.pressed.connect(_on_refresh_button_pressed)

	# Initial UI update
	_update_resources()
	_update_health()
	_update_wave(GameManager.wave)

	# Initial Shop Refresh
	_refresh_shop()

func _process(_delta):
	# Optional: Update resources every frame if we want smooth interpolation,
	# but SignalBus.resource_changed is cleaner.
	# However, GameManager updates food/mana in _process and emits signal on floor change.
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
	# Logic for refresh cost could go here
	_refresh_shop()

func _refresh_shop():
	# Clear existing cards
	for child in shop_container.get_children():
		child.queue_free()

	var units = shop_manager.refresh_shop()
	for unit_data in units:
		var card = ShopCardScene.instantiate()
		shop_container.add_child(card)
		# We need to wait for ready or call setup immediately.
		# Instantiate adds to tree but _ready runs later?
		# No, add_child runs _ready if in tree.
		# But we can call setup explicitly.
		card.setup(unit_data)
		card.card_clicked.connect(_on_shop_card_clicked)

func _on_shop_card_clicked(unit_data):
	SignalBus.unit_purchased.emit(unit_data)
