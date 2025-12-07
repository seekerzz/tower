extends Control

@onready var gold_label = $VBoxContainer/TopBar/Gold
@onready var food_label = $VBoxContainer/TopBar/Food
@onready var mana_label = $VBoxContainer/TopBar/Mana
@onready var wave_label = $VBoxContainer/TopBar/Wave
@onready var core_hp_label = $VBoxContainer/TopBar/CoreHP

@onready var shop_container = $VBoxContainer/BottomPanel/ShopContainer
@onready var build_container = $VBoxContainer/LeftPanel/BuildContainer

func _ready():
	SignalBus.resource_changed.connect(update_resource)
	SignalBus.core_damaged.connect(update_core_hp)
	SignalBus.wave_started.connect(update_wave)
	SignalBus.game_over.connect(show_game_over)

	update_all_ui()
	setup_shop()
	setup_build_panel()

func update_all_ui():
	gold_label.text = "💰 %d" % GameManager.gold
	food_label.text = "🍖 %d/%d" % [GameManager.food, GameManager.max_food]
	mana_label.text = "💧 %d/%d" % [GameManager.mana, GameManager.max_mana]
	wave_label.text = "Wave %d" % GameManager.wave
	core_hp_label.text = "❤️ %d/%d" % [GameManager.core_health, GameManager.max_core_health]

func update_resource(type, value):
	if type == "gold": gold_label.text = "💰 %d" % value
	elif type == "food": food_label.text = "🍖 %d/%d" % [value, GameManager.max_food]
	elif type == "mana": mana_label.text = "💧 %d/%d" % [value, GameManager.max_mana]

func update_core_hp(hp):
	core_hp_label.text = "❤️ %d/%d" % [hp, GameManager.max_core_health]

func update_wave(wave):
	wave_label.text = "Wave %d" % wave

func show_game_over(wave):
	$GameOverPanel.visible = true
	$GameOverPanel/Label.text = "Game Over! Reached Wave %d" % wave

func setup_shop():
	# Simple shop buttons
	for key in ["mouse", "turtle", "ranger", "plant"]: # Initial set
		var btn = Button.new()
		var unit = GameData.UNIT_TYPES[key]
		btn.text = "%s %s (%d)" % [unit.icon, unit.name, unit.cost]
		btn.pressed.connect(func(): _on_buy_unit(key, unit.cost))
		shop_container.add_child(btn)

func _on_buy_unit(key, cost):
	if GameManager.gold >= cost:
		# For now, just placing mode or add to bench?
		# Let's assume placement mode triggered immediately for simplicity in this version
		# Real version would have drag & drop or bench

		# Find a free spot around 0,0 or ask user to place?
		# Trigger placement mode in GridManager
		var main = get_tree().current_scene
		if main.name != "Main":
			main = main.find_child("Main", true, false)

		if main and main.has_method("start_placement"):
			main.start_placement(key)

func setup_build_panel():
	for key in GameData.MATERIAL_TYPES:
		var btn = Button.new()
		var mat = GameData.MATERIAL_TYPES[key]
		btn.text = "%s %s" % [mat.icon, mat.name]
		btn.pressed.connect(func(): _on_select_material(key))
		build_container.add_child(btn)

func _on_select_material(key):
	var main = get_tree().current_scene
	if main.name != "Main":
		main = main.find_child("Main", true, false)

	if main and main.has_method("start_drawing"):
		main.start_drawing(key)

func _on_start_wave_pressed():
	SignalBus.wave_started.emit(GameManager.wave)
