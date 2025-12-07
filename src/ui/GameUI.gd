extends CanvasLayer

@onready var gold_label = $HUD/Resources/GoldLabel
@onready var food_label = $HUD/Resources/FoodLabel
@onready var mana_label = $HUD/Resources/ManaLabel
@onready var hp_label = $HUD/Status/HPLabel
@onready var wave_label = $HUD/Status/WaveLabel
@onready var shop_container = $ShopPanel/HBoxContainer
@onready var start_wave_btn = $ShopPanel/StartWaveBtn

var shop_card_scene = preload("res://src/ui/components/ShopCard.tscn")
var shop_manager

func _ready():
	SignalBus.resource_changed.connect(_on_resource_changed)
	SignalBus.core_health_changed.connect(_on_core_health_changed)
	SignalBus.wave_started.connect(_on_wave_started)
	SignalBus.wave_ended.connect(_on_wave_ended)

	start_wave_btn.pressed.connect(_on_start_wave_pressed)

	shop_manager = load("res://src/systems/ShopManager.gd").new()
	add_child(shop_manager) # Add it so it runs _ready? Or just use it as logic. Better as node.

	refresh_shop()

func _on_resource_changed(type, value):
	match type:
		"gold": gold_label.text = "Gold: %d" % value
		"food": food_label.text = "Food: %d" % int(value)
		"mana": mana_label.text = "Mana: %d" % int(value)

func _on_core_health_changed(value):
	hp_label.text = "HP: %d" % int(value)

func _on_wave_started(wave):
	wave_label.text = "Wave: %d" % wave
	start_wave_btn.disabled = true

func _on_wave_ended():
	start_wave_btn.disabled = false
	refresh_shop()

func _on_start_wave_pressed():
	SignalBus.wave_started.emit(GameManager.wave)

func refresh_shop():
	for child in shop_container.get_children():
		child.queue_free()

	var units = shop_manager.get_random_units(5)
	for unit_data in units:
		var card = shop_card_scene.instantiate()
		card.unit_data = unit_data
		shop_container.add_child(card)
