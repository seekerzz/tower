extends Node

@onready var wave_manager = $WaveManager
@onready var entity_layer = $EntityLayer

const ENEMY_SCENE = preload("res://src/entities/Enemy.tscn")

func _ready():
	wave_manager.spawn_request.connect(_on_wave_manager_spawn_request)
	SignalBus.enemy_reached_core.connect(_on_enemy_reached_core)

func _on_wave_manager_spawn_request(enemy_type, position):
	# Currently ignoring enemy_type as we only have one Enemy.tscn
	var enemy = ENEMY_SCENE.instantiate()
	enemy.global_position = position
	entity_layer.add_child(enemy)

func _on_enemy_reached_core(amount):
	GameManager.take_damage(amount)
