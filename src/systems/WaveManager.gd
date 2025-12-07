extends Node2D

@export var enemy_scene: PackedScene
@export var grid_manager: Node2D

var enemies_to_spawn: int = 0
var wave_active: bool = false
var spawn_timer: Timer

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 0.5
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	SignalBus.wave_started.connect(start_wave)
	SignalBus.enemy_died.connect(_on_enemy_died)

func start_wave(wave_num: int):
	wave_active = true
	enemies_to_spawn = 10 + wave_num * 5
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if enemies_to_spawn > 0:
		spawn_enemy()
		enemies_to_spawn -= 1
	else:
		spawn_timer.stop()

func spawn_enemy():
	var angle = randf() * TAU
	var radius = 600
	var spawn_pos = Vector2(cos(angle), sin(angle)) * radius

	var enemy = enemy_scene.instantiate()
	enemy.position = spawn_pos
	# Increase difficulty logic here
	add_child(enemy)

func _on_enemy_died(_enemy):
	if enemies_to_spawn <= 0 and get_tree().get_nodes_in_group("enemies").size() <= 1: # 1 because the dying one is still in group?
		end_wave()

func end_wave():
	wave_active = false
	SignalBus.wave_ended.emit()
