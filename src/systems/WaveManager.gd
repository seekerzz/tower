extends Node

@export var spawn_radius: float = 600.0

var enemies_to_spawn: int = 0
var enemies_remaining: int = 0
var spawn_timer: Timer

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 0.5
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

	SignalBus.wave_started.connect(start_wave)
	SignalBus.enemy_died.connect(_on_enemy_died)

func start_wave(wave_num):
	var base_count = 20 + (wave_num * 6)
	enemies_to_spawn = base_count
	enemies_remaining = base_count

	spawn_timer.start()

func _on_spawn_timer_timeout():
	if enemies_to_spawn <= 0:
		spawn_timer.stop()
		return

	spawn_enemy()
	enemies_to_spawn -= 1

func spawn_enemy():
	var angle = randf() * TAU
	var spawn_pos = Vector2(cos(angle), sin(angle)) * spawn_radius

	var enemy_scene = load("res://src/scenes/Enemy.tscn")
	var enemy = enemy_scene.instantiate()

	# Determine enemy type based on wave
	var type = "slime"
	if GameManager.wave > 2: type = "wolf"
	# ... logic from ref.html

	enemy.global_position = spawn_pos

	# Add to main scene entities layer
	get_parent().get_node("EntityLayer").add_child(enemy)
	enemy.setup(type, float(GameManager.wave))
	SignalBus.enemy_spawned.emit(enemy)

func _on_enemy_died(enemy):
	enemies_remaining -= 1
	if enemies_remaining <= 0 and enemies_to_spawn <= 0:
		end_wave()

func end_wave():
	GameManager.wave += 1
	SignalBus.wave_ended.emit(GameManager.wave - 1)
	# Reward logic moved to Enemy die or here?
	# ref.html says "endWave" gives gold + 20 + wave*5
	GameManager.add_resource("gold", 20 + (GameManager.wave * 5))
