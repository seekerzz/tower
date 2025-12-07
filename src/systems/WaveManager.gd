extends Node

signal wave_started
signal wave_ended
signal spawn_request(enemy_type, position)

var current_wave: int = 0
var is_wave_active: bool = false
var _enemies_spawned_count: int = 0
const MAX_ENEMIES_PER_WAVE = 10
const SPAWN_RADIUS = 300.0

@onready var spawn_timer: Timer = $SpawnTimer

func _ready():
	if spawn_timer:
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func start_wave():
	is_wave_active = true
	# Increment wave count only when starting a new wave?
	# The task doesn't specify when to increment, but usually it's at start.
	current_wave += 1
	_enemies_spawned_count = 0
	emit_signal("wave_started")

	spawn_timer.start()

func _on_spawn_timer_timeout():
	if not is_wave_active:
		return

	if _enemies_spawned_count >= MAX_ENEMIES_PER_WAVE:
		_end_wave()
		return

	# Random position on circle
	var angle = randf() * TAU
	var spawn_pos = Vector2(cos(angle), sin(angle)) * SPAWN_RADIUS

	emit_signal("spawn_request", "basic_enemy", spawn_pos)
	_enemies_spawned_count += 1

func _end_wave():
	is_wave_active = false
	spawn_timer.stop()
	emit_signal("wave_ended")
	SignalBus.wave_ended.emit(current_wave)
