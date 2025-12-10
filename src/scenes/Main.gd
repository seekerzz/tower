extends Node

@onready var wave_manager = $WaveManager
@onready var entity_layer = $EntityLayer

const ENEMY_SCENE = preload("res://src/entities/Enemy.tscn")
const EVENT_PANEL_SCENE = preload("res://src/ui/panels/EventPanel.tscn")

func _ready():
	# Wire up InteractionController
	if has_node("InteractionController") and has_node("GridManager"):
		$InteractionController.grid_manager = $GridManager

	wave_manager.spawn_request.connect(_on_wave_manager_spawn_request)
	SignalBus.enemy_reached_core.connect(_on_enemy_reached_core)
	SignalBus.wave_ended.connect(_on_wave_ended)

func _on_wave_ended(wave_number):
	if wave_number % 3 == 0:
		get_tree().paused = true
		var event_panel = EVENT_PANEL_SCENE.instantiate()
		add_child(event_panel)

		var options = [
			{"id": "heal", "text": "Heal +30"},
			{"id": "gold", "text": "Gold +100"},
			{"id": "enhance", "text": "Enhance +2.0 Food Rate"}
		]

		event_panel.setup(options)
		event_panel.option_selected.connect(_on_event_option_selected.bind(event_panel))

func _on_event_option_selected(option_id, panel):
	match option_id:
		"heal":
			GameManager.core_health = min(GameManager.max_core_health, GameManager.core_health + 30)
			SignalBus.resource_changed.emit("core_health", GameManager.core_health)
		"gold":
			GameManager.add_gold(100)
		"enhance":
			GameManager.base_food_rate += 2.0
			# Note: GameManager handles rate changes in _process, but if we need to emit changed signal for UI:
			# SignalBus.resource_changed.emit("base_food_rate", GameManager.base_food_rate)
			# (Assuming UI might display it, but current GameManager doesn't emit this signal type typically)

	panel.queue_free()
	get_tree().paused = false

func _on_wave_manager_spawn_request(enemy_type, position):
	# Currently ignoring enemy_type as we only have one Enemy.tscn
	var enemy = ENEMY_SCENE.instantiate()
	enemy.global_position = position
	entity_layer.add_child(enemy)

func _on_enemy_reached_core(amount):
	GameManager.take_damage(amount)
